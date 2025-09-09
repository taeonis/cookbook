//
//  Ingredient.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import SwiftUI

enum Unit: String, CaseIterable, Identifiable, Codable, Hashable {
    case tsp
    case tbsp
    case cup
    case oz
    case g
    case ml
    case fl_oz
    case lb
    case custom
    case n_a
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .tsp: "tsp"
        case .tbsp: "tbsp"
        case .cup: "cup"
        case .oz: "oz"
        case .g: "g"
        case .ml: "ml"
        case .fl_oz: "fl oz"
        case .lb: "lb"
        case .custom: "(custom)"
        case .n_a: "N/A"
        }
    }
}

struct Ingredient: Identifiable, Hashable {
    var id = UUID()
    var isChecked: Bool = false
    var name: String = ""
    var quantityIsRange: Bool = false
    var quantityRange: [Float] = [0, 0]
    var unit: Unit = .n_a
    var customUnit: String = ""
}

struct newIngredient: Identifiable, Hashable {
    var id = UUID()
    var text: String
}

func unitMap() -> [String: Unit] {
    return [
        "tsp": .tsp, "teaspoon": .tsp, "teaspoons": .tsp,
        "tbsp": .tbsp, "tablespoon": .tbsp, "tablespoons": .tbsp,
        "cup": .cup, "cups": .cup,
        "oz": .oz, "ounce": .oz, "ounces": .oz,
        "g": .g, "gram": .g, "grams": .g,
        "ml": .ml, "milliliter": .ml, "milliliters": .ml,
        "floz": .fl_oz, "fl": .fl_oz, "fl.oz": .fl_oz,
        "fluid": .fl_oz, "pound": .lb, "pounds": .lb, "lb": .lb, "lbs": .lb
    ]
}

func fractionsList() -> [String] {
    return ["¼","½","¾","⅓","⅔","⅙","⅚","⅛","⅜","⅝","⅞"]
}

func floatToFraction(num: Float) -> String {
    if num.isApproximately(1.0/3.0) {
        return "⅓"
    } else if num.isApproximately(2.0/3.0) {
        return "⅔"
    } else if num.isApproximately(0.5) {
        return "½"
    } else if num.isApproximately(0.25) {
        return "¼"
    } else if num.isApproximately(0.75) {
        return "¾"
    } else if num.isApproximately(0.125) {
        return "⅛"
    } else if num.isApproximately(0.375) {
        return "⅜"
    } else if num.isApproximately(0.625) {
        return "⅝"
    } else if num.isApproximately(0.875) {
        return "⅞"
    } else if num.isApproximately(1.0/6.0) {
        return "⅙"
    } else if num.isApproximately(5.0/6.0) {
        return "⅚"
    } else {
        return String(format: "%.2f", num)
    }
}

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

struct newIngredientView: View {
    @Binding var ingredient: newIngredient
    @Binding var ingredientMultiplier: Float?
    
    var body: some View {
        Text(ingredient.text)
    }
}

struct IngredientView: View {
    @Binding var ingredient: Ingredient
    @Binding var ingredientMultiplier: Float
    
    var quantity: [Float] {
        if ingredient.quantityIsRange {
            return ingredient.quantityRange.map { $0 * ingredientMultiplier }
        }
        return [ingredient.quantityRange[0] * ingredientMultiplier]
    }
    
    var quantityDisplay: String {
        quantity.enumerated().map { idx, q in
            if q == Float(Int(q)) {
                return String(Int(q))
            } else if q < 1 {
                return floatToFraction(num: q)
            } else {
                let fractional = floatToFraction(num: q.decimalPart)
                if fractional.contains(".") {
                    return String(q)
                } else {
                    return "\(Int(q)) \(fractional)"
                }
            }
        }
        .joined(separator: "-")
    }
    
    var unitDisplay: String {
        if ingredient.unit == .custom {
            return ingredient.customUnit
        } else if ingredient.unit == .n_a {
            return ""
        }
        return ingredient.unit.displayName
    }
    
    var body: some View {
        Text("\(quantityDisplay) \(unitDisplay) \(ingredient.name)")
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

