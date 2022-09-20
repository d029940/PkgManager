//
//  main.swift
//  Pkg_Manager
//
//  Created by Manfred on 06.08.22.
//

import Foundation

var pkgutilvm = PkgUtilVm()

//pkgutil.getPkgList()

print(pkgutilvm.pkgListNonApple)
try! pkgutilvm.setCurrentPkg(pkg: pkgutilvm.pkgListApple[3])
print(pkgutilvm.getAllPaths())

print("end")








