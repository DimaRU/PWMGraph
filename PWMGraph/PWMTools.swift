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
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warmCoeff: UInt32, coolCoeff: UInt32)
    nonisolated var PWMBase: UInt32 { get }
    nonisolated var PWMSum: UInt32 { get }
}

class PWMCoeffNEQ: PWMToolProtocol {
    let topMargin: UInt32 = 2
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warmCoeff: UInt32, coolCoeff: UInt32) {
        let miredsNeutral = (MiredsWarm + MiredsCold) / 2
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)
        
        if mireds >= miredsNeutral {
            let coldCoeff = topMargin * (PWMBase - tempCoeff) * brightnessCoeff / PWMBase
            return (brightnessCoeff, coldCoeff)
        } else {
            let warmCoeff = topMargin * tempCoeff * brightnessCoeff / PWMBase
            return (warmCoeff, brightnessCoeff)
        }
    }
}

class PWMCoeff: PWMToolProtocol {
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warmCoeff: UInt32, coolCoeff: UInt32) {
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold)
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)

        let warmCoeff = tempCoeff * brightnessCoeff / PWMBase
        let coldCoeff = (PWMBase - tempCoeff) * brightnessCoeff / PWMBase
        return (warmCoeff, coldCoeff)
    }
}


class PWMCoeffOld: PWMToolProtocol {
    let topMargin: UInt32 = 2
    nonisolated let PWMBase: UInt32 = 4096
    nonisolated var PWMSum: UInt32 {
        PWMBase * topMargin
    }
    
    nonisolated func PWMCoeff(brightness: UInt8, mireds: UInt16) -> (warmCoeff: UInt32, coolCoeff: UInt32) {
        let topMargin: UInt32 = 2
        let tempCoeff = UInt32(mireds - MiredsCold) * PWMBase / UInt32(MiredsWarm - MiredsCold) * topMargin
        let brightnessCoeff = UInt32(brightness) * PWMBase / UInt32(BrigthnessMax)

        var warmCoeff = tempCoeff * brightnessCoeff / PWMBase
        if warmCoeff > PWMBase {
            warmCoeff = PWMBase
        }
        var coldCoeff = (topMargin * PWMBase - tempCoeff) * brightnessCoeff / PWMBase
        if coldCoeff > PWMBase {
            coldCoeff = PWMBase
        }
        return (warmCoeff, coldCoeff)
    }
}
