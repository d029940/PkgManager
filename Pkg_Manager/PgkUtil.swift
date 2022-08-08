//
//  PgkUtil.swift
//  Pkg_Manager
//
//  Created by Manfred on 07.08.22.
//

import Foundation

typealias PkgUtilOutput = [String]

enum PkgUtilErrors: Error {
    case pkgUtilCmdFailed(errorno: Int32)
}

struct PkgUtil {
    private(set) var pkgList: PkgUtilOutput = []
    private(set) var pkgGroups: PkgUtilOutput = []
    private(set) var currentPkgFilesDirs: PkgUtilOutput = []
    private(set) var pkgFilesDirs: [PkgUtilOutput] = []
    
    private static let applePkgs = "com.apple.pkg" // Apple packages begin with com.apple.pkg (or com.apple)
    
    public init() {
        
    }
    
    /// Reading all packages
    /// sets the var pkgList
    mutating func getPkgList() {
        pkgList.removeAll()
        do {
            try pkgList = (pkgutil(args: "--pkgs"))
            pkgList.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("pkgutil return ocde: \(errorno)")
        } catch {
            fatalError("Unknown error")
        }
    }
    
    /// Reading all package groups
    /// sets the var pkgGroups
    mutating func getPkgGroups() {
        pkgGroups.removeAll()
        do {
            try pkgGroups = pkgutil(args: "--groups")
            pkgGroups.removeLast()
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("pkgutil return ocde: \(errorno)")
        } catch {
            fatalError("Unknown error")
        }
    }
    
    /// Getting all files and directories  of a given package
    /// sets the var currentPkgFilesDirs
    /// - Parameter package: package to inspect for files and directories
    mutating func getPkgFilesDirs(of package: String) {
        currentPkgFilesDirs.removeAll()
        do {
            try currentPkgFilesDirs = pkgutil(args: "--lsbom", package)
        } catch PkgUtilErrors.pkgUtilCmdFailed(let errorno) {
            print("pkgutil return ocde: \(errorno)")
        } catch {
            fatalError("Unknown error")
        }
    }
    
    /// Get files and directories of all packages
    mutating func getAllPkgFilesDirs() {
        pkgFilesDirs.removeAll()
        for pkg in pkgList {
            getPkgFilesDirs(of: pkg)
            pkgFilesDirs.append(currentPkgFilesDirs)
        }
    }
    
    /// removes all Apple packages from pkglist
    mutating func removeApplePkgs() {
        pkgList.removeAll { pkg in
            pkg.hasPrefix(PkgUtil.applePkgs) ? true : false
        }
    }
    
    /// call pkgutil command line tool
    /// throws an error if pkgutil returns non-null
    /// - Parameter args for pkgutil
    private mutating func pkgutil(args: String...) throws -> PkgUtilOutput {
        let outputPipe = Pipe()
        let task = Process()
        task.launchPath = "/usr/sbin/pkgutil"
        task.arguments = args
        task.standardOutput = outputPipe
        if let _ = try? task.run(){
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self).components(separatedBy: CharacterSet.newlines)
        }else{
            throw PkgUtilErrors.pkgUtilCmdFailed(errorno: task.terminationStatus)
        }
    }
    
}

