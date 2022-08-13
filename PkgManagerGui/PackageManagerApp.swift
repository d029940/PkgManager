//
//  PackageManagerApp.swift
//  PackageManager
//
//  Created by Manfred on 08.08.22.
//

import SwiftUI

@main
struct PackageManagerApp: App {
    @StateObject var pkgUtil = PkgUtil()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(pkgUtil)
        }
    }
}
