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
    @StateObject var vm = PkgUtil()
    @State private var showApplePkg = false
//    @State private var buttonPkgText = ApplePackagesButtonText.show.rawValue
    private let showAppleButtonText = "Show Apple Packages"
    
    var body: some View {
        return VStack {

            NavigationView {
                VStack {
                    List(vm.pkgList, id: \.self) {pkg in
                        // Check if Apple packages should also be listed
                        if (showApplePkg) || (!showApplePkg && !vm.isApplePkg(pkg)) {
                            NavigationLink(pkg) {
                                PkgDetailsView(pkg: pkg)
                            }
                        }
                    }
                    .navigationTitle("Result from pkgutil")
                    
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(PkgUtil())
    }
}
