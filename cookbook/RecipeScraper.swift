//
//  RecipeScraper.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import Foundation
import SwiftSoup
import SwiftUI

struct RecipeSchema: Codable {
    let name: String?
    let totalTime: String?
    let recipeIngredient: [String]?
    let recipeInstructions: [tempInstruction]?
    
    struct tempInstruction: Codable {
        let text: String?
    }
}

func fetchHTML(from urlString: String) async throws -> String {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }

    let (data, _) = try await URLSession.shared.data(from: url)
    return String(decoding: data, as: UTF8.self)
}

func parseHTML(_ html: String) throws -> RecipeSchema? {
    let doc: Document = try SwiftSoup.parse(html)
    let scripts = try doc.select("script[type=application/ld+json]")
    
    for script in scripts {
        let json = try script.html()
        if let data = json.data(using: .utf8) {
            let decoder = JSONDecoder()
            
            //singular
            if let schema = try? decoder.decode(RecipeSchema.self, from: data),
               schema.recipeIngredient != nil {
                print("RETURNING single schema")
                return schema
            }
            
            // array
            if let schemas = try? decoder.decode([RecipeSchema].self, from: data) {
                if let recipe = schemas.first(where: { $0.recipeIngredient != nil }) {
                    print("RETURNING schema from array")
                    return recipe
                }
            }
        }
    }
    return nil
}

func parseFraction(_ str: String) -> Float? {
    let parts = str.split(separator: "/").compactMap { Float($0) }
    guard parts.count == 2 else { return nil }
    return parts[0] / parts[1]
}

func parseQuantity(_ input: String) -> [Float] {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.allowsFloats = true
    formatter.generatesDecimalNumbers = true
    formatter.isLenient = true
    formatter.locale = Locale(identifier: "en_US")

    // Add support for simple vulgar fractions
    let normalized = input
        .replacingOccurrences(of: "½", with: "1/2")
        .replacingOccurrences(of: "¼", with: "1/4")
        .replacingOccurrences(of: "¾", with: "3/4")
        .replacingOccurrences(of: "⅓", with: "1/3")
        .replacingOccurrences(of: "⅔", with: "2/3")
        .replacingOccurrences(of: "⅙", with: "1/6")
        .replacingOccurrences(of: "⅚", with: "5/6")
        .replacingOccurrences(of: "⅛", with: "1/8")
        .replacingOccurrences(of: "⅜", with: "3/8")
        .replacingOccurrences(of: "⅝", with: "5/8")
        .replacingOccurrences(of: "⅞", with: "7/8")
    
    // Handle ranges like "2-3", "2 to 3"
    if normalized.contains("-") || normalized.contains(" to ") {
        let parts = normalized
            .replacingOccurrences(of: " to ", with: "-")
            .split(separator: "-")
            .compactMap { formatter.number(from: String($0))?.floatValue }
        if parts.count == 2 { return parts }
    }

    // Handle simple whole/fraction combos like "1 1/2"
    if normalized.contains(" ") {
        let parts = normalized.split(separator: " ")
        if let whole = formatter.number(from: String(parts[0]))?.floatValue,
           let frac = parseFraction(String(parts[1])) {
            return [whole + frac]
        }
    }

    // Single number, fraction, or decimal
    if let value = formatter.number(from: normalized)?.floatValue {
        return [value]
    }

    if let frac = parseFraction(normalized) {
        return [frac]
    }

    return [0]
}

func parseIngredient(_ scrapedIngredient: String) -> Ingredient{
    var ingredient: Ingredient = Ingredient()
    
    // pattern =
    // 1) integer, optionally followed by fraction ("1 1/2" or "1 ½")
    // 2) standalone fraction like "3/4"
    // 3) decimal like "1.5"
    // 4) single unicode fraction "¼", "½", "¾"
    // 5) range with dash "2-3"
    // 6) range with "to" ("2 to 3")
    // 7) unit (letters only, e.g. "cups", "g")
    // 8) ingredient name (everything else)
    let pattern = #"^(\d+\.\d+|\d+/\d+|[\u00BC-\u00BE\u2150-\u215E]+|\d+-\d+|\d+\s+to\s+\d+|\d+(?:\s+(?:\d+/\d+|[\u00BC-\u00BE\u2150-\u215E]))?)?\s*([a-zA-Z]+)?\s*(.*)$"#
    let regex = try! NSRegularExpression(pattern: pattern)
    if let match = regex.firstMatch(in: scrapedIngredient, range: NSRange(scrapedIngredient.startIndex..., in: scrapedIngredient)) {
        // parse quantity
        let quantitySubstring = Range(match.range(at: 1), in: scrapedIngredient).map { String(scrapedIngredient[$0]) } ?? ""
        let quantity: [Float] = parseQuantity(quantitySubstring)
        if quantity.count > 1 {
            ingredient.quantityRange = [quantity.first!, quantity.last!]
        } else {
            ingredient.quantityRange[0] = quantity.first!
        }
        
        // parse units
        let unitSubstring = Range(match.range(at: 2), in: scrapedIngredient).map { String(scrapedIngredient[$0]) } ?? ""
        if unitSubstring == "" {
            ingredient.unit = .n_a
        } else if let unit = unitMap()[unitSubstring] {
            ingredient.unit = unit
        } else {
            ingredient.unit = .custom
            ingredient.customUnit = unitSubstring 
        }
        
        // parse name
        let nameSubstring = Range(match.range(at: 3), in: scrapedIngredient).map { String(scrapedIngredient[$0]) } ?? scrapedIngredient
        ingredient.name = nameSubstring
    }
    return ingredient
}

func parseDate(_ durationString: String) -> Int {
    guard durationString.hasPrefix("P") else {
        return 0
    }
    var remainingString: Substring = durationString.dropFirst()
    var totalMinutes: Int = 0
    
    if let rangeOfT = remainingString.range(of: "T") {
        let timePart = remainingString[rangeOfT.upperBound...]
        remainingString = remainingString[..<rangeOfT.lowerBound]
        
        if let hourRange = timePart.range(of: "H") {
            let hourString = timePart[..<hourRange.lowerBound]
            if let hours = Int(hourString) {
                totalMinutes += hours * 60
            }
        }

        if let minuteRange = timePart.range(of: "M", options: .backwards) {
            let minuteStartIndex = timePart.range(of: "H")?.upperBound ?? timePart.startIndex
            let minuteString = timePart[minuteStartIndex..<minuteRange.lowerBound]
            if let minutes = Int(minuteString) {
                totalMinutes += minutes
            }
        }
    }
    return totalMinutes
}


func createRecipe(url: String) async throws -> Recipe {
    var newRecipe: Recipe = Recipe()
    
    let html = try? await fetchHTML(from: url)
    let scrapedData: RecipeSchema? = try parseHTML(html ?? "")
    if let scrapedData {
        var finalIngredients: [Ingredient] = []
        
        for scrapedIngredient in scrapedData.recipeIngredient ?? [] {
            finalIngredients.append(parseIngredient(scrapedIngredient))
        }
        newRecipe.source = url
        newRecipe.name = scrapedData.name ?? ""
        newRecipe.totalTime = parseDate(scrapedData.totalTime ?? "")
        newRecipe.instructions = (scrapedData.recipeInstructions ?? []).map {
            Instruction(text: $0.text ?? "")
        }
        newRecipe.ingredients = finalIngredients
    }
    
    return newRecipe
}

struct UrlInput: View {
    var body: some View {
        
    }
}
