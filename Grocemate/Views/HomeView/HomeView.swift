//
//  ContentView.swift
//  GroceMate
//
//  Created by Giorgio Latour on 11/2/23.
//

import SwiftUI

struct HomeView: View {
    //MARK: - State
    @StateObject var vm = HomeViewModel()
    
    //MARK: - Properties
    @FetchRequest(fetchRequest: IngredientCard.all()) private var ingredientCards
    var coreDataController = CoreDataController.shared
    
    var body: some View {
        NavigationStack(path: $vm.path) {
            mainView
                .toolbar {
                    mainViewToolbar
                }
                
        }
        .sheet(isPresented: $vm.presentCreateCardView, content: {
            CardDetailView<CreateCardViewModel>(vm: CreateCardViewModel(coreDataController: .shared))
        })
        .sheet(item: $vm.sheet, content: makeSheet)
        .confirmationDialog("Add Options", isPresented: $vm.presentConfirmationDialog) {
            Button  {
                vm.sheet = .editCard
            } label: {
                Text("Edit Ingredients Card")
            }
        }
        .environmentObject(vm)
    }
    
    //MARK: - Subviews
    private var mainView: some View {
        ScrollView(.vertical) {
            VStack {
                if ingredientCards.isEmpty {
                    emptyIngredientCardsView
                } else {
                    ingredientCardsView
                        .padding(.top, 30)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    //    private var showCreateCardViewButton: some View {
    //        Button {
    //            showCreateCardView = true
    //        } label: {
    //            ZStack {
    //                RoundedRectangle(cornerRadius: 15)
    //                    .foregroundStyle(.blue)
    //                    .frame(width: 120, height: 50)
    //                Text("Grocemate")
    //                    .fontWeight(.bold)
    //                    .fontDesign(.rounded)
    //            }
    //        }
    //        .tint(.white)
    //    }
    
    private var emptyIngredientCardsView: some View {
        Text("Tap the plus to get started!")
            .font(.system(size: 30))
            .fontWeight(.semibold)
            .fontDesign(.rounded)
            .frame(width: 300)
            .frame(minHeight: 600)
    }
    
    private var ingredientCardsView: some View {
        LazyVStack(alignment: .center) {
            ForEach(ingredientCards) { ingredientCard in
                Card(ingredientCard: ingredientCard)
                    .padding(.bottom, 15)
            }
        }
    }
    
    private var mainViewToolbar: some ToolbarContent {
        Group {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("Grocemate")
                    .multilineTextAlignment(.center)
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(.blue)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button {
                        vm.sheet = .cameraView
                    } label: {
                        HStack {
                            Text("Take a Picture")
                            Image(systemName: "camera")
                        }
                    }
                    
                    Button {
                        vm.presentPhotosPicker = true
                    } label: {
                        HStack {
                            Text("Select from Photos")
                            Image(systemName: "photo.stack")
                        }
                    }
                    
                    Button {
                        vm.presentCreateCardView = true
                    } label: {
                        HStack {
                            Text("Manually Add Card")
                            Image(systemName: "character.cursor.ibeam")
                        }
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 16, weight: .semibold))
                        .accessibilityLabel("Add a new card.")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    vm.path.append("Settings")
                } label: {
                    Image(systemName: "gear")
                        .font(.system(size: 16, weight: .semibold))
                }
            }
        }
    }
    
    @ViewBuilder private func makeSheet(_ sheet: Sheets) -> some View {
        switch sheet {
        case .cameraView:
            EmptyView()
//            CameraView()
        case .imageROI:
            EmptyView()
//            if let image = selectedImage {
//                ImageWithROI(image: image)
//            }
        case .editCard:
            if let selectedCard = vm.selectedCard {
                CardDetailView<EditCardViewModel>(vm: EditCardViewModel(coreDataController: .shared, ingredientCard: selectedCard))
            }
        }
    }
}

#Preview("Main View with Data") {
    let preview = CoreDataController.shared
    
    let viewToPreview = {
        HomeView()
            .environment(\.managedObjectContext, preview.viewContext)
            .onAppear {
                IngredientCard.makePreview(count: 2, in: preview.viewContext)
            }
    }()
    
    return viewToPreview
}

#Preview("Empty Main View") {
    let preview = CoreDataController.shared
    
    let viewToPreview = {
        HomeView()
            .environment(\.managedObjectContext, preview.viewContext)
            .onAppear {
                IngredientCard.makePreview(count: 0, in: preview.viewContext)
            }
    }()
    
    return viewToPreview
}
