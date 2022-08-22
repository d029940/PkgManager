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

extension InfoFilesStates {
    var buttonText: String {
        switch self {
        case .info: return "Info"
        case .files: return "Only Files"
        case .dirs: return "Only Dirs"
        case .filesAndDirs: return "Files/Dirs"
        }
    }
}

struct ContentView: View {
    @StateObject var vm = PkgUtil()
    @State private var hideApplePkg = true
    @State private var buttonPkgText = ApplePackagesButtonText.show.rawValue
    
    @State private var infoFilesState = InfoFilesStates.info
    
    var body: some View {
    
        VStack {
            NavigationView {
                List(vm.pkgList, id: \.self) {pkg in
                    NavigationLink(pkg) {
                        PkgDetailsView(pkg: pkg, detailsView: $infoFilesState)
                    }

                }
                .navigationTitle("Result from pkgutil")
                
                Text("Pkgutil Output")
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
                
                Picker("Details:", selection: $infoFilesState) {
                    ForEach(InfoFilesStates.allCases) { state in
                        Text(state.buttonText)
                    }
                }
                .pickerStyle(.segmented)

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
        
        return ContentView().environmentObject(PkgUtil())
    }
}
