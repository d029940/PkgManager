//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgInfoView: View {
    let pkgDesciption: String
    
    var body: some View {
        Text(pkgDesciption)
    }
}

struct PkgInfoView_Previews: PreviewProvider {
    static let vm = PkgUtilVm()
    
    static var previews: some View {
        vm.setCurrentPkg(pkg: vm.pkgList[2])
        return PkgInfoView(pkgDesciption: vm.getPkgDescription)
    }
}
 
