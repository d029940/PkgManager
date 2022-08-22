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
        try? vm.readPkgAsPlist(of: pkg)
         return VStack {
            switch detailsView {
            case .info:
                PkgInfoView()
            default:
                PkgFilesView(viewContent: detailsView)
            }
        }
    }
}


struct PkgDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var infoView: InfoFilesStates = .info
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgDetailsView(pkg: "com.amazon.Kindle",
        detailsView: $infoView)
            .environmentObject(pkgUtil)
    }
}
