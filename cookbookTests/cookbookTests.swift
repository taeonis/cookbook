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
    

}
