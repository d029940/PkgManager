//
//  PkgUtilVm.swift
//  PkgManager
//
//  Created by Manfred on 20.09.22.
//

import Foundation
import Combine
import AppKit



// MARK: - Enums

/// Error Messages thrown by pkgutil functions
enum PkgUtilsErrorMessage: String {
    case promptMessage = "pkgutil return ocde:"
    case unknownError = "Unknown error"
    case unkownPackage = "Unknown package:"
    case invalidArgs = "Invalid argument list"
}


/// indicates to show info, files & dirs of a package
enum InfoFilesDirsState: Identifiable, CaseIterable {
    case info, files, dirs, filesAndDirs
    var id: Self {self}
}

// MARK: - Main Class

/// Defines properties and functions of  the manage package utilty
class PkgUtilVm: ObservableObject {
    
    // MARK: - Properties exposed to outside
    
    @Published private(set) var pkgList = [String]()
    @Published var showApplePkg = false
    @Published var showExistenceCheck = false
    @Published var showInfoFilesDirs = InfoFilesDirsState.info
    
    var currentPkg = PackageInfo()
    var currentFilesPaths = [PkgPath]()
    var currentOnlyFilesPaths = [PkgPath]()
    var currentOnlyDirsPaths = [PkgPath]()
    
    var getPkgDescription: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm"
        return PkgExternalInfo.id.rawValue + currentPkg.id + "\n" +
        PkgExternalInfo.volume.rawValue + currentPkg.volume + "\n" +
        PkgExternalInfo.location.rawValue + currentPkg.installLocation + "\n" +
        PkgExternalInfo.time.rawValue + dateFormatter.string(from: currentPkg.installTime)
    }
    
    // MARK: - Constants for pkgutil command
    
    /// Various info retrievable for a package
    enum PkgExternalInfo: String {
        case location = "location: "
        case time = "install-time: "
        case version = "version: "
        case id = "package-id: "
        case volume = "volume: "
    }
    
    
    // MARK: - Initialization
    
    /// Start with packages of pkgutil but remove Apple packages
    public init() {
        getPkgList()
    }
    
    
    // MARK: - Read packages and groups
    
    /// Reading all packages
    /// sets the var pkgList
    func getPkgList() {
        PkgUtil.getPkgList()
        pkgList = PkgUtil.pkgListNonApple
    }
    
    // MARK: - Users intent(s)
    
    /// Checks if the files / dirs for the currentPkg exists
    /// Updates var currentPkg
    /// - Parameter package: package to be checked
    func checkFileDirExistence() {
        switch showInfoFilesDirs {
        case .files:
            if currentOnlyFilesPaths.first?.exists == nil {
                PkgUtil.checkFileDirExistence(currentPkg: currentPkg, paths: &currentOnlyFilesPaths)
            }
        case .dirs:
            if currentOnlyDirsPaths.first?.exists == nil {
                PkgUtil.checkFileDirExistence(currentPkg: currentPkg, paths: &currentOnlyDirsPaths)
            }
        case .filesAndDirs:
            if currentFilesPaths.first?.exists == nil {
                PkgUtil.checkFileDirExistence(currentPkg: currentPkg, paths: &currentFilesPaths)
            }
        default:
            return
        }
    }

    /// Shows file/dir location and select it in Finder
    /// - Parameters:
    ///   - volume: Volume from Package info
    ///   - installLocation: installation location from Package info
    ///   - itemPath:name of file/dir to be shown in Finder
    static func openInFileViewer(volume: String, installLocation: String, itemPath: String) {
        let fullPath = PkgUtil.fullPath(volume: volume, installLocation: installLocation, itemPath: itemPath)
        openInFileViewer(fullPath: fullPath)
    }
    
    /// Shows file/dir location and select it in Finder
    /// - Parameter fullPath: full path of file/dir to be shwon in Finder
    static func openInFileViewer(fullPath: String) {
        NSWorkspace.shared.selectFile(fullPath, inFileViewerRootedAtPath: "")
    }
    
    /// Forget package, i.e. remove package from MacOS package list
    /// Information about files, dirs and info of package will be saved
    /// - Parameter pkg: package to forget
    static func forgetPackage(_ pkg: String) {
        // TODO: 
        // 1. get & save files and info
        // 2. pkgutil forget
        // 3. reload package list
    }
    
    /// Switches the package list to list containing either Apple packages or no Apple packages
    /// - Parameter showApplePkg: show Apple packages, if true - otherwise without
    func showList(withApplePkgs showApplePkg: Bool) {
        if showApplePkg {
            pkgList = PkgUtil.pkgListApple
        } else {
            pkgList = PkgUtil.pkgListNonApple
        }
    }
    
    // MARK: - Getters & Setters to important vars
    
    func setCurrentPkg(pkg: String) {
        if currentPkg.id != pkg {
            currentPkg = PkgUtil.getInfoOfPkg(pkg)
            currentFilesPaths.removeAll()
            currentOnlyDirsPaths.removeAll()
            currentOnlyFilesPaths.removeAll()
            // TODO: Check needed?
            if showExistenceCheck {
                checkFileDirExistence()
            }
        }
    }
    
    func getAllPaths() -> [PkgPath] {
        if currentFilesPaths.isEmpty {
            currentFilesPaths = PkgUtil.getFilesOfPkg(currentPkg.id, fileMode: .fileAndDir)
        }
        if showExistenceCheck {
            checkFileDirExistence()
        }
        return currentFilesPaths
    }
    
    func getFiles() -> [PkgPath] {
        if currentOnlyFilesPaths.isEmpty {
            currentOnlyFilesPaths = PkgUtil.getFilesOfPkg(currentPkg.id, fileMode: .file)
        }
        if showExistenceCheck {
            checkFileDirExistence()
        }
        return currentOnlyFilesPaths
    }
    
    func getDirs() -> [PkgPath] {
        if currentOnlyDirsPaths.isEmpty {
            currentOnlyDirsPaths = PkgUtil.getFilesOfPkg(currentPkg.id, fileMode: .dir)
        }
        if showExistenceCheck {
            checkFileDirExistence()
        }
        return currentOnlyDirsPaths
    }
    
    
    // MARK: - Old approach taking plist as reading pkg list -> quite slow

//    /// Checks if the files / dirs for the currentPkg exists
//    /// Updates var currentPkg
//    /// - Parameter package: package to be checked
//    func checkFileDirExistence_Old() {
//        PkgUtil.checkFileDirExistence_Old(currentPkg: &currentPkg)
//        currentPaths = currentPkg.paths;
//    }
//
//    func setCurrentPkg_Old(pkg: String) throws {
//        if currentPkg.id != pkg {
//            currentPkg = try PkgUtil.readPkgAsPlist(of: pkg)
//            currentFilesPaths.removeAll()
//            currentOnlyDirsPaths.removeAll()
//            currentOnlyFilesPaths.removeAll()
//        }
//    }
//
//    func getAllPaths_Old() -> [PkgPath] {
//        currentPaths = currentPkg.paths
//        return currentPaths
//    }
//
//    func getFiles_Old() -> [PkgPath] {
//        currentPaths = currentPkg.paths.filter({ path in
//            path.mode == .file || path.mode == .link || path.mode == .exe
//        })
//        return currentPaths
//    }
//
//    func getDirs_Old() -> [PkgPath] {
//        currentPaths = currentPkg.paths.filter({ path in
//            path.mode == .dir
//        })
//        return currentPaths
//    }
    
}

