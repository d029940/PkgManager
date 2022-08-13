//
//  ContentView.swift
//  PackageManager
//
//  Created by Manfred on 08.08.22.
//

import SwiftUI

enum ApplePackagesButtonText: String {
    case hide = "Hide Apple Packages"
    case show = "Show Apple Packages"
}

enum InfoFilesButtonText: String {
    case files = "Files"
    case info = "Info"
}


struct ContentView: View {
    @StateObject var vm = PkgUtil()
    @State private var hideApplePkg = true
    @State private var buttonPkgText = ApplePackagesButtonText.show.rawValue
    
    @State private var infoView = true
    @State private var buttonInfoText = InfoFilesButtonText.files.rawValue

    
    var body: some View {
    
        VStack {
            NavigationView {
                List(vm.pkgList, id: \.self) {pkg in
                    NavigationLink(pkg) {
                        PkgDetailsView(pkg: pkg, infoView: $infoView)
                    }

                }
                .navigationTitle("Result from pkgutil")
                
                Text("Pkgutil result")
            }
            HStack {
                Button(buttonPkgText) {
                    if hideApplePkg == true {
                        hideApplePkg = false
                        buttonPkgText = ApplePackagesButtonText.hide.rawValue
                        vm.getPkgList()
                    } else {
                        hideApplePkg = true
                        buttonPkgText = ApplePackagesButtonText.show.rawValue
                        vm.getPkgList()
                        vm.hideApplePkgs()
                    }
                }
                Spacer()
                Button(buttonInfoText) {
                    if infoView == true {
                        infoView = false
                        buttonInfoText = InfoFilesButtonText.info.rawValue
                    } else {
                        infoView = true
                        buttonInfoText = InfoFilesButtonText.files.rawValue
                    }
                }
                Button("Show Package List") {
                    vm.getPkgList()
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(PkgUtil())
    }
}
