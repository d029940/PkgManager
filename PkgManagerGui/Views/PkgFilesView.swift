//
//  PkgFilesView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgFilesView: View {
    @EnvironmentObject var vm: PkgUtil
    let pkg: String
    var body: some View {
        vm.getPkgFilesDirs(of: pkg)
        return List(vm.currentPkgFilesDirs, id: \.self) {entry in
            Text(entry)
        }
    }
}

struct PkgFilesView_Previews: PreviewProvider {
    static var previews: some View {
        PkgFilesView(pkg: "com.apple.pkg.XProtectPayloads_10_15.16U4204").environmentObject(PkgUtil())
    }
}
