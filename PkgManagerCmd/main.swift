//
//  main.swift
//  Pkg_Manager
//
//  Created by Manfred on 06.08.22.
//

import Foundation

var pkgutilvm = PkgUtilVm()

//print(pkgutilvm.pkgListNonApple)
let pkg = pkgutilvm.pkgListNonApple[2]
pkgutilvm.setCurrentPkg(pkg: pkg)
//print(pkgutilvm.getAllPaths())
print(PkgUtil.getFilesOfPkg(pkg, fileMode: .dir))
print(PkgUtil.getInfoOfPkg(pkg))
//PkgUtil.readPkg(pkg)

print("end")




