//
//  PkgInfoView.swift
//  PackageManager
//
//  Created by Manfred on 13.08.22.
//

import SwiftUI


struct PkgDetailsView: View {
    // MARK: - state vars
    @EnvironmentObject var vm: PkgUtil
    @State private var infoFilesState = InfoFilesStates.info
    
    // MARK: - local vars
    let pkg: String
    
    var body: some View {
        // Check if another packages has been selected
        if pkg != vm.currentPkg.id {
            do {
                try vm.readPkgAsPlist(of: pkg)
            } catch PkgUtilErrors.noPackages {
                print("\(PkgUtilsErrorMessages.unkownPackage.rawValue) \(pkg)")
            } catch {
                fatalError(PkgUtilsErrorMessages.unknownError.rawValue)
            }
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
            .padding(.leading)
        }
    }
}

// MARK: - Extension helper

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

// MARK: - preview
struct PkgDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        @State var infoView: InfoFilesStates = .info
        let pkgUtil = PkgUtil()
        try? pkgUtil.readPkgAsPlist(of: "com.amazon.Kindle")
        return PkgDetailsView(pkg: "com.amazon.Kindle")
            .environmentObject(pkgUtil)
    }
}
