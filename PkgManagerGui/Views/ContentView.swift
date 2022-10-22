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
//                        .onChange(of: vm.showApplePkg) { newValue in
//                           
//                        }
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
            .frame(minWidth: 750, maxWidth: .infinity, minHeight: 450, maxHeight: .infinity)
            .padding()
    }
}

/// Lists the packages and provides search capabilities
struct ListOfPackagesView: View {

    let packageList: [String]
    @State private var searchText = ""
    
    var body: some View {
            List(searchResults, id: \.self) {pkg in
                NavigationLink(pkg) {
                    PkgDetailsView(pkg: pkg)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Result from pkgutil")
        }
    
    var searchResults: [String] {
        if searchText.isEmpty {
            return packageList
        } else {
            return packageList.filter { $0.contains(searchText) }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        return ContentView().environmentObject(PkgUtilVm())
    }
}

