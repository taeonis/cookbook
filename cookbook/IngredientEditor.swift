//
//  IngredientEditor.swift
//  CookBookApp
//
//  Created by Taeoni Norgaar on 8/21/25.
//

import SwiftUI

struct IngredientEditor: View {
    @Binding var ingredient: Ingredient
    @Binding var wasCancelled: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    var fractions: [String] = ["","¼","½","¾","⅓","⅔","⅙","⅚","⅛","⅜","⅝","⅞"]
    
    @State var ingredientQuantityWhole_first: Int = 1
    @State var ingredientQuantityFractional_first: String = ""
    @State var ingredientQuantityWhole_last: Int = 1
    @State var ingredientQuantityFractional_last: String = ""
    
    @State var displayAsDecimal: Bool = false

    var body: some View {
        VStack() {
            IngredientView(ingredient: $ingredient, ingredientMultiplier: .constant(1))
                .font(.title)
                .fontWeight(.semibold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
                .padding(.bottom, 20)
            
            List {
                Section (
                    header:
                        HStack {
                            Text("Quantity")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Picker("Display as:", selection: $displayAsDecimal) {
                                Text("decimal").tag(true)
                                Text("fraction").tag(false)
                            }
                            .pickerStyle(.segmented)
                            .fixedSize()
                        }
                ) {
                    if displayAsDecimal {
                        if ingredient.quantityIsRange {
                            HStack {
                                TextField("Enter starting value:", value: $ingredient.quantityRange[0], format: .number)
                                    .keyboardType(.numberPad)
                                    .textEntryBorder()
                                    .frame(height: 150)
                                    .multilineTextAlignment(.center)
                                Text(" to ")
                                TextField("Enter ending value: ", value: $ingredient.quantityRange[1], format: .number)
                                    .keyboardType(.numberPad)
                                    .textEntryBorder()
                                    .frame(height: 150)
                                    .multilineTextAlignment(.center)
                            }
                            
                        } else {
                            TextField("Enter quantity", value: $ingredient.quantityRange[0], format: .number)
                                .keyboardType(.numberPad)
                                .textEntryBorder()
                                .frame(height: 150)
                                .multilineTextAlignment(.center)
                        }
                    } else {
                        if ingredient.quantityIsRange {
                            HStack {
                                HStack {
                                    TextField("Enter whole number:", value: $ingredientQuantityWhole_first, format: .number)
                                        .keyboardType(.numberPad)
                                        .textEntryBorder()
                                        .multilineTextAlignment(.center)
                                        .font(.title3)
                                    Text("+")
                                    Picker("", selection: $ingredientQuantityFractional_first) {
                                        ForEach(fractions, id: \.self) { fraction in
                                            Text(fraction).tag(fraction)
                                                .font(.title3)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 150)
                                }
                                Text(" to ")
                                HStack {
                                    TextField("Enter whole number:", value: $ingredientQuantityWhole_last, format: .number)
                                        .keyboardType(.numberPad)
                                        .textEntryBorder()
                                        .multilineTextAlignment(.center)
                                        .font(.title3)
                                    Text("+")
                                    Picker("", selection: $ingredientQuantityFractional_last) {
                                        ForEach(fractions, id: \.self) { fraction in
                                            Text(fraction).tag(fraction)
                                                .font(.title3)
                                        }
                                    }
                                    .pickerStyle(.wheel)
                                    .frame(height: 125)
                                }
                            }
                        } else {
                            HStack {
                                TextField("Enter whole number:", value: $ingredientQuantityWhole_first, format: .number)
                                    .keyboardType(.numberPad)
                                    .textEntryBorder()
                                    .multilineTextAlignment(.center)
                                    .font(.title3)
                                Text("+")
                                Picker("", selection: $ingredientQuantityFractional_first) {
                                    ForEach(fractions, id: \.self) { fraction in
                                        Text(fraction).tag(fraction)
                                            .font(.title3)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(height: 125)
                            }
                        }
                    }
                    
                    HStack {
                        Spacer()
                        Toggle("Is Range?", isOn: $ingredient.quantityIsRange)
                            .font(.caption2)
                            .fixedSize()
                    }
                }
                
                Section (
                    header:
                        Text("Units")
                            .font(.headline)
                            .fontWeight(.semibold)
                ) {
                    Picker("Select units", selection: $ingredient.unit) {
                        ForEach(Unit.allCases) { unit in
                            Text(unit.displayName).tag(unit)
                                .font(.title3)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 125)
                    if ingredient.unit == .custom {
                        TextField("Enter custom unit name:", text: $ingredient.customUnit)
                            .textEntryBorder()
                            .multilineTextAlignment(.center)
                    }
                }
                
                Section (
                    header:
                        Text("Ingredient Name")
                            .font(.headline)
                            .fontWeight(.semibold)
               ) {
                   TextField("Enter ingredient name:", text: $ingredient.name)
                       .textEntryBorder()
                       .multilineTextAlignment(.center)
                       .font(.title3)
               }
            }

        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    wasCancelled = true
                    dismiss()
                } label: {
                    Text("Cancel")
                }
            }
            ToolbarItem {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                }
                .disabled(ingredient.name == "")
            }
        }
        .onChange(of: ingredientQuantityWhole_first) { updateIngredientQuantity(updateIdx: 0) }
        .onChange(of: ingredientQuantityFractional_first) { updateIngredientQuantity(updateIdx: 0) }
        .onChange(of: ingredientQuantityWhole_last) { updateIngredientQuantity(updateIdx: 1) }
        .onChange(of: ingredientQuantityFractional_last) { updateIngredientQuantity(updateIdx: 1) }
        .onAppear {
            ingredientQuantityWhole_first = Int(ingredient.quantityRange[0])
            ingredientQuantityFractional_first = floatToFraction(num: ingredient.quantityRange[0].decimalPart)
            
            ingredientQuantityWhole_last = Int(ingredient.quantityRange[1])
            ingredientQuantityFractional_last = floatToFraction(num: ingredient.quantityRange[1].decimalPart)
        }
    }
    
    private func updateIngredientQuantity(updateIdx: Int) {
        let whole = Float(updateIdx == 0 ? ingredientQuantityWhole_first : ingredientQuantityWhole_last)
        let frac = fractionToFloat(fraction: updateIdx == 0 ? ingredientQuantityFractional_first : ingredientQuantityFractional_last)

        ingredient.quantityRange[updateIdx] = whole + frac
    }
    
}

#Preview {
    StatefulPreviewWrapper(
        Ingredient(isChecked: false, name: "Flour", quantityIsRange: true, quantityRange: [1, 3], unit: .cup)
    ) { binding in
        IngredientEditor(ingredient: binding, wasCancelled: .constant(false))
    }
}

