//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgDetailsView: View {
    @EnvironmentObject var vm: PkgUtilVm
    
    // MARK: - local vars
    let pkg: String
    
    init(pkg: String) {
        self.pkg = pkg
    }
    
    var body: some View {
        vm.setCurrentPkg(pkg: pkg)
        return VStack {
            Spacer()
            switch vm.showInfoFilesDirs {
            case .info:
                PkgInfoView(pkgDesciption: vm.getPkgDescription)
            case .filesAndDirs:
                PkgFilesView(paths: vm.getAllPaths())
            case .dirs:
                PkgFilesView(paths: vm.getDirs())
            case .files:
                PkgFilesView(paths: vm.getFiles())
            }
            Spacer()
            Picker("Details:", selection: $vm.showInfoFilesDirs) {
                ForEach(InfoFilesDirsState.allCases) { state in
                    Text(state.buttonText)
                }
            }
            .pickerStyle(.segmented)
            .padding(.leading)
        }
    }
}

// MARK: - Extension helper

extension InfoFilesDirsState {
    var buttonText: String {
        switch self {
        case .info: return "Info"
        case .files: return "Only Files"
        case .dirs: return "Only Dirs"
        case .filesAndDirs: return "Files/Dirs"
        }
    }
}

// MARK: - preview
struct PkgDetailsView_Previews: PreviewProvider {
    static let vm = PkgUtilVm()
    static let pkg = vm.pkgList[2]

    static var previews: some View {
        vm.setCurrentPkg(pkg: pkg)
        return PkgDetailsView(pkg: pkg)
            .environmentObject(vm)
    }
}
