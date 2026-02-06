//
//  PWMLineLollipop.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 27/01/2026.
//

import Charts
import SwiftUI


struct PWMLineLollipop: View {
    enum PWMChannel: String {
        case warm, cold, sum
        
        var color: Color {
            return switch self {
            case .warm: .yellow
            case .cold: .white
            case .sum: .mint
            }
        }
    }
    @State private var mireds: Float = Float(MiredsCold) + Float(MiredsWarm - MiredsCold) / 2
    @State private var showSymbols = false
    @State private var showLollipop = true
    @State private var lollipopColor: Color = .red
    @State private var lineWidth = 4.0
    @State private var selectedX: UInt8? = 128
    nonisolated let PWMTool: PWMToolProtocol

    let brigthnessRange = 0...BrigthnessMax

    var body: some View {
        VStack {
            chart
            TemperatureSlider(mireds: $mireds)
        }
        .padding()
        .background(Color.black.opacity(0.1))
    }
    
    
    private func getBaselineMarker(brightness: UInt8, mireds: UInt16, channel: PWMChannel) -> some ChartContent {
        let (warmCoeff, coldCoeff) = PWMTool.PWMCoeff(brightness: brightness, mireds: mireds)
        let coeff = switch channel {
        case .cold: coldCoeff
        case .warm: warmCoeff
        case .sum: coldCoeff + warmCoeff
        }
        return LineMark(
            x: .value("Brightness", brightness),
            y: .value("PWM", coeff),
            series: .value(channel.color.description, channel.color.description)
        )
        .lineStyle(StrokeStyle(lineWidth: lineWidth))
        .foregroundStyle(channel.color)
        .interpolationMethod(.linear)
        .symbolSize(showSymbols ? 60 : 0)
    }
    
    private var chart: some View {
        Chart {
            // Sum channel
            ForEach(brigthnessRange, id: \.self) { brigthness in
                let baselineMarker = getBaselineMarker(brightness: brigthness, mireds: UInt16(mireds.rounded(.down)), channel: .sum)
                if (selectedX == brigthness) && showLollipop {
                    baselineMarker.symbol() {
                        Circle().strokeBorder(.red, lineWidth: 2).background(Circle().foregroundColor(lollipopColor)).frame(width: 11)
                    }
                } else {
                    baselineMarker.symbol(Circle().strokeBorder(lineWidth: lineWidth))
                }
            }

            // Cold channel
            ForEach(brigthnessRange, id: \.self) { brigthness in
                let baselineMarker = getBaselineMarker(brightness: brigthness, mireds: UInt16(mireds.rounded(.down)), channel: .cold)
                if (selectedX == brigthness) && showLollipop {
                    baselineMarker.symbol() {
                        Circle().strokeBorder(.red, lineWidth: 2).background(Circle().foregroundColor(lollipopColor)).frame(width: 11)
                    }
                } else {
                    baselineMarker.symbol(Circle().strokeBorder(lineWidth: lineWidth))
                }
            }
            
            // Warm channel
            ForEach(brigthnessRange, id: \.self) { brigthness in
                let baselineMarker = getBaselineMarker(brightness: brigthness, mireds: UInt16(mireds.rounded(.down)), channel: .warm)
                if (selectedX == brigthness) && showLollipop {
                    baselineMarker.symbol() {
                        Circle().strokeBorder(.red, lineWidth: 2).background(Circle().foregroundColor(lollipopColor)).frame(width: 11)
                    }
                } else {
                    baselineMarker.symbol(Circle().strokeBorder(lineWidth: lineWidth))
                }
            }

        }
        .chartXScale(domain: brigthnessRange)
        .chartYScale(domain: [0, PWMTool.PWMSum])

        // Gesture lolipop
        .chartOverlay { proxy in
            GeometryReader { geo in
                Rectangle().fill(.clear).contentShape(Rectangle())
                    .gesture(
                        SpatialTapGesture()
                            .onEnded { value in
                                let element = findElement(location: value.location, proxy: proxy, geometry: geo)
                                if selectedX == element {
                                    // If tapping the same element, clear the selection.
                                    selectedX = nil
                                } else {
                                    selectedX = element
                                }
                            }
                            .exclusively(
                                before: DragGesture()
                                    .onChanged { value in
                                        selectedX = findElement(location: value.location, proxy: proxy, geometry: geo)
                                    }
                            )
                    )
            }
        }
        // Draw Lollipop
        .chartBackground { proxy in
            ZStack(alignment: .topLeading) {
                GeometryReader { geo in
                    if showLollipop,
                       let selectedX {
                        let startPositionX1 = proxy.position(forX: selectedX) ?? 0
                        
                        let lineX = startPositionX1 + geo[proxy.plotFrame!].origin.x
                        let lineHeight = geo[proxy.plotFrame!].maxY
                        let boxWidth: CGFloat = 180
                        let boxOffset = max(0, min(geo.size.width - boxWidth, lineX - boxWidth / 2))
                        let (warmCoeff, coldCoeff) = PWMTool.PWMCoeff(brightness: selectedX, mireds: UInt16(mireds.rounded(.down)))

                        Rectangle()
                            .fill(lollipopColor)
                            .frame(width: 2, height: lineHeight)
                            .position(x: lineX, y: lineHeight / 2)
                        
                        Grid(horizontalSpacing: 15) {
                            GridRow {
                                Text("b: \(selectedX)")
                                    .font(.title3.bold().monospaced())
                                    .foregroundColor(.primary)
                                    .gridColumnAlignment(.leading)
                                Text("warm:")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                    .gridColumnAlignment(.trailing)
                                Text("\(warmCoeff, format: .number)")
                                    .font(.callout.bold().monospacedDigit())
                                    .foregroundStyle(.secondary)
                                    .gridColumnAlignment(.trailing)
                            }
                            GridRow {
                                Text("t: \(UInt16(mireds.rounded(.down)))")
                                    .font(.title3.bold().monospaced())
                                    .foregroundColor(.primary)
                                Text("cold:")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("\(coldCoeff, format: .number)")
                                    .font(.callout.bold().monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            GridRow(alignment: .top) {
                                Text(" ")
                                    .font(.title3.bold())
                                    .foregroundColor(.primary)
                                Text("sum:")
                                    .font(.callout.bold())
                                    .foregroundStyle(.secondary)
                                Text("\(coldCoeff + warmCoeff, format: .number)")
                                    .font(.callout.bold().monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(width: boxWidth, alignment: .leading)
                        .background {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.background)
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.quaternary.opacity(0.2))
                            }
                            .padding(.horizontal, -8)
                            .padding(.vertical, -4)
                        }
                        .offset(x: boxOffset, y: 10)
                    }
                }
            }
        }
        .chartXAxis(.automatic)
        .chartYAxis(.automatic)
    }
    
    private func findElement(location: CGPoint, proxy: ChartProxy, geometry: GeometryProxy) -> UInt8? {
        let relativeXPosition = location.x - geometry[proxy.plotFrame!].origin.x
        guard
            let value = proxy.value(atX: relativeXPosition) as UInt32?,
            value <= BrigthnessMax
        else { return nil}
        return UInt8(value)
    }
}

#Preview("not equal", traits: .fixedLayout(width: 1000, height: 500)) {
    PWMLineLollipop(PWMTool: PWMCoeffNEQ())
}

#Preview("equal", traits: .fixedLayout(width: 1000, height: 500)) {
    PWMLineLollipop(PWMTool: PWMCoeff())
}
