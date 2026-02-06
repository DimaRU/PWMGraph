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
    
    @State var selection: PWMFuncSelection = .nequal
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Picker("Coeff func", selection: $selection) {
                    Text("\(PWMFuncSelection.nequal.title)").tag(PWMFuncSelection.nequal)
                    Text("\(PWMFuncSelection.equal.title)").tag(PWMFuncSelection.equal)
                }
                .pickerStyle(.segmented)
                Spacer()
                NavigationLink {
                    switch selection {
                    case .nequal:
                        PWMSurface(PWMTool: PWMCoeffNEQ())
                    case .equal:
                        PWMSurface(PWMTool: PWMCoeff())
                    }
                } label: {
                    Text("3D Chart")
                }
                NavigationLink {
                    switch selection {
                    case .nequal:
                        PWMLineLollipop(PWMTool: PWMCoeffNEQ())
                    case .equal:
                        PWMLineLollipop(PWMTool: PWMCoeff())
                    }
                } label: {
                    Text("2D Chart")
                }
                
                Spacer()

            }
            .font(.title.bold())
        }
    }
}

#Preview {
    ContentView()
}
