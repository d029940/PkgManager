//
//  PkgFilesView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgFilesView: View {
    // MARK: - State vars
    @EnvironmentObject var vm: PkgUtil
    @State private var showExistence: Bool = false
    
    // MARK: - local vars
    let viewContent: InfoFilesStates
    
    // MARK: - view
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
                        Label {
                            Text(entry.path)
                        }
                    icon: {
                        Image(systemName: "checkmark.square")
                    }
                    .accentColor(/*@START_MENU_TOKEN@*/.green/*@END_MENU_TOKEN@*/)
                        
                    } else {
                        Label {
                            Text(entry.path)
                        }
                    icon: {
                        Image(systemName: "multiply.circle")
                    }
                    .accentColor(.red)
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

// MARK: - Preview

struct PkgFilesView_Previews: PreviewProvider {
    static var previews: some View {
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgFilesView(viewContent: .filesAndDirs)
        .environmentObject(pkgUtil)
    }
}
