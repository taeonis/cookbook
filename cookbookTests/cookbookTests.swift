//
//  cookbookTests.swift
//  cookbookTests
//
//  Created by Taeoni Norgaar on 8/5/25.
//

import Testing
@testable import CookBookApp

struct cookbookTests {

    @Test func testFetchHTML() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        let url = "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/"
        let html = try await fetchHTML(from: url)
        #expect(!html.isEmpty)
    }
    
    @Test func testParseHTML() async throws {
        let url = "https://www.allrecipes.com/recipe/21014/good-old-fashioned-pancakes/"
        var html: String = ""
        do {
            html = try await fetchHTML(from: url)
        } catch {
            print("Error fetching HTML:", error)
        }
        if let schema = try parseHTML(html) {
//            print("Schema:", schema)
//            print("Name:", schema.name ?? "nil")
//            print("Ingredients:", schema.recipeIngredient ?? [])
//            print("Instructions:", schema.recipeInstructions ?? [])
        } else {
//            print("No recipe schema found")
        }
        
        #expect(true)
    }
    
    @Test func testParseIngredient() {
        let strs: [String] = [
            "1 ½ cups all-purpose flour", // unicode frac unit
            "1 tablespoon white sugar", // whole number unit
            "a banana", // no quantity/units
            "3.5 cups buttermilk", // decimal unit
            "1/2 tbsp salt", // fraction unit
            "1 large egg", // yes quantity no units
            "1 stalk broccoli", // custom units
            "1-2 lbs potatoes", // range quantity
            "1 to 2 pounds potatoes"
            
        ]
        let correctParsed: [Ingredient] = [
            Ingredient(name: "all-purpose flour", quantity: 1.5, unit: .cup),
            Ingredient(name: "white sugar", quantity: 1, unit: .tbsp),
            Ingredient(name: "banana", quantity: 0, unit: .custom, customUnit: "a"),
            Ingredient(name: "buttermilk", quantity: 3.5, unit: .cup),
            Ingredient(name: "salt", quantity: 0.5, unit: .tbsp),
            Ingredient(name: "egg", quantity: 1, unit: .custom, customUnit: "large"),
            Ingredient(name: "broccoli", quantity: 1, unit: .custom, customUnit: "stalk"),
            Ingredient(name: "potatoes", quantity: 1, quantityRange: [1,2], unit: .lb),
            Ingredient(name: "potatoes", quantity: 1, quantityRange: [1,2], unit: .lb)
        ]
        
        for i in strs.indices {
            let parsed: Ingredient = parseIngredient(strs[i])
            #expect(parsed.name == correctParsed[i].name)
            #expect(parsed.quantity == correctParsed[i].quantity)
            #expect(parsed.unit == correctParsed[i].unit)
            #expect(parsed.customUnit == correctParsed[i].customUnit)
            #expect(parsed.quantityRange == correctParsed[i].quantityRange)
        }
    }

}
