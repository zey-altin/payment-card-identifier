//
//  LuhnValidator.swift
//  card-identifier
//
//  Created by Zeynep Nur Altın
//

import UIKit


//0-> Invalid Card
//1-> Valid Card
public class LuhnValidator {
    
    static func isValid(cardNumber: String) -> Bool {
        let digits = cardNumber.compactMap { $0.wholeNumberValue }
        let checksum = digits.reversed().enumerated().reduce(0) { sum, pair in
            let (index, digit) = pair
            if index % 2 == 1 {
                return sum + (digit * 2 > 9 ? digit * 2 - 9 : digit * 2)
            } else {
                return sum + digit
            }
        }
        return checksum % 10 == 0
    }
}
