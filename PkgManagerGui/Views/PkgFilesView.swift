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
    
    // MARK: - parameters
    @Binding var showExistence: Bool
    var paths: [PkgPath]
    
    // MARK: - view
    var body: some View {
        
        return VStack {
            List(paths, id: \.id) {entry in
                PkgItem(pkgPath: entry, showExistence: showExistence)
                    .contextMenu {
                        Button {
                            print("\(vm.currentPkg.volume)\(vm.currentPkg.installLocation)/\(entry)")
                            
                        } label: {
                            Label("Menu", systemImage: "viewfinder")
                        }
                    }
            }
            
            Spacer()
            Toggle("Check Existence", isOn: $showExistence)
            
        }
    }
}

// MARK: - helper view
/// Shows a single File / Dir path
struct PkgItem: View {
    let pkgPath: PkgPath
    let showExistence: Bool

    var body: some View {
        if showExistence {
            if pkgPath.exists {
                Label {
                    Text(pkgPath.path)
                }
            icon: {
                Image(systemName: "checkmark.square")
            }
            .accentColor(/*@START_MENU_TOKEN@*/.green/*@END_MENU_TOKEN@*/)
            }
            else {
                Label {
                    Text(pkgPath.path)
                }
            icon: {
                Image(systemName: "multiply.circle")
            }
            .accentColor(.red)
            }
        } else {
            Text(pkgPath.path)
        }
    }
}


// MARK: - Preview

struct PkgFilesView_Previews: PreviewProvider {
    static var previews: some View {
        let pkgUtil = PkgUtil()
        @State var showPresent: Bool = true
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgFilesView(showExistence: $showPresent, paths: pkgUtil.currentPkg.paths)
        .environmentObject(pkgUtil)
    }
}
