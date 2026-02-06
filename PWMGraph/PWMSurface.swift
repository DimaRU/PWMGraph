//
//  PWMSurface.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 27/01/2026.
//

import SwiftUI
import Charts
import Spatial

struct PWMSurface: View {
    nonisolated let PWMTool: PWMToolProtocol
    @State private var pose : Chart3DPose = .default
    @State private var cameraProjection: Chart3DCameraProjection = .orthographic
    let scaleRange: [CGFloat] = [-0.6, 0.6]
    
    var body: some View {
        VStack {
            Chart3D {
                SurfacePlot(x: "brightness", y: "warm", z: "temp") { x, z in
                    let x1 = x > Double(BrigthnessMax) ? Double(BrigthnessMax) : x
                    guard check(x: x1, z: z) else { return .nan }
                    let (warm, _) = PWMTool.PWMCoeff(brightness: UInt8(x1.rounded(.down)), mireds: UInt16(z))
                    return Double(warm)
                }
                .foregroundStyle(.yellow)
                
                SurfacePlot(x: "brightness", y: "cold", z: "temp") { x, z in
                    let x1 = x > Double(BrigthnessMax) ? Double(BrigthnessMax) : x
                    guard check(x: x1, z: z) else { return .nan }
                    let (_, cold) = PWMTool.PWMCoeff(brightness: UInt8(x1.rounded(.down)), mireds: UInt16(z))
                    return Double(cold)
                }
                .foregroundStyle(.white)

                SurfacePlot(x: "brightness", y: "sum", z: "temp") { x, z in
                    let x1 = x > Double(BrigthnessMax) ? Double(BrigthnessMax) : x
                    guard check(x: x1, z: z) else { return .nan }
                    let (warm, cold) = PWMTool.PWMCoeff(brightness: UInt8(x1.rounded(.down)), mireds: UInt16(z))
                    return Double(warm + cold)
                }
                .foregroundStyle(.blue.opacity(0.6))
            }
            .chartXScale(domain: 0 ... 254, range: scaleRange)
            .chartZScale(domain: MiredsCold + 1 ... MiredsWarm - 1, range: scaleRange)
            .chartYScale(domain: 0 ... PWMTool.PWMSum, range: scaleRange)
            .chartXAxis {
                AxisMarks(values: [0, 64, 128, 192, 256]) {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartZAxis {
                AxisMarks {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            
            .chartYAxis {
                AxisMarks {
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel()
                }
            }
            .chartXAxisLabel("brightness")
            .chartYAxisLabel("PWM", position: .automatic, alignment: .center)
            .chartZAxisLabel("temp, mireds")
            .chart3DCameraProjection(cameraProjection)
            .chart3DPose($pose)
            .chartBackground { chartProxy in
                Color.black.opacity(0.1)
            }
            .aspectRatio(contentMode: .fit)

        }
        .ignoresSafeArea()
    }
    
    private nonisolated func check(x: Double, z: Double) -> Bool {
        if
            x >= 0,
            x.rounded(.down) <= Double(BrigthnessMax),
            UInt16(z) >= MiredsCold,
            UInt16(z) <= MiredsWarm
        {
            return true
        }
        return false
    }
    
}

#Preview("not equal", traits: .fixedLayout(width: 600, height: 500)) {
    PWMSurface(PWMTool: PWMCoeffNEQ())
}

#Preview("equal", traits: .fixedLayout(width: 600, height: 500)) {
    PWMSurface(PWMTool: PWMCoeff())
}
