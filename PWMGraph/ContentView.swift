//
//  ContentView.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 29/01/2026.
//

import SwiftUI

struct ContentView: View {
    enum PWMFuncSelection {
        case nequal, equal
        var title: String {
            return switch self {
            case .nequal: "nequal"
            case .equal: "equal"
            }
        }
    }
    
    @State private var selection: PWMFuncSelection = .nequal
    @State private var cie1931: Bool = false
    
    var body: some View {
        NavigationSplitView {
            Text("Coeff func")
                .font(.title3.bold())
            Picker(selection: $selection) {
                Text("\(PWMFuncSelection.nequal.title)").tag(PWMFuncSelection.nequal)
                Text("\(PWMFuncSelection.equal.title)").tag(PWMFuncSelection.equal)
            } label: {
                EmptyView()
            }
            .pickerStyle(.segmented)
            
            Toggle(isOn: $cie1931) {
                Text("cie1931")
            }
            
            Spacer()
            NavigationLink {
                switch (selection, cie1931) {
                case (.nequal, false): PWMSurface(PWMTool: PWMCoeffNEQ())
                case (.nequal, true):  PWMSurface(PWMTool: PWMCoeffNEQ_cie1931())
                case (.equal, false):  PWMSurface(PWMTool: PWMCoeff())
                case (.equal, true):   PWMSurface(PWMTool: PWMCoeff_cie1931())
                }
            } label: {
                Text("3D Chart")
            }
            NavigationLink {
                switch (selection, cie1931) {
                case (.nequal, false): PWMLineLollipop(PWMTool: PWMCoeffNEQ())
                case (.nequal, true):  PWMLineLollipop(PWMTool: PWMCoeffNEQ_cie1931())
                case (.equal, false):  PWMLineLollipop(PWMTool: PWMCoeff())
                case (.equal, true):   PWMLineLollipop(PWMTool: PWMCoeff_cie1931())
                }
            } label: {
                Text("2D Chart")
            }
            Spacer()
        } detail: {
        }

    }
}

#Preview("ContentView", traits: .fixedLayout(width: 700, height: 500)) {
    ContentView()
}
