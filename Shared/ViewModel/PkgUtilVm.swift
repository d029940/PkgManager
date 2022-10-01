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
    
    @Published private(set) var pkgListNonApple = [String]()
    @Published private(set) var pkgListApple = [String]()
    @Published var showApplePkg = false
    @Published var showExistenceCheck = false
    @Published var showInfoFilesDirs = InfoFilesDirsState.info
    
    var currentPkg = PackageInfo()
    var currentPaths = [PkgPath]()
    
    var getPkgDescription: String {
        PkgExternalInfo.id.rawValue + currentPkg.id + "\n" +
        PkgExternalInfo.volume.rawValue + currentPkg.volume + "\n" +
        PkgExternalInfo.location.rawValue + currentPkg.installLocation + "\n" +
        PkgExternalInfo.time.rawValue + currentPkg.installTime.description
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
        pkgListApple.removeAll()
        pkgListNonApple.removeAll()
        PkgUtil.getPkgList()
        pkgListApple = PkgUtil.pkgListApple
        pkgListNonApple = PkgUtil.pkgListNonApple
    }
    
    // MARK: - Users intent(s)
    
    /// Checks if the files / dirs for the currentPkg exists
    /// Updates var currentPkg
    /// - Parameter package: package to be checked
    func checkFileDirExistence() {
        PkgUtil.checkFileDirExistence(currentPkg: &currentPkg)
        currentPaths = currentPkg.paths;
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
    
    // MARK: - Getters & Setters to important vars
    
    func setCurrentPkg(pkg: String) throws {
        currentPkg = try PkgUtil.readPkgAsPlist(of: pkg)
    }
    
    func getAllPaths() -> [PkgPath] {
        currentPaths = currentPkg.paths
        return currentPaths
    }
    
    func getFiles() -> [PkgPath] {
        currentPaths = currentPkg.paths.filter({ path in
            path.mode == .file || path.mode == .link || path.mode == .exe
        })
        return currentPaths
    }
    
    func getDirs() -> [PkgPath] {
        currentPaths = currentPkg.paths.filter({ path in
            path.mode == .dir
        })
        return currentPaths
    }
    
}

