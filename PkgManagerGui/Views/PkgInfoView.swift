//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgInfoView: View {
    @EnvironmentObject var vm: PkgUtil
    
    var body: some View {
        Text(vm.getPkgDescription)
    }
}

struct PkgInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgInfoView().environmentObject(pkgUtil)
    }
}
