//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation
import Combine

typealias PkgUtilOutput = [String]

enum PkgUtilErrors: Error {
    case pkgUtilCmdFailed(errorno: Int32)
}

enum PkgUtilsErrorMessages: String {
    case promptMessage = "pkgutil return ocde:"
    case unknownError = "Unknown error"
}

class PkgUtil: ObservableObject {
    @Published var currentPkg: String = ""
    @Published private(set) var pkgList: PkgUtilOutput = []
    private(set) var pkgGroups: PkgUtilOutput = []
    private(set) var currentPkgFilesDirs: PkgUtilOutput = []
    private(set) var pkgFilesDirs: [PkgUtilOutput] = []
    
    // Constants for pkgutil command
    private static let pkgCmd = "/usr/sbin/pkgutil"
    enum PkgCommands: String {
        case list = "--pkgs"
        case groups = "--groups"
        case pkgsOfGroup = "--group-pkgs"
        case info = "--pkg-info"
        case filesDirs = "--lsbom"
        case forget = "--forget"
    }
    enum PkgOptions: String {
        case onlyFiles = "--only-files"
        case onlyDirs = "--only-dirs"
    }
    private static let applePkgs = "com.apple.pkg" // Apple packages begin with com.apple.pkg (or com.apple)
    
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
    
    // MARK: -Read Infos, files and directories of a package
    
    /// Getting all files and directories  of a given package
    /// sets the var currentPkgFilesDirs
    /// - Parameter package: package to inspect for files and directories
    func getPkgFilesDirs(of package: String) {
        currentPkgFilesDirs.removeAll()
        do {
            try currentPkgFilesDirs = pkgutil(args: PkgCommands.filesDirs.rawValue, package)
            currentPkgFilesDirs.removeFirst() // remove current dir
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
        currentPkgFilesDirs.removeAll()
        do {
            try currentPkgFilesDirs = pkgutil(args: PkgOptions.onlyFiles.rawValue, PkgCommands.filesDirs.rawValue, package)
            currentPkgFilesDirs.removeFirst() // remove current dir
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
        currentPkgFilesDirs.removeAll()
        do {
            try currentPkgFilesDirs = pkgutil(args: PkgOptions.onlyDirs.rawValue, PkgCommands.filesDirs.rawValue, package)
            currentPkgFilesDirs.removeFirst() // remove current dir
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Get files and directories of all packages
    func getAllPkgFilesDirs() {
        pkgFilesDirs.removeAll()
        for pkg in pkgList {
            getPkgFilesDirs(of: pkg)
            pkgFilesDirs.append(currentPkgFilesDirs)
        }
    }
    
    /// Read info of package
    /// - Parameter package: package to read info from
    /// - Returns: Package Info (array of string lines of pkgutil output)
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    func readPkgInfoAsLines(of package: String) throws -> PkgUtilOutput {
        return  try pkgutil(args: PkgCommands.info.rawValue, package)
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
