//
//  cie1931.swift
//  PWMGraph
//
//  Created by Dmitriy Borovikov on 06/02/2026.
//

import Foundation

//CIE 1931 lightness
nonisolated func cie1931(lightness l: Double) -> Double {
    if l <= 0.08 {
        return l / 9.033
    } else {
        return pow(((l + 0.16) / 1.16), 3)
    }
}
