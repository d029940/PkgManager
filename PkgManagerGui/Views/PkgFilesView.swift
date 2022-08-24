//
//  PkgFilesView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgFilesView: View {
    @EnvironmentObject var vm: PkgUtil
    @State private var showExistence: Bool = false
    let viewContent: InfoFilesStates
    var body: some View {
        if showExistence {
            // Files / dirs from package already read with pkgutil.
            // Now only check those files/dirs if they exist
            vm.checkFileDirExistence()
        } else {
            switch viewContent {
            case .files:
                vm.getFiles()
            case .dirs:
                vm.getDirs()
            default:
                vm.getAllPaths()
            }
        }

        return VStack {
            List($vm.currentPkg.paths, id: \.id) {$entry in
                if showExistence {
                    if entry.exists {
                        Label(entry.path, systemImage: "checkmark.square")
                    } else {
                        Label(entry.path, systemImage: "multiply.circle")
                    }
                } else {
                    Text(entry.path)
                }
            }
            Spacer()
            Toggle("Check Existence", isOn: $showExistence)
        }
    }
}

struct PkgFilesView_Previews: PreviewProvider {
    static var previews: some View {
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgFilesView(viewContent: .filesAndDirs)
        .environmentObject(pkgUtil)
    }
}
