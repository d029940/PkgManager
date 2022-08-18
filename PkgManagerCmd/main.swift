//
//  main.swift
//  Pkg_Manager
//
//  Created by Manfred on 06.08.22.
//

import Foundation

var pkgutil = PkgUtil()
//pkgutil.getPkgList()
//print(pkgutil.pkgList)
//print("PkgList count \(pkgutil.pkgList.count)")
pkgutil.hideApplePkgs()
//print("PkgList count \(pkgutil.pkgList.count)")
print(pkgutil.pkgList)
//pkgutil.getPkgGroups()
//print(pkgutil.pkgGroups)
pkgutil.getPkgFilesDirs(of: pkgutil.pkgList[3])
//pkgutil.getPkgDirs(of: pkgutil.pkgList[3])
print(pkgutil.pkgFilesDirs)
try? pkgutil.checkFileDirExistence(of: pkgutil.pkgList[3])
try? pkgutil.readPkgInfoAsLines(of: pkgutil.pkgList[3])
print(pkgutil.pkgFilesDirsExistence)
pkgutil.getPkgDirs(of: pkgutil.pkgList[3])
print(pkgutil.pkgFilesDirs)
try? pkgutil.checkFileDirExistence(of: pkgutil.pkgList[3])
try? pkgutil.readPkgInfoAsLines(of: pkgutil.pkgList[3])
print(pkgutil.pkgFilesDirsExistence)
print("Number of file/dirs = \(pkgutil.pkgFilesDirs.count), Number of filedir checks = \(pkgutil.pkgFilesDirsExistence.count)")

print("end")








