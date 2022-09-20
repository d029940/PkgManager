//
//  PkgFilesView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI

struct PkgFilesView: View {
    // MARK: - State vars
    @EnvironmentObject var vm: PkgUtilVm
    
    // MARK: - parameters
    var paths: [PkgPath]
    
    // MARK: - view
    var body: some View {
        
        return VStack {
            List(paths, id: \.id) {entry in
                PkgItem(pkgPath: entry, showExistence: vm.showExistenceCheck)
                    .contextMenu {
                        Button {
                            print("\(vm.currentPkg.volume)\(vm.currentPkg.installLocation)/\(entry)")
                            
                        } label: {
                            Label("Menu", systemImage: "viewfinder")
                        }
                    }
            }
            
            Spacer()
            Toggle("Check Existence", isOn: $vm.showExistenceCheck)
            
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
        let vm = PkgUtilVm()
        let pkginfo = try! PkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgFilesView(paths: pkginfo.paths)
        .environmentObject(vm)
    }
}
