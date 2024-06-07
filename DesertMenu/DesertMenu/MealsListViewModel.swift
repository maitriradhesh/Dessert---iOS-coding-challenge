//
//  MealsListViewModel.swift
//  DesertMenu
//
//  Created by Maitri on 06/06/24.
//

import Foundation
import Combine

class MealsListViewModel: ObservableObject {
    @Published var meals: [Meal] = []
    @Published var showFavoritesOnly = false
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    var filteredMeals: [Meal] {
        meals.filter { meal in
            (!showFavoritesOnly || meal.isFavorite) &&
            (searchText.isEmpty || meal.strMeal.lowercased().contains(searchText.lowercased()))
        }
    }

    func fetchMeals() {
        isLoading = true
        APIService.shared.fetchMeals { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                switch result {
                    case .failure(let error):
                    self?.errorMessage = "Failed to fetch meals: \(error.localizedDescription)"
                    case .success(let fetchedMeals):
                    self?.meals = fetchedMeals.sorted(by: { $0.strMeal < $1.strMeal })
                
                }
            }
        }
    }

    func isFavorite(mealID: String) -> Bool {
        // Assuming FavoritesManager implementation is correct
        FavoritesManager.shared.isFavorite(mealId: mealID)
    }

    func toggleFavorite(mealID: String) {
        guard let index = meals.firstIndex(where: { $0.idMeal == mealID }) else { return }
        meals[index].isFavorite.toggle()
        FavoritesManager.shared.updateFavorite(mealId: mealID, isFavorite: meals[index].isFavorite)
    }
}
