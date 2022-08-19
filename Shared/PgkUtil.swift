//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation
import Combine

// MARK: - Types and Enums
typealias PkgUtilOutput = [String]

/// Error  thrown by pkgutil system command
enum PkgUtilErrors: Error {
    case pkgUtilCmdFailed(errorno: Int32)
}

/// Error Messages thrown by pkgutil functions
enum PkgUtilsErrorMessages: String {
    case promptMessage = "pkgutil return ocde:"
    case unknownError = "Unknown error"
}

/// Tristate for result check existence of files / dirs
enum CheckExistence {
    case unknown, exists, notExists
}

/// Defines properties and functions of  the manage package utilty
class PkgUtil: ObservableObject {
    
    // MARK: - Properties exposed to outside
    @Published var currentPkg: String = ""
    @Published private(set) var pkgList: PkgUtilOutput = []
    private(set) var pkgGroups: PkgUtilOutput = []
    private(set) var pkgFilesDirs: PkgUtilOutput = []
    private(set) var pkgFilesDirsExistence = [CheckExistence]()   // Holds per each file/dir whether they exist in filesystem
    
    // MARK: - Constants for pkgutil command

    private static let pkgCmd = "/usr/sbin/pkgutil"
    
    /// Commands of pkgutil implemented
    enum PkgCommands: String {
        case list = "--pkgs"
        case groups = "--groups"
        case pkgsOfGroup = "--group-pkgs"
        case info = "--pkg-info"
        case info_plist = "--pkg-info-plist"
        case filesDirs = "--lsbom"
        case forget = "--forget"
    }
    /// Options for some pkgutil commands
    enum PkgOptions: String {
        case onlyFiles = "--only-files"
        case onlyDirs = "--only-dirs"
    }
    /// Various info retrievable for a package
    enum PkgInfo: String {
        case location = "install-location"
        case time = "install-time"
        case version = "version"
        case id = "pkgid"
        case receiptPlist = "receipt-plist"
        case volume = "volume"
    }
    
    
    /// Apple packages begin with com.apple.pkg (or com.apple)
    private static let applePkgs = "com.apple.pkg"
    
    
    /// Start with packages of pkgutil but remove Apple packages
    public init() {
        getPkgList()
        hideApplePkgs()
    }
    
    // MARK: - Read packages and groups
    
