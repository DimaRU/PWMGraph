//
//  ContentView.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 29/01/2026.
//

import SwiftUI

struct ContentView: View {
    enum PWMFuncSelection: CaseIterable {
        case nequal, equal, nequal_cie1931, equal_cie1931, equal1_cie1931
        var title: String {
            return switch self {
            case .nequal: "nonequal"
            case .equal: "equal"
            case .nequal_cie1931: "nequal-cie1931"
            case .equal_cie1931: "equal-cie1931"
            case .equal1_cie1931: "equal1-cie1931"
            }
        }
        
        var tool: PWMToolProtocol {
            switch self {
            case .nequal: PWMCoeffNEQ()
            case .equal: PWMCoeff()
            case .nequal_cie1931: PWMCoeffNEQ_cie1931()
            case .equal_cie1931: PWMCoeff_cie1931()
            case .equal1_cie1931: PWMEQ_cie1931()
            }
        }
    }
    
    @State private var selection: PWMFuncSelection = .nequal
    
    var body: some View {
        NavigationSplitView {
            Text("Coeff func")
                .font(.title3.bold())
            Picker(selection: $selection) {
                ForEach(PWMFuncSelection.allCases, id: \.self) { pwmTool in
                    Text(pwmTool.title).tag(pwmTool)
                }
            } label: {
                EmptyView()
            }
            .pickerStyle(.radioGroup)
            
            
            Spacer()
            NavigationLink {
                PWMLineLollipop(PWMTool: selection.tool)
            } label: {
                Text("2D Chart")
                    .font(.title3.bold())
            }
            NavigationLink {
                PWMSurface(PWMTool: selection.tool)
            } label: {
                Text("3D Chart")
                    .font(.title3.bold())
            }
            Spacer()
        } detail: {
        }

    }
}

#Preview("ContentView", traits: .fixedLayout(width: 800, height: 500)) {
    ContentView()
}
