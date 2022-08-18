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
    let viewContent: InfoFilesStates
    var body: some View {
        switch viewContent {
        case .files:
            vm.getPkgFiles(of: pkg)
        case .dirs:
            vm.getPkgDirs(of: pkg)
        default:
            vm.getPkgFilesDirs(of: pkg)
        }

        return List(vm.pkgFilesDirs, id: \.self) {entry in
            HStack {
                Label(entry, systemImage: "multiply.circle")
                // and "checkmark.square"
            }
        }
    }
}

struct PkgFilesView_Previews: PreviewProvider {
    static var previews: some View {
        PkgFilesView(pkg: "com.apple.pkg.XProtectPayloads_10_15.16U4204",
                     viewContent: .filesAndDirs)
        .environmentObject(PkgUtil())
    }
}
