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
    @Binding var detailsView: InfoFilesStates
    
    var body: some View {
        VStack {
            switch detailsView {
            case .info:
                PkgInfoView(pkg: pkg)
            default:
                PkgFilesView(pkg: pkg, viewContent: detailsView)
            }
        }
    }
}


struct PkgDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var infoView: InfoFilesStates = .info
        return PkgDetailsView(pkg: "com.apple.pkg.XProtectPayloads_10_15.16U4204",
        detailsView: $infoView)
            .environmentObject(PkgUtil())
    }
}
