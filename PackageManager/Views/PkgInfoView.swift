//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgInfoView: View {
    @EnvironmentObject var vm: PkgUtil
    let pkg: String
    
    var body: some View {
        guard let info = try? vm.readPkgInfoAsString(of: pkg) else {
            return Text("")
        }
        return Text(info)
    }
}

struct PkgInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PkgInfoView(pkg: "com.apple.pkg.XProtectPayloads_10_15.16U4204").environmentObject(PkgUtil())
    }
}
