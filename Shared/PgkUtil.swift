//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation
import Combine

// MARK: - Types and Enums

enum FileModes: NSNumber {
    case unknown        // unknown mode
    case dir    = 16877 // directory
    case link   = 41471 // link (file)
    case exe    = 33261 // executable (file)
    case file   = 33188 // rgular file
}

/// Information of a specific file/dir of a specfic package
struct PkgPath: Identifiable {
    let id = UUID()
    let path: String
    let mode: FileModes
    var exists: Bool = false   // Holds per each file/dir whether they exist in filesystem
}

/// All information about a package
struct PackageInfo: Identifiable {
    var id: String
    var volume: String
    var installLocation: String
    var installTime: Date
    var paths: [PkgPath]
    
    init() {
        id = ""
        volume = ""
        installLocation = ""
        installTime = Date()
        paths = []
    }
}

// MARK: - Error Enums

/// Error  thrown by pkgutil system command
enum PkgUtilErrors: Error {
    case pkgUtilCmdFailed(errorno: Int32)
    case noPackages
    case noPathsForPackage(package: String)
}

/// Error Messages thrown by pkgutil functions
enum PkgUtilsErrorMessages: String {
    case promptMessage = "pkgutil return ocde:"
    case unknownError = "Unknown error"
    case unkownPackage = "Unknown package:"
}

// MARK: - Main Class

/// Defines properties and functions of  the manage package utilty
class PkgUtil: ObservableObject {
    
    // MARK: - Properties exposed to outside
    @Published private(set) var pkgList = [String]()
    
    var currentPkg = PackageInfo()
    var currentPaths = [PkgPath]()
    
    var getPkgDescription: String {
        PkgExternalInfo.id.rawValue + currentPkg.id + "\n" +
        PkgExternalInfo.volume.rawValue + currentPkg.volume + "\n" +
        PkgExternalInfo.location.rawValue + currentPkg.installLocation + "\n" +
        PkgExternalInfo.time.rawValue + currentPkg.installTime.description
    }
    
    private(set) var pkgGroups = [String]()
    
    // MARK: - Constants for pkgutil command
    
    private static let pkgCmd = "/usr/sbin/pkgutil"
    
    /// Commands of pkgutil implemented
    enum PkgCommands: String {
        case list = "--pkgs"
        case groups = "--groups"
        case pkgsOfGroup = "--group-pkgs"
        case info_plist = "--pkg-info-plist"
        case forget = "--forget"
        case pkg_plist = "--export-plist"
    }

    /// keys used in plist of pkgutil
    enum PkgPlistKeys: String {
        case location = "install-location"
        case time = "install-time"
        case version = "version"
        case id = "pkgid"
        case receiptPlist = "receipt-plist"
        case volume = "volume"
        case paths = "paths"
        case mode = "mode"
    }
    
    /// Various info retrievable for a package
    enum PkgExternalInfo: String {
        case location = "location: "
        case time = "install-time: "
        case version = "version: "
        case id = "package-id: "
        case volume = "volume: "
    }
    
    /// Apple packages begin with com.apple.pkg (or com.apple)
    private static let applePkgs = "com.apple."
 
    
    // MARK: - Initialization
    
    /// Start with packages of pkgutil but remove Apple packages
    public init() {
        getPkgList()
    }
    
    
    // MARK: - Read packages and groups
    
    /// Reading all packages
    /// sets the var pkgList
    func getPkgList() {
        pkgList.removeAll()
        do {
            pkgList = try PkgUtil.pkgutil(args: PkgCommands.list.rawValue).components(separatedBy: CharacterSet.newlines)
            pkgList.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Checks whether pacakge is an Apple package
    /// - Parameter pkg: package to be checked
    /// - Returns: true if Apple package, otherwise false
    func isApplePkg(_ pkg: String) -> Bool {
        pkg.hasPrefix(PkgUtil.applePkgs) ? true : false
    }
    
    /// Reading all package groups
    /// sets the var pkgGroups
    func getPkgGroups() {
        pkgGroups.removeAll()
        do {
            try pkgGroups = PkgUtil.pkgutil(args: PkgCommands.groups.rawValue).components(separatedBy: CharacterSet.newlines)
            pkgGroups.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Read package as plist dict
    /// - Parameter package: package to read
    /// - Returns: Package (plist as dict )
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null)), nopackages, noPathsForPackages
    ///
    func readPkgAsPlist(of package: String) throws {
        do {
            // get all info with pkgutil and extract it
            let pkgutilResult = try PkgUtil.pkgutil(args: PkgCommands.pkg_plist.rawValue, package)
            let plistData = Data(pkgutilResult.utf8)
            let options = PropertyListSerialization.MutabilityOptions.mutableContainers
            let plistDict = (try PropertyListSerialization.propertyList(from: plistData,
                                                                        options: PropertyListSerialization.ReadOptions(rawValue: options.rawValue),
                                                                        format: nil)) as? NSDictionary
            guard let plistDict = plistDict else {
                throw PkgUtilErrors.noPackages
            }
            
            // Process pkg info
            currentPkg.id = package
            currentPkg.volume = plistDict[PkgPlistKeys.volume.rawValue] as! String
            currentPkg.installLocation = plistDict[PkgPlistKeys.location.rawValue] as! String
            let installTime = plistDict[PkgPlistKeys.time.rawValue] as! NSNumber  // TODO: Convert to Date/Time
            currentPkg.installTime  = Date(timeIntervalSince1970: installTime.doubleValue)
            
            // Process paths of packages
            currentPkg.paths.removeAll()
            let paths = plistDict["paths"] as! [String: Any]
            for (path, value) in paths {
                guard let value = value as? NSDictionary else { throw PkgUtilErrors.noPathsForPackage(package: package) }
                let modeAsNumber = value["mode"] as! NSNumber
                let modeAsFileMode: FileModes
                switch modeAsNumber {
                case FileModes.dir.rawValue:
                    modeAsFileMode = FileModes.dir
                case FileModes.file.rawValue:
                    modeAsFileMode = .file
                case FileModes.link.rawValue:
                    modeAsFileMode = .link
                case FileModes.exe.rawValue:
                    modeAsFileMode = .exe
                default:
                    modeAsFileMode = FileModes.unknown
                }
                currentPkg.paths.append(PkgPath(path: path, mode: modeAsFileMode))
            }
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
            return
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
    }
    
    /// Checks if the files / dirs for the currentPkg exists
    /// Updates var currentPkg
    /// - Parameter package: package to be checked
    func checkFileDirExistence() {
        let fm = FileManager.default
        for (index, item) in currentPkg.paths.enumerated() {
            // Check file / dir for existence
            let fullpath = "\(currentPkg.volume)\(currentPkg.installLocation)/\(item.path)"
            currentPkg.paths[index].exists = fm.fileExists(atPath: fullpath) ? true : false
        }
    }
    
    // MARK: - Getters to important vars
    
    func getAllPaths() {
        currentPaths = currentPkg.paths
    }
    
    func getFiles() {
        currentPaths = currentPkg.paths.filter({ path in
            path.mode == .file || path.mode == .link || path.mode == .exe
        })
    }
    
    func getDirs() {
        currentPaths = currentPkg.paths.filter({ path in
            path.mode == .dir
        })
    }
    
    // MARK: - Helpers
    
    /// call pkgutil command line tool
    /// - Parameter args: for pkgutil
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    /// - Returns: Info as a string
    static private  func pkgutil(args: String...) throws -> String {
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
