//
//  main.swift
//  Pkg_Manager
//
//  Created by Manfred on 06.08.22.
//

import Foundation

var pkgutilvm = PkgUtilVm()

print(pkgutilvm.pkgListNonApple)
let pkg = pkgutilvm.pkgListNonApple[2]
try! pkgutilvm.setCurrentPkg(pkg: pkg)
print(pkgutilvm.getAllPaths())

print("end")








