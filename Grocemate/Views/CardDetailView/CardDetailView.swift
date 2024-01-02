//
//  CreateCardView.swift
//  GroceMate
//
//  Created by Giorgio Latour on 11/5/23.
//

import SwiftUI

struct CardDetailView<ViewModel: CardDetailViewModellable>: View {
    // MARK: - Environment
    @Environment(\.dismiss) var dismiss

    // MARK: - State
    @StateObject var viewModel: ViewModel
    @FocusState var titleFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ingredientCardTitle
                    .padding(20)
                List {
                    ingredientList
                }
                .toolbar {
                    toolbarView
                }
                .environment(\.editMode, $viewModel.editMode)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(
                titleTextView
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Subviews
    private var titleTextView: Text {
        let titleText = viewModel.editOrCreateIngredientCard == .editCard ? "Edit Card" : "Create Card"

        return Text(titleText)
    }
    private var addButton: some View {
        Button {
            withAnimation {
                viewModel.addDummyIngredient()
            }
        } label: {
            Text("Add Ingredient")
                .fontWeight(.bold)
                .fontDesign(.rounded)
                .padding(5)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(
            .roundedRectangle(radius: 30)
        )
    }

    private var ingredientCardTitle: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .fill(viewModel.titleError ? .red.opacity(0.2) : .gray.opacity(0.1))
                .frame(height: 60)
            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .center)) {
                TextField("Recipe Title", text: $viewModel.title)
                    .disabled(viewModel.editMode == .inactive)
                    .font(.system(.title3))
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
                    .padding()
                    .focused($titleFocused)
                    /// .onAppear { UITextField.appearance().clearButtonMode = .whileEditing }
                    /// Causes:
                    /// "Error: this application, or a library it uses, has passed an invalid
                    /// numeric value (NaN, or not-a-number) to CoreGraphics API and this
                    /// value is being ignored. Please fix this problem."
                    /// A clear text field button is not available without reaching into UITextField.
                    /// Add a custom button.
                    .overlay {
                        if titleFocused {
                            HStack {
                                Spacer()

                                Button {
                                    viewModel.clearTitle()
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title2)
                                        .tint(.gray.opacity(0.5))
                                }
                                .padding(.trailing, 20)
                            }
                        }
                    }
            }
        }
    }

    private var ingredientList: some View {
        Group {
            Section(header: Text("Ingredients")) {
                ForEach($viewModel.ingredients) { $ingredient in
                    TextField("Ingredient", text: $ingredient.name, axis: .vertical)
                        .disabled(viewModel.editMode == .inactive)
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                }
                .onDelete(perform: viewModel.deleteIngredient)
                .listRowBackground(viewModel.ingredientsError ? Color.red.opacity(0.2) : .gray.opacity(0.1))
            }

            Section {
                EmptyView()
            } footer: {
                HStack(alignment: .center) {
                    Spacer()
                    addButton
                    Spacer()
                }
            }
        }
    }

    private var toolbarView: some ToolbarContent {
        Group {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .fontDesign(.rounded)
                    .fontWeight(.semibold)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    do {
                        try viewModel.save()
                        dismiss()
                    } catch CardDetailSaveError.titleError {
                        titleErrorAnimation()
                    } catch CardDetailSaveError.ingredientsError {
                        ingredientsErrorAnimation()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Text("Save")
                        .fontDesign(.rounded)
                        .fontWeight(.semibold)
                }
            }
        }
    }

    // MARK: - Animations
    private func titleErrorAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.titleError = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                viewModel.titleError = false
            }
        }
    }

    private func ingredientsErrorAnimation() {
        withAnimation(.easeInOut(duration: 0.5)) {
            viewModel.ingredientsError = true
            viewModel.addDummyIngredient()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeInOut(duration: 0.5)) {
                viewModel.ingredientsError = false
            }
        }
    }
}

#Preview("CardDetailView_ManualAdd") {
    let preview = CoreDataController.shared

    let viewToPreview = {
        CardDetailView<CreateCardViewModel>(
            viewModel: CreateCardViewModel(
                coreDataController: preview,
                context: preview.newContext
            )
        )
        .environment(\.managedObjectContext, preview.viewContext)
    }()

    return viewToPreview
}
