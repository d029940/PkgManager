//
//  PkgUtilCmd.swift
//  PkgManager
//
//  Created by Manfred on 19.09.22.
//

import Foundation


/// Error  thrown by pkgutil system command
enum PkgUtilError: Error {
    case pkgUtilCmdFailed(errorno: Int32)
    case noPackages
    case noPathsForPackage(package: String)
}

struct PkgUtilCmd {
    
    private static let pkgCmd = "/usr/sbin/pkgutil"
    
    /// call pkgutil command line tool
    /// - Parameter args: for pkgutil
    /// - Throws: PkgUtilErrors.pkgUtilCmdFailed (pkgutil call failed (returns non-null))
    /// - Returns: Info as a string
    static func pkgutil(args: String...) throws -> String {
        let outputPipe = Pipe()
        let task = Process()
        task.launchPath = pkgCmd
        task.arguments = args
        task.standardOutput = outputPipe
        if let _ = try? task.run() {
            let data = outputPipe.fileHandleForReading.readDataToEndOfFile()
            return String(decoding: data, as: UTF8.self)
        } else {
            throw PkgUtilError.pkgUtilCmdFailed(errorno: task.terminationStatus)
        }
    }
    
}
