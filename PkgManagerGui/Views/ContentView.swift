//
//  ContentView.swift
//  PackageManager
//
//  Created by Manfred on 08.08.22.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var vm: PkgUtilVm
//    @ObservedObject var vm: PkgUtilVm
    private let showAppleButtonText = "Show Apple Packages"
    
    var body: some View {
        return VStack {

            NavigationView {
                VStack {
                    // Check if Apple packages should also be listed
                    if (vm.showApplePkg) {
                        ListOfPackagesView(packageList: vm.pkgListApple)
                    } else {
                        ListOfPackagesView(packageList: vm.pkgListNonApple)
                    }
                    
                    Spacer()
                    
                    Toggle(showAppleButtonText, isOn: $vm.showApplePkg)
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

