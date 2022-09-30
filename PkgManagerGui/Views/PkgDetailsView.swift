//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

// TODO: Implement --forget

struct PkgDetailsView: View {
    @EnvironmentObject var vm: PkgUtilVm
    
    // MARK: - local vars
    let pkg: String
    
    var body: some View {
        // Check if another packages has been selected
        // TODO: this should be put into the view model. The currentPkg should be observed
        if pkg != vm.currentPkg.id {
            do {
                try vm.setCurrentPkg(pkg: pkg)
            } catch PkgUtilError.noPackages {
                print("\(PkgUtilsErrorMessage.unkownPackage.rawValue) \(pkg)")
            } catch {
                fatalError(PkgUtilsErrorMessage.unknownError.rawValue)
            }
        }
        if vm.showExistenceCheck {
            // Files / dirs from package already read with pkgutil.
            // Now only check those files/dirs if they exist
            vm.checkFileDirExistence()
        }
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
    static var previews: some View {
        let vm = PkgUtilVm()
        try! vm.setCurrentPkg(pkg: "com.amazon.Kindle")
        return PkgDetailsView(pkg: "com.amazon.Kindle")
            .environmentObject(vm)
    }
}