    /// Reading all packages
    /// sets the var pkgList
    func getPkgList() {
        pkgList.removeAll()
        do {
            try pkgList = (pkgutil(args: PkgCommands.list.rawValue))
            pkgList.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// hides all Apple packages from pkglist
    func hideApplePkgs() {
        pkgList.removeAll { pkg in
            pkg.hasPrefix(PkgUtil.applePkgs) ? true : false
        }
    }
    
    /// Reading all package groups
    /// sets the var pkgGroups
    func getPkgGroups() {
        pkgGroups.removeAll()
        do {
            try pkgGroups = pkgutil(args: PkgCommands.groups.rawValue)
            pkgGroups.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    // MARK: - Read files and directories of a package
    
    /// Getting all files and directories  of a given package
    /// sets the var currentPkgFilesDirs
    /// - Parameter package: package to inspect for files and directories
    func getPkgFilesDirs(of package: String) {
        pkgFilesDirs.removeAll()
        do {
            try pkgFilesDirs = pkgutil(args: PkgCommands.filesDirs.rawValue, package)
            pkgFilesDirs.removeFirst() // remove current dir
            pkgFilesDirsExistence = Array(repeating: CheckExistence.unknown, count: pkgFilesDirs.count)
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Getting all files  of a given package
    /// sets the var currentPkgFilesDirs
    /// - Parameter package: package to inspect for files
    func getPkgFiles(of package: String) {
        pkgFilesDirs.removeAll()
        do {
            try pkgFilesDirs = pkgutil(args: PkgOptions.onlyFiles.rawValue, PkgCommands.filesDirs.rawValue, package)
            pkgFilesDirs.removeFirst() // remove current dir
            pkgFilesDirsExistence = Array(repeating: CheckExistence.unknown, count: pkgFilesDirs.count)
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Getting all directories  of a given package
    /// sets the var currentPkgFilesDirs
    /// - Parameter package: package to inspect for directories
    func getPkgDirs(of package: String) {
        pkgFilesDirs.removeAll()
        do {
            try pkgFilesDirs = pkgutil(args: PkgOptions.onlyDirs.rawValue, PkgCommands.filesDirs.rawValue, package)
            pkgFilesDirs.removeFirst() // remove current dir
            pkgFilesDirsExistence = Array(repeating: CheckExistence.unknown, count: pkgFilesDirs.count)
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Checks if the files / dirs for a package exists
    /// Updates var pkgFilesDirsExistence
    /// - Parameter package: package to be checked
    func checkFileDirExistence(of package: String) throws {
        do {
            let pkgInfoDict = try readPkgInfoAsPlist(of: package)
            
            if let path = pkgInfoDict?[PkgInfo.location.rawValue], let volume = pkgInfoDict?[PkgInfo.volume.rawValue] {
                let fm = FileManager.default
                for (index, item) in pkgFilesDirs.enumerated() {
                    // Check file / dir for existence
                    let filePath = "\(volume)\(path)/\(item)"
                    pkgFilesDirsExistence[index] = fm.fileExists(atPath: filePath) ? CheckExistence.exists : CheckExistence.notExists
                }
            }
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }

    // MARK: - Read Info of a package
    
    /// Read info of package as lines of strings
    /// - Parameter package: package to read info from
    /// - Returns: Package Info (array of string lines of pkgutil output)
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    func readPkgInfoAsLines(of package: String) throws -> PkgUtilOutput {
        return  try pkgutil(args: PkgCommands.info.rawValue, package)
    }
    
    /// Read info of package as plist dict
    /// - Parameter package: package to read info from
    /// - Returns: Package Info (plist as dict )
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    func readPkgInfoAsPlist(of package: String) throws -> [String: Any]? {
        do {
            let pkgInfo = try pkgutilAsString(args: PkgCommands.info_plist.rawValue, package)
            let plistData = Data(pkgInfo.utf8)
            let options = PropertyListSerialization.MutabilityOptions.mutableContainers
            return (try PropertyListSerialization.propertyList(from: plistData,
                                                               options: PropertyListSerialization.ReadOptions(rawValue: options.rawValue),
                                                               format: nil)) as? [String: Any]
            
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
            return nil
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Read info of package
    /// - Parameter package: package to read info from
    /// - Returns: Package Info as string
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    func readPkgInfoAsString(of package: String) throws -> String {
        return try pkgutilAsString(args: PkgCommands.info.rawValue, package)
    }
    
    // MARK: - Helpers
    
    /// call pkgutil command line tool
    /// - Parameter args: for pkgutil
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    /// - Returns: PkgUtilOutput (Array of strings). Each entry correspnds to one info line
    private  func pkgutil(args: String...) throws -> PkgUtilOutput {
        let outputPipe = Pipe()
        let task = Process()
        task.launchPath = PkgUtil.pkgCmd
        task.arguments = args
        task.standardOutput = outputPipe
        if let _ = try? task.run() {
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self).components(separatedBy: CharacterSet.newlines)
        } else {
            throw PkgUtilErrors.pkgUtilCmdFailed(errorno: task.terminationStatus)
        }
    }
    
    /// call pkgutil command line tool
    /// - Parameter args: for pkgutil
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    /// - Returns: Info as a string
    private  func pkgutilAsString(args: String...) throws -> String {
        let outputPipe = Pipe()
        let task = Process()
        task.launchPath = PkgUtil.pkgCmd
        task.arguments = args
        task.standardOutput = outputPipe
        if let _ = try? task.run() {
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } else {
            throw PkgUtilErrors.pkgUtilCmdFailed(errorno: task.terminationStatus)
        }
    }

    
}
