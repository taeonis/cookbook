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


func parseTime(_ durationString: String) -> Int {
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
        
        newRecipe.source = url
        newRecipe.name = scrapedData.name ?? ""
        newRecipe.totalTime = parseTime(scrapedData.totalTime ?? "")
        newRecipe.instructions = (scrapedData.recipeInstructions ?? []).map {
            Instruction(text: $0.text ?? "")
        }
        newRecipe.ingredients = (scrapedData.recipeIngredient ?? []).map {
            Ingredient(text: $0)
        }
    }
    
    return newRecipe
}

struct UrlInput: View {
    var body: some View {
        
    }
}
