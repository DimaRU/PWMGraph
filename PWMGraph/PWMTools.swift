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

class PWMCoeffNEQ: PWMToolProtocol {
    let topMargin: UInt32 = 2
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
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

class PWMCoeff: PWMToolProtocol {
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)

        let warm = tempCoeff * brightnessCoeff / PWMBase
        let cold = (PWMBase - tempCoeff) * brightnessCoeff / PWMBase
        return (warm, cold)
    }
}


class PWMCoeffOld: PWMToolProtocol {
    let topMargin: UInt32 = 2
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warm: UInt32, cold: UInt32) {
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
