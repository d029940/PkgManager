//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation

// MARK: - Types and Enums

enum FileMode {
    case fileAndDir // unknown mode, also used if it is either a file or a dir
    case dir        // directory
    case file       //  file
}

/// Information of a specific file/dir of a specfic package
struct PkgPath: Identifiable {
    let id = UUID()
    let path: String
    let mode: FileMode
    var exists: Bool?   // Holds per each file/dir whether they exist in filesystem
}

/// All information about a package
struct PackageInfo: Identifiable {
    var id: String
    var volume: String
    var installLocation: String
    var installTime: Date
    
    init() {
        id = ""
        volume = ""
        installLocation = ""
        installTime = Date()
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
        case files = "--files"
        case groups = "--groups"
        case pkgsOfGroup = "--group-pkgs"
        case info_plist = "--pkg-info-plist"
        case pkgInfo = "--pkg-info"
        case forget = "--forget"
//        case pkg_plist = "--export-plist"
    }
    /// Options for pkguitl in conjunction file files command
    enum PkgOptions: String {
        case onlyFiles = "--only-files"
        case onlyDirs = "--only-dirs"
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
        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
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
        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
        } catch {
            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
        }
        return pkgGroups
    }
    
    /// Get files and/or dirs of package
    /// - Parameter package: Mac package
    /// - Parameter fileMode: 'unkown' for getting all files and dirs, 'file' for getting only files, 'dir' for getting only dirs
    /// - Returns: List of file names including paths
    static func getFilesOfPkg(_ package: String, fileMode: FileMode = .fileAndDir) -> [PkgPath] {
        var result = [PkgPath]()
        var options: String
        switch fileMode {
        case .file:
            options = PkgOptions.onlyFiles.rawValue
        case .dir:
            options = PkgOptions.onlyDirs.rawValue
        default:
            options = ""
        }
        do {
            let pkgutilResult = try PkgUtilCmd.pkgutil(args: options, PkgCommands.files.rawValue, package)
            var paths = pkgutilResult.components(separatedBy: CharacterSet.newlines)
            paths.removeLast()
            
            for item in paths {
                result.append(PkgPath(path: item, mode: fileMode))
            }
            
        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
        } catch  {
            print(error.localizedDescription)
            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
        }
        return result
    }
    
    /// Get info about package
    /// - Parameter package: Mac package
    /// - Returns: Infos of package
    static func getInfoOfPkg(_ package: String) -> PackageInfo {
        var pkgInfo = PackageInfo()
        do {
            let pkgutilResult = try PkgUtilCmd.pkgutil(args: PkgCommands.pkgInfo.rawValue, package)
            let result = pkgutilResult.components(separatedBy: CharacterSet.newlines)
            pkgInfo.id = result[0].components(separatedBy: CharacterSet.whitespaces).last ?? ""
            pkgInfo.volume = result[2].components(separatedBy: CharacterSet.whitespaces).last ?? ""
            pkgInfo.installLocation = result[3].components(separatedBy: CharacterSet.whitespaces).last ?? ""
            let installTimeComponents = result[4].components(separatedBy: CharacterSet.whitespaces)
            let installTime = Double(installTimeComponents.last!) ?? 0
            pkgInfo.installTime = Date(timeIntervalSince1970: installTime)
            
        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
        } catch  {
            print(error.localizedDescription)
            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
        }
        return pkgInfo
    }
    
    
    // MARK: - Destructive actions on pakckages
    static func forgetPkg(_ package: String) throws {
        do {
            try PkgUtilCmd.pkgutil(args: PkgCommands.forget.rawValue, package)
        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
        } catch  {
            print(error.localizedDescription)
            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
        }
    }
    
    // MARK: - Utility functions
    
    /// Checks if the files / dirs for the currentPkg exists
    /// Updates var currentPkg
    /// - Parameter package: package to be checked
    static func checkFileDirExistence(currentPkg: PackageInfo, paths: inout [PkgPath]) {
        let fm = FileManager.default
        for (index, item) in paths.enumerated() {
            // Check file / dir for existence
            let fullpath = fullPath(volume: currentPkg.volume, installLocation: currentPkg.installLocation, itemPath: item.path)
            paths[index].exists = fm.fileExists(atPath: fullpath) ? true : false
        }
    }
    
    /// Constructs full path out of pieces given by Package info
    /// - Parameters:
    ///   - volume: Volume from Package info
    ///   - installLocation: installation location from Package info
    ///   - itemPath:name of file/dir to be shown in Finder
    /// - Returns: Fullpath constructed out of the parameters
    static func fullPath(volume: String, installLocation: String, itemPath: String) -> String {
        return("\(volume)\(installLocation)/\(itemPath)")
    }
    
    // MARK: - Old approach taking plist as reading pkg list -> quite slow
    
