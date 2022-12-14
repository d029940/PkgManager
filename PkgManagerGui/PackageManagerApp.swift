//
//  PackageManagerApp.swift
//  PackageManager
//
//  Created by Manfred on 08.08.22.
//

import SwiftUI

@main
struct PackageManagerApp: App {
//    let pkgUtil = PkgUtilVm()
    @StateObject var pkgUtil = PkgUtilVm()

    var body: some Scene {
        WindowGroup {
            MainView()
                .environmentObject(pkgUtil)
        }
    }
}
