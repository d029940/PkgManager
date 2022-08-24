//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI


struct PkgDetailsView: View {
    let pkg: String
    @EnvironmentObject var vm: PkgUtil
    @State private var infoFilesState = InfoFilesStates.info
    
    var body: some View {
        if pkg != vm.currentPkg.id {
            try? vm.readPkgAsPlist(of: pkg) // TODO: error
        }
        return VStack {
            Spacer()
            switch infoFilesState {
            case .info:
                PkgInfoView()
            default:
                PkgFilesView(viewContent: infoFilesState)
            }
            Spacer()
            Picker("Details:", selection: $infoFilesState) {
                ForEach(InfoFilesStates.allCases) { state in
                    Text(state.buttonText)
                }
            }
            .pickerStyle(.segmented)
        }
    }
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


struct PkgDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var infoView: InfoFilesStates = .info
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgDetailsView(pkg: "com.amazon.Kindle")
            .environmentObject(pkgUtil)
    }
}