//
//    enum FileMode: NSNumber {
//        case unknown        // unknown mode, also used if it is either a file or a dir
//        case dir    = 16877 // directory
//        case link   = 41471 // link (file)
//        case exe    = 33261 // executable (file)
//        case file   = 33188 // rgular file
//    }
    
//    /// keys used in plist of pkgutil
//    enum PkgPlistKeys: String {
//        case location = "install-location"
//        case time = "install-time"
//        case version = "version"
//        case id = "pkgid"
//        case receiptPlist = "receipt-plist"
//        case volume = "volume"
//        case paths = "paths"
//        case mode = "mode"
//    }

//    /// All information about a package
//    struct PackageInfo: Identifiable {
//        var id: String
//        var volume: String
//        var installLocation: String
//        var installTime: Date
//        var paths: [PkgPath]
//
//        init() {
//            id = ""
//            volume = ""
//            installLocation = ""
//            installTime = Date()
//            paths = []
//        }
    
//    /// Read package as plist dict
//    /// - Parameter package: package to read
//    /// - Returns: Package (plist as dict )
//    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null)), nopackages, noPathsForPackages
//    static func readPkgAsPlist(of package: String) throws -> PackageInfo {
//        var currentPkg = PackageInfo()
//
//        do {
//            // get all info with pkgutil and extract it
//            let pkgutilResult = try PkgUtilCmd.pkgutil(args: PkgCommands.pkg_plist.rawValue, package)
//            let plistData = Data(pkgutilResult.utf8)
//            let options = PropertyListSerialization.MutabilityOptions.mutableContainers
//            let plistDict = (try PropertyListSerialization.propertyList(from: plistData,
//                                                                        options: PropertyListSerialization.ReadOptions(rawValue: options.rawValue),
//                                                                        format: nil)) as? NSDictionary
//            guard let plistDict = plistDict else {
//                throw PkgUtilError.noPackages
//            }
//
//            // Process pkg info
//            currentPkg.id = package
//            currentPkg.volume = plistDict[PkgPlistKeys.volume.rawValue] as! String
//            currentPkg.installLocation = plistDict[PkgPlistKeys.location.rawValue] as! String
//            currentPkg.installTime = Date(timeIntervalSince1970: plistDict[PkgPlistKeys.time.rawValue] as! Double)
//
//
//            // Process paths of packages
//            currentPkg.paths.removeAll()
//            let paths = plistDict["paths"] as! [String: Any]
//            for (path, value) in paths {
//                guard let value = value as? NSDictionary else { throw PkgUtilError.noPathsForPackage(package: package) }
//                let modeAsNumber = value["mode"] as! NSNumber
//                let modeAsFileMode: FileMode
//                switch modeAsNumber {
//                case FileMode.dir.rawValue:
//                    modeAsFileMode = FileMode.dir
//                case FileMode.file.rawValue:
//                    modeAsFileMode = .file
//                case FileMode.link.rawValue:
//                    modeAsFileMode = .link
//                case FileMode.exe.rawValue:
//                    modeAsFileMode = .exe
//                default:
//                    modeAsFileMode = FileMode.unknown
//                }
//                currentPkg.paths.append(PkgPath(path: path, mode: modeAsFileMode))
//            }
//        } catch PkgUtilError.pkgUtilCmdFailed(let errorno) {
//            print("\(PkgUtilsErrorMessage.promptMessage.rawValue) \(errorno)")
//        } catch  {
//            print(error.localizedDescription)
//            fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
//        }
//        return currentPkg
//    }
    
//    /// Checks if the files / dirs for the currentPkg exists
//    /// Updates var currentPkg
//    /// - Parameter package: package to be checked
//    static func checkFileDirExistence_Old(currentPkg: inout PackageInfo) {
//        let fm = FileManager.default
//        for (index, item) in currentPkg.paths.enumerated() {
//            // Check file / dir for existence
//            let fullpath = fullPath(volume: currentPkg.volume, installLocation: currentPkg.installLocation, itemPath: item.path)
//            currentPkg.paths[index].exists = fm.fileExists(atPath: fullpath) ? true : false
//        }
//    }
//
    
}
