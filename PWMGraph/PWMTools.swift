//
//  PWMTools.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 27/01/2026.
//

import Foundation


nonisolated let MiredsWarm: UInt16 = 333
nonisolated let MiredsCold: UInt16 = 153
nonisolated let BrigthnessMax: UInt8 = 254
nonisolated let BrigthnessMin: UInt8 = 0

protocol PWMToolProtocol: AnyObject {
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32)
    nonisolated var PWMBase: UInt32 { get }
    nonisolated var PWMSum: UInt32 { get }
}

nonisolated
class PWMCoeffNEQ: PWMToolProtocol {
    let topMargin: UInt32 = 2
    let PWMBase: UInt32 = 4096
    var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let miredsNeutral = (MiredsWarm + MiredsCold) / 2
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)
        
        if mireds >= miredsNeutral {
            let cold = topMargin * (PWMBase - tempCoeff) * brightnessCoeff / PWMBase
            return (brightnessCoeff, cold)
        } else {
            let warm = topMargin * tempCoeff * brightnessCoeff / PWMBase
            return (warm, brightnessCoeff)
        }
    }
}

nonisolated
class PWMCoeff: PWMToolProtocol {
    let PWMBase: UInt32 = 4096
    var PWMSum: UInt32 {
        PWMBase
    }
    
    func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)

        let warm = tempCoeff * brightnessCoeff / PWMBase
        let cold = (PWMBase - tempCoeff) * brightnessCoeff / PWMBase
        return (warm, cold)
    }
}

nonisolated
class PWMCoeffOld: PWMToolProtocol {
    let topMargin: UInt32 = 2
    let PWMBase: UInt32 = 4096
    var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let topMargin: UInt32 = 2
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold) * topMargin
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)

        var warm = tempCoeff * brightnessCoeff / PWMBase
        if warm > PWMBase {
            warm = PWMBase
        }
        var cold = (topMargin * PWMBase - tempCoeff) * brightnessCoeff / PWMBase
        if cold > PWMBase {
            cold = PWMBase
        }
        return (warm, cold)
    }
}

nonisolated
class PWMCoeffNEQ_cie1931: PWMToolProtocol {
    let topMargin: UInt32 = 2
    let PWMBase: UInt32 = 4096
    var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    private let lightnessBase: UInt32 = 2000
    private var cieTable: [UInt32] = []
    
    init() {
        for index in 0...lightnessBase {
            let lightness = Double(index) / Double(lightnessBase)
            let coeff = cie1931(lightness: lightness) * Double(PWMBase)
            cieTable.append(UInt32(coeff))
        }
    }
    
    func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let miredsNeutral = (MiredsWarm + MiredsCold) / 2
        let tempCoeff = UInt32(mireds - MiredsCold) * lightnessBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * lightnessBase / UInt32(BrigthnessMax)
        
        if mireds >= miredsNeutral {
            let cold = topMargin * (lightnessBase - tempCoeff) * brightnessCoeff / lightnessBase
            return (cieTable[Int(brightnessCoeff)], cieTable[Int(cold)])
        } else {
            let warm = topMargin * tempCoeff * brightnessCoeff / lightnessBase
            return (cieTable[Int(warm)], cieTable[Int(brightnessCoeff)])
        }
    }
}

nonisolated
class PWMCoeff_cie1931: PWMToolProtocol {
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase
    }
    
    private let lightnessBase: UInt32 = 2000
    private var cieTable: [UInt32] = []
    
    init() {
        for index in 0...lightnessBase {
            let lightness = Double(index) / Double(lightnessBase)
            let coeff = cie1931(lightness: lightness) * Double(PWMBase)
            cieTable.append(UInt32(coeff))
        }
    }

    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let tempCoeff = UInt32(mireds - MiredsCold) * lightnessBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * lightnessBase / UInt32(BrigthnessMax)

        let warm = tempCoeff * brightnessCoeff / lightnessBase
        let cold = (lightnessBase - tempCoeff) * brightnessCoeff / lightnessBase
        return (cieTable[Int(warm)], cieTable[Int(cold)])
    }
}

nonisolated
class PWMEQ_cie1931: PWMToolProtocol {
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase
    }
    
    private let precisionBase: UInt32 = 1000
    private var cieTable: [UInt32] = []
    
    init() {
        for index in 0...BrigthnessMax {
            let lightness = Double(index) / Double(BrigthnessMax)
            let coeff = cie1931(lightness: lightness) * Double(precisionBase)
            cieTable.append(UInt32(coeff))
        }
        print(cieTable)
    }

    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let tempCoeff = UInt32(mireds - MiredsCold) * precisionBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = cieTable[Int(brightness)]

        let warm = tempCoeff * brightnessCoeff / precisionBase * PWMBase / precisionBase
        let cold = (precisionBase - tempCoeff) * brightnessCoeff / precisionBase * PWMBase / precisionBase
        return (warm, cold)
    }
}
