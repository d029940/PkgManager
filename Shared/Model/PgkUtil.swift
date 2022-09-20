//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation

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

// MARK: - Main struct

/// Defines properties and functions of  the manage package utilty
struct PkgUtil {
    
    static private(set) var pkgListApple = [String]()
    static private(set) var pkgListNonApple = [String]()
    private(set) var pkgGroups = [String]()
    
    // MARK: - Constants for pkgutil command
    
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
    
    /// Apple packages begin with com.apple.pkg (or com.apple)
    private static let applePkgs = "com.apple."
 
    
    // MARK: - Read packages and groups
    
    /// Reading all packages
    /// - Returns: pkgList
    static func getPkgList() {
        var pkgList = [String]()
        do {
            pkgList = try PkgUtilCmd.pkgutil(args: PkgCommands.list.rawValue).components(separatedBy: CharacterSet.newlines)
            pkgList.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
        for pkg in pkgList {
            PkgUtil.isApplePkg(pkg) ? PkgUtil.pkgListApple.append(pkg) : PkgUtil.pkgListNonApple.append(pkg)
        }
    }
    
    /// Checks whether pacakge is an Apple package
    /// - Parameter pkg: package to be checked
    /// - Returns: true if Apple package, otherwise false
    static func isApplePkg(_ pkg: String) -> Bool {
        pkg.hasPrefix(PkgUtil.applePkgs) ? true : false
    }
    
    /// Reading all package groups
    /// - Returns: pkgGroups
    func getPkgGroups() -> [String] {
        var pkgGroups = [String]()
        do {
            pkgGroups = try PkgUtilCmd.pkgutil(args: PkgCommands.groups.rawValue).components(separatedBy: CharacterSet.newlines)
            pkgGroups.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessages.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
        return pkgGroups
    }
    
    /// Read package as plist dict
    /// - Parameter package: package to read
    /// - Returns: Package (plist as dict )
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null)), nopackages, noPathsForPackages
    static func readPkgAsPlist(of package: String) throws -> PackageInfo {
        var currentPkg = PackageInfo()
        
        do {
            // get all info with pkgutil and extract it
            let pkgutilResult = try PkgUtilCmd.pkgutil(args: PkgCommands.pkg_plist.rawValue, package)
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
        } catch  {
            print(error.localizedDescription)
            fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
        }
        return currentPkg
    }
    
    /// Checks if the files / dirs for the currentPkg exists
    /// Updates var currentPkg
    /// - Parameter package: package to be checked
    static func checkFileDirExistence(currentPkg: inout PackageInfo) {
        let fm = FileManager.default
        for (index, item) in currentPkg.paths.enumerated() {
            // Check file / dir for existence
            let fullpath = "\(currentPkg.volume)\(currentPkg.installLocation)/\(item.path)"
            currentPkg.paths[index].exists = fm.fileExists(atPath: fullpath) ? true : false
        }
    }
    
}
