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
    static var previews: some View {
        let vm = PkgUtilVm()
        vm.currentPkg = try! PkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgInfoView(pkgDesciption: vm.getPkgDescription)
    }
}
 
