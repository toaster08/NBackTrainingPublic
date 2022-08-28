//
//  Model.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/06/02.
//

import Foundation
import UIKit

enum PlusMinus: Int, CaseIterable {
    case plus = 0
    case minus
    
    var string: String {
        switch self {
        case .plus: return "＋"
        case .minus: return "ー"
        }
    }
    
    var calculation: (Int,Int) -> Int {
        switch self {
        case .plus:
            return (+)
        case .minus:
            return (-)
        }
    }
    
    static var random: Self {
        let randomeCase = Self.allCases.randomElement()
        return randomeCase!
    }
}

struct Problem {
    let plusMinus: PlusMinus
    let lhsNumber: Int
    let rhsNumber: Int
    
    var totalNumber: Int {
        plusMinus.calculation(lhsNumber, rhsNumber)
    }
    
    var expressionString: String {
        "\(lhsNumber) \(plusMinus.string) \(rhsNumber)"
    }
    
    init() {
        let plusMinus = PlusMinus.random
        let leftSideNumber = Int.random(in: 1...9)
        let rightSideNumber: Int = {
            switch plusMinus {
            case .plus:
                let rhsUpperNumber = 9 - leftSideNumber
                let rhsNumber = Int.random(in: 0...rhsUpperNumber)
                return rhsNumber
            case .minus:
                let rhsUpperNumber = leftSideNumber - 1
                let rhsNumber = Int.random(in: 0...rhsUpperNumber)
                return rhsNumber
            }
        }()
        
        self.plusMinus = plusMinus
        self.lhsNumber = leftSideNumber
        self.rhsNumber = rightSideNumber
    }
}
