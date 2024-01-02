//
//  EditCardViewModel.swift
//  Grocemate
//
//  Created by Giorgio Latour on 11/18/23.
//

import CoreData
import Foundation
import SwiftUI

final class EditCardViewModel: ObservableObject, CardDetailViewModellable {
    // MARK: - Properties
    @Published var editMode: EditMode = .active
    @Published var titleError: Bool = false
    @Published var ingredientsError: Bool = false

    /// Use the ingredient card in our view.
    /// Also use a Published reference of the ingredients associated
    /// with the card. This allows us to use and modify these rather than
    /// mess with the NSManagedObject. On save, we replace the ingredients
    /// Set and title with what we have in the Published properties.
    var card: IngredientCard
    @Published var title: String
    @Published var ingredients: [Ingredient]

    private let context: NSManagedObjectContext
    let editOrCreateIngredientCard: EditOrCreateIngredientCard = .editCard

    init(coreDataController: CoreDataController,
         ingredientCard: IngredientCard
    ) {
        /// When editing an ingredient card, that card will exist in the main view content,
        /// not the newContext we defined in CoreDataController. Hence, we have to use
        /// viewContext.
        self.context = coreDataController.viewContext
        self.card = ingredientCard
        self.title = ingredientCard.title
        self.ingredients = ingredientCard.ingredientsArr
        print("init editcardviewmodel")
    }

    public func addDummyIngredient() {
        self.ingredients.append(Ingredient(context: self.context))
    }

    /// Using a separate array of Ingredients allows us to circumvent problems with NSSet
    /// in the CoreDataClass for Ingredient. This method replaces the NSManagedObject's
    /// ingredients Set with what we have in this view model.
    public func setIngredientsToCard() {
        self.card.ingredients = Set(self.ingredients)
    }

    public func setCardTitle() {
        self.card.title = self.title
    }

    public func clearTitle() {
        self.title = ""
    }

    public func deleteIngredient(_ indexSet: IndexSet) {
        ingredients.remove(atOffsets: indexSet)
    }

    public func save() throws {
        /// Make sure title field isn't blank.
        if self.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw CardDetailSaveError.titleError
        }

        /// Make sure ingredients list isn't empty and that the ingredients don't have empty names.
        if self.ingredients.isEmpty || self.ingredients.map({ $0.name }).areThereEmptyStrings() {
            throw CardDetailSaveError.ingredientsError
        }

        setCardTitle()
        setIngredientsToCard()

        do {
            try CoreDataController.shared.persist(in: context)
        } catch {
            print("An error occurred saving the card: \(error.localizedDescription)")
        }
    }
}
