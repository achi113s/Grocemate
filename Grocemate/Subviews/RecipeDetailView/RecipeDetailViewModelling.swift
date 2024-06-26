//
//  CardDetailViewModelProtocol.swift
//  Grocemate
//
//  Created by Giorgio Latour on 11/18/23.
//

import SwiftUI

@MainActor protocol RecipeDetailViewModelling: ObservableObject {
    var editMode: EditMode { get set }
    var titleError: Bool { get set }
    var ingredientsError: Bool { get set }

    var recipe: Recipe { get set }
    var title: String { get set }
    var ingredients: [Ingredient] { get set }
    var steps: [RecipeStep] { get set }
    var notes: String { get set }
    var yield: String { get set }

    func clearTitle()
    func addDummyIngredient()
    func addDummyStep()

    func setRecipeTitle()
    func setIngredientsToRecipe()
    func setStepsToRecipe()
    func setRecipeNotes()
    func setRecipeYield()

    func deleteIngredient(_ indexSet: IndexSet)
    func deleteRecipeStep(_ indexSet: IndexSet)
    func moveRecipeStep(from indices: IndexSet, to newOffset: Int)
    func save() throws
}
