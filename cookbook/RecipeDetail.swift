//
//  RecipeDetail.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/18/25.
//

import SwiftUI
import Foundation

struct RecipeDetail: View {
    @Binding var recipe: Recipe
    let isEditing: Bool
    
    @State var isEditingTags = false
    @State private var ingredientMultiplier: Double = 1.0
    @State private var wasCancelled: Bool = false
    @State private var isCreatingNew: Bool = false
    @State private var isEditingTime: Bool = false
    @State private var showNotes: Bool = false
    
    @State private var sheetHeight: CGFloat = .zero
    
    @State private var deleteTarget: UUID? = nil
    
    @Namespace private var deleteAnimation
    
    var body: some View {
        List {
            // TITLE
            if isEditing {
                TextField("New Recipe", text: $recipe.name, axis: .vertical)
                    .font(.title)
                    .lineLimit(1...5)
                    .textEntryBorder()
                    .fontWeight(.semibold)
            } else {
                Text(recipe.name)
                    .font(.title)
                    .fontWeight(.bold)
            }
            
            // TAGS
            if isEditing {
                if recipe.tags.isEmpty {
                    TagScrollView(tags: ["Add a tag..."])
                        .opacity(0.5)
                        .textEntryBorder()
                        .onTapGesture {
                            isEditingTags.toggle()
                        }
                } else {
                    TagScrollView(tags: recipe.tags)
                        .textEntryBorder()
                        .onTapGesture {
                            isEditingTags.toggle()
                        }
                }
            } else {
                if !recipe.tags.isEmpty {
                    TagScrollView(tags: recipe.tags)
                }
            }
            
            // SOURCE
            HStack {
                Text("Source:")
                if let source = recipe.source, let url = URL(string: source) {
                    Link(destination: url) {
                        Text(source)
                            .foregroundColor(.blue)
                            .underline()
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .fontWeight(.regular)
                    }
                } else {
                    Text("N/A")
                        .fontWeight(.regular)
                }
                
                Spacer()
                Divider()
                
                if isEditing {
                    Button {
                        isEditingTime.toggle()
                    } label: {
                        HStack {
                            Image(systemName: "clock")
                            Text(getTotalTime(for: recipe))
                                .fontWeight(.regular)
                        }
                    }
                    .textEntryBorder()
                } else {
                    HStack {
                        Image(systemName: "clock")
                        Text(getTotalTime(for: recipe))
                            .fontWeight(.regular)
                    }
                }
            }
            .buttonStyle(.plain)
            .font(.subheadline)
            .fontWeight(.semibold)
            .foregroundColor(.secondary)
            
            
            // NOTES
            Button {
                withAnimation {
                    showNotes.toggle()
                }
            } label: {
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees((showNotes ?  -180 : 0)))
                Text(showNotes || isEditing ? "Hide Notes" : "Show Notes")
            }
            .disabled(isEditing)
            .buttonStyle(.plain)
            .fontWeight(.semibold)
            .foregroundStyle(.secondary)
            if showNotes || isEditing {
                HStack {
                    RoundedRectangle(cornerRadius: 16)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: 3)
                        .padding(.horizontal, 8)
                        .opacity(0.8)
                    if recipe.notes.isEmpty && !isEditing {
                        Text("You haven't written any notes yet!")
                            .foregroundColor(.secondary)
                            .padding(.vertical)
                    } else if isEditing {
                        ZStack {
                            if recipe.notes.isEmpty {
                                TextEditor(text: .constant("Add some notes..."))
                                    .foregroundColor(.gray)
                                    .disabled(true)
                            }
                            TextEditor(text: $recipe.notes)
                        }
                        .frame(minHeight: 50)
                        .textEntryBorder()
                        .padding(.vertical)
                    } else {
                        Text(recipe.notes)
                            .padding(.vertical)
                    }
                }
            }
            
            
            // INGREDIENTS
            Section (
                header:
                    HStack {
                        Text("Ingredients")
                            .font(.title2)
                            .fontWeight(.semibold)
                        if !isEditing {
                            Spacer()
                            Text("Multiplier:")
                            Button {
                                print()
                            } label: {
                                if ingredientMultiplier == floor(ingredientMultiplier) {
                                    Text("\(String(format: "%.0f", ingredientMultiplier))×")
                                } else {
                                    Text("\(ingredientMultiplier)×")
                                }
                            }
                            .font(.subheadline)
//                            Picker("Multiplier", selection: $ingredientMultiplier) {
//                                Text("1/2×").tag(0.5 as Double)
//                                Text("1×").tag(1 as Double)
//                                Text("2×").tag(2 as Double)
//                            }
//                            .pickerStyle(.segmented)
//                            .fixedSize()
                        }
                    }
            ) {
                if isEditing {
                    ForEach($recipe.ingredients) { $ingredient in
                        HStack {
                            DeleteButton(
                                deleteTarget: $deleteTarget,
                                itemID: ingredient.id,
                                onDelete: { deleteIngredient(ingredient) })
                            TextField("Enter ingredient...", text: $ingredient.text, axis: .vertical)
                                .lineLimit(1...10)
                                .textEntryBorder()
                        }
                        
                    }
                    HStack {
                        Text("Add Ingredient")
                            .fontWeight(.semibold)
                            .opacity(0.3)
                        Spacer()
                        Button(action: addIngredient) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        
                    }
                } else {
                    ForEach($recipe.ingredients) { $ingredient in
                        HStack {
                            Button {
                                ingredient.isChecked.toggle()
                            } label: {
                                Image(systemName: ingredient.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(ingredient.isChecked ? .green : .gray)
                            }
                            .buttonStyle(.plain)
                            .id(ingredient.isChecked)
                            
                            IngredientView(ingredient: $ingredient, ingredientMultiplier: $ingredientMultiplier)
                        }
                    }
                }
            }
            
            // INSTRUCTIONS
            Section(
                header:
                    Text("Instructions")
                        .font(.title2)
                        .fontWeight(.semibold)
            ) {
                ForEach($recipe.instructions) { $instruction in
                    HStack {
                        if isEditing {
                            DeleteButton(
                                deleteTarget: $deleteTarget,
                                itemID: instruction.id,
                                onDelete: { deleteInstruction(instruction) })
                        }
                        Text("Step \(recipe.instructions.firstIndex(of: instruction)! + 1)")
                            .fontWeight(.semibold)
                    }
                    
                    if isEditing {
                        TextField("Enter instructions...", text: $instruction.text, axis: .vertical)
                            .lineLimit(1...10)
                            .textEntryBorder()
                    } else {
                        Text(instruction.text)
                    }
                }
                if isEditing {
                    HStack {
                        Text("Step \(recipe.instructions.count + 1)")
                            .fontWeight(.semibold)
                            .opacity(0.3)
                        Spacer()
                        Button(action: addInstruction) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                    }
                }
            }
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .sheet(isPresented: $isEditingTags) {
            TagEditor(tags: $recipe.tags)
        }
        .sheet(isPresented: $isEditingTime) {
            NavigationStack {
                TimeEditor(time: $recipe.totalTime)
            }
            .padding()
            .presentationDetents([.height(350)])
        }
    }
    
    private func deleteIngredient(_ ingredient: Ingredient) {
        if deleteTarget == ingredient.id {
            recipe.ingredients.removeAll { $0.id == ingredient.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = ingredient.id
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // reset after 2 seconds if not pressed again
                if deleteTarget == ingredient.id {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        deleteTarget = nil
                    }
                }
            }
        }
    }
    
    private func addIngredient() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            recipe.ingredients.append(Ingredient(text: ""))
        }
    }
    
    private func deleteInstruction(_ instruction: Instruction) {
        if deleteTarget == instruction.id {
            recipe.instructions.removeAll { $0.id == instruction.id }
            deleteTarget = nil
        }
        else {
            deleteTarget = instruction.id
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // reset after 2 seconds if not pressed again
                if deleteTarget == instruction.id {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        deleteTarget = nil
                    }
                }
            }
        }
    }
    
    private func addInstruction() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            recipe.instructions.append(Instruction(text: ""))
        }
    }
}


#Preview {
    StatefulPreviewWrapper(Recipe.example) { recipe in
        RecipeDetail(recipe: recipe, isEditing: false)
            .environmentObject(RecipeData())
    }
}
