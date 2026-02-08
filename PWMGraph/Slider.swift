//
//  Slider.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 02/02/2026.
//

import SwiftUI


struct TemperatureSlider: View {
    @Binding var mireds: Float
    
    var body: some View {
        VStack {
            Slider(
                value: $mireds,
                in: Float(MiredsCold)...Float(MiredsWarm),
                neutralValue: Float(MiredsCold) + Float(MiredsWarm - MiredsCold) / 2
            ) {
                EmptyView()
            } currentValueLabel: {
                Text("Temp: \(UInt16(mireds.rounded(.down)))")
            } minimumValueLabel: {
                Text("\(kelvinS(Float(MiredsCold)))")
            } maximumValueLabel: {
                Text("\(kelvinS(Float(MiredsWarm)))")
            } ticks: {
                SliderTickContentForEach(
                    stride(from: 0.0, through: 1.0, by: 0.05).map { Float($0) },
                    id: \.self
                ) { v in
                    let position = Float(MiredsCold) + v * Float(MiredsWarm - MiredsCold)
                    SliderTick(position) {
                        Text("\(UInt16(position.rounded(.down)))")
                            .font(.caption)
                            .foregroundStyle(v == 0.5 ? .red : .primary)
                    }
                }
            }
            
            Text("Temp: \(kelvinS(mireds)) / \(UInt16(mireds.rounded(.down))) m")
        }
    }
    
    nonisolated func kelvin(_ mireds: Float) -> UInt32 {
        1_000_000/UInt32(mireds)
    }
    
    nonisolated func kelvinS(_ mireds: Float) -> String {
        "\(kelvin(mireds).formatted(.number.grouping(.never)))K"
    }
}
