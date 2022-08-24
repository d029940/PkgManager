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

enum InfoFilesStates: Identifiable, CaseIterable {
    case info, files, dirs, filesAndDirs
    var id: Self {self}
}



struct ContentView: View {
    @StateObject var vm = PkgUtil()
    @State private var hideApplePkg = true
    @State private var buttonPkgText = ApplePackagesButtonText.show.rawValue
    
    
    var body: some View {
//        vm.getPkgList()
//        if hideApplePkg {
//            vm.hideApplePkgs()
//        }
        return VStack {

            NavigationView {
                VStack {
                    List(vm.pkgList, id: \.self) {pkg in
                        NavigationLink(pkg) {
                             PkgDetailsView(pkg: pkg)
//                            detailsView(package: pkg)
                        }
                    }
                    .navigationTitle("Result from pkgutil")
                    
                    Spacer()
//                                    Toggle(buttonPkgText, isOn: $hideApplePkg)
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
                }
                
                Text("Pkgutil Output")
            }
//
//                Spacer()
//
//                Button("Show Package List") {
//                    vm.getPkgList()
//                }
            .padding()
        }
    }
    
    func detailsView(package: String) -> PkgDetailsView {
        vm.getPkgList()
        if hideApplePkg {
            vm.hideApplePkgs()
        }
        return PkgDetailsView(pkg: package)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(PkgUtil())
    }
}
