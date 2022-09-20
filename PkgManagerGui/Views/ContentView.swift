//
//  ContentView.swift
//  PackageManager
//
//  Created by Manfred on 08.08.22.
//

import SwiftUI
//
//enum ApplePackagesButtonText: String {
//    case hide = "Hide Apple Packages"
//    case show = "Show Apple Packages"
//}

enum InfoFilesStates: Identifiable, CaseIterable {
    case info, files, dirs, filesAndDirs
    var id: Self {self}
}

struct ContentView: View {
    @EnvironmentObject var vm: PkgUtilVm
    @State private var showApplePkg = false
//    @State private var buttonPkgText = ApplePackagesButtonText.show.rawValue
    private let showAppleButtonText = "Show Apple Packages"
    
    var body: some View {
        return VStack {

            NavigationView {
                VStack {
                    // Check if Apple packages should also be listed
                    if (showApplePkg) {
                        ListOfPackagesView(packageList: vm.pkgListApple)
                    } else {
                        ListOfPackagesView(packageList: vm.pkgListNonApple)
                    }
                    
                    Spacer()
                    
                    Toggle(showAppleButtonText, isOn: $showApplePkg)
//                    Button(buttonPkgText) {
//                        showApplePkg.toggle()
//                        if showApplePkg == true {
//                            buttonPkgText = ApplePackagesButtonText.hide.rawValue
//                        } else {
//                            buttonPkgText = ApplePackagesButtonText.show.rawValue
//                        }
//                    }
                }
                
                Text("Pkgutil Output")
            }
            .padding()
        }
    }
}

struct ListOfPackagesView: View {
    let packageList: [String]
    var body: some View {
        List(packageList, id: \.self) {pkg in
            NavigationLink(pkg) {
                // TODO: Just set currentPkg in view model
                PkgDetailsView(pkg: pkg)
            }
        }
        .navigationTitle("Result from pkgutil")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(PkgUtilVm())
    }
}

