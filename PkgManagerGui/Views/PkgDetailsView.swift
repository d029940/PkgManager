//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgDetailsView: View {
    let pkg: String
    @EnvironmentObject var vm: PkgUtil
    @Binding var infoView: Bool
    
    var body: some View {
        VStack {
            if infoView == true {
                PkgInfoView(pkg: pkg)
            } else {
                PkgFilesView(pkg: pkg)
            }
        }
    }
}


struct PkgDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var infoView = true
        return PkgDetailsView(pkg: "com.apple.pkg.XProtectPayloads_10_15.16U4204",
        infoView: $infoView)
            .environmentObject(PkgUtil())
    }
}
