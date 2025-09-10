//
//  Ingredient.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import SwiftUI
import Foundation

struct Ingredient: Identifiable, Hashable, Equatable {
    var id = UUID()
    var isChecked: Bool = false
    var text: String = ""
}

func fractionsList() -> [String] {
    return ["¼","½","¾","⅓","⅔","⅙","⅚","⅛","⅜","⅝","⅞"]
}

//func floatToFraction(num: Float) -> String {
//    if num.isApproximately(1.0/3.0) {
//        return "⅓"
//    } else if num.isApproximately(2.0/3.0) {
//        return "⅔"
//    } else if num.isApproximately(0.5) {
//        return "½"
//    } else if num.isApproximately(0.25) {
//        return "¼"
//    } else if num.isApproximately(0.75) {
//        return "¾"
//    } else if num.isApproximately(0.125) {
//        return "⅛"
//    } else if num.isApproximately(0.375) {
//        return "⅜"
//    } else if num.isApproximately(0.625) {
//        return "⅝"
//    } else if num.isApproximately(0.875) {
//        return "⅞"
//    } else if num.isApproximately(1.0/6.0) {
//        return "⅙"
//    } else if num.isApproximately(5.0/6.0) {
//        return "⅚"
//    } else {
//        return String(format: "%.2f", num)
//    }
//}

func fractionToFloat(fraction: String) -> Float {
    switch fraction {
    case "¼":
        return 0.25
    case "½":
        return 0.5
    case "¾":
        return 0.75
    case "⅓":
        return 1.0/3.0
    case "⅔":
        return 2.0/3.0
    case "⅙":
        return 1.0/6.0
    case "⅚":
        return 5.0/6.0
    case "⅛":
        return 0.125
    case "⅜":
        return 0.375
    case "⅝":
        return 0.625
    case "⅞":
        return 0.875
    default:
        return 0
    }
}

func scaleQuantities(in input: String, by factor: Double) -> String {
    let pattern = #"""
        (?x)
        (                 # number token
              \d+\s+\d+/\d+   # mixed number: 1 1/2
            |
              \d+\s*/\s*\d+   # fraction like 1/2
            |
              \d+(?:\.\d+)?   # int/decimal like 2 or 0.5
        )
        """#
    
    let regex = try! NSRegularExpression(pattern: pattern, options: [])
    var result = input
    var delta = 0
    
    let nsInput = input as NSString
    let matches = regex.matches(in: input, range: NSRange(location: 0, length: nsInput.length))
    
    for m in matches {
        let r = NSRange(location: m.range.location + delta, length: m.range.length)
        let current = (result as NSString).substring(with: r)
        
        guard let value = parseNumber(from: current) else { continue }
        
        let newVal = value * factor
        let replacement = formatNumber(newVal)
        
        result = (result as NSString).replacingCharacters(in: r, with: replacement)
        delta += replacement.count - r.length
    }
    return result
}

private func parseNumber(from token: String) -> Double? {
    let parts = token.split(separator: " ")
    if parts.count == 2, let whole = Double(parts[0]) { // mixed number
        let fracParts = parts[1].split(separator: "/")
        if fracParts.count == 2,
           let num = Double(fracParts[0]),
           let den = Double(fracParts[1]), den != 0 {
            return whole + (num / den)
        }
    }
    if token.contains("/") { // pure fraction
        let fracParts = token.split(separator: "/")
        if fracParts.count == 2,
           let num = Double(fracParts[0]),
           let den = Double(fracParts[1]), den != 0 {
            return num / den
        }
    }
    return Double(token) // int or decimal
}

private func formatNumber(_ x: Double) -> String {
    var unicodeFractions: [(Double, String)] = [
           (0.125, "⅛"),
           (0.1666, "⅙"),
           (0.25, "¼"),
           (0.3333, "⅓"),
           (0.375, "⅜"),
           (0.5,  "½"),
           (0.625, "⅝"),
           (0.6666, "⅔"),
           (0.75, "¾"),
           (0.8333, "⅚"),
           (0.875, "⅞")
    ]
       
    let whole = Int(floor(x))
    let frac = x - Double(whole)
    
   
    // Find closest unicode fraction within tolerance
    let tolerance = 0.05
    if let (val, symbol) = unicodeFractions.min(by: {
        abs(frac - $0.0) < abs(frac - $1.0)
     }), abs(frac - val) < tolerance {
        if whole == 0 {
            return symbol
        } else {
            return "\(whole) \(symbol)"
        }
    }
     
     let f = NumberFormatter()
     f.minimumIntegerDigits = 1
     f.minimumFractionDigits = 0
     f.maximumFractionDigits = 3
     f.usesGroupingSeparator = false
     return f.string(from: NSNumber(value: x)) ?? "\(x)"
}

struct IngredientView: View {
    @Binding var ingredient: Ingredient
    @Binding var ingredientMultiplier: Double
    
    var body: some View {
        Text(scaleQuantities(in: ingredient.text, by: ingredientMultiplier))
    }
}

extension Float {
    func isApproximately(_ value: Float, tolerance: Float = 0.0001) -> Bool {
        abs(self - value) < tolerance
    }
    
    var decimalPart: Self {
        self.truncatingRemainder(dividingBy: 1)
    }
    
}

