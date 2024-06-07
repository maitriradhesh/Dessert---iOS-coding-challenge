//
//  FavouritesManager.swift
//  DesertMenu
//
//  Created by Maitri on 06/06/24.
//

import Foundation

class FavoritesManager: ObservableObject {
    static let shared = FavoritesManager()
    private let defaults = UserDefaults.standard
    private let favoritesKey = "Favorites"

    private init() {}  // Private initializer to ensure singleton usage

    var favorites: Set<String> {
        get {
            Set(defaults.stringArray(forKey: favoritesKey) ?? [])
        }
        set {
            defaults.set(Array(newValue), forKey: favoritesKey)
        }
    }

    func isFavorite(mealId: String) -> Bool {
        favorites.contains(mealId)
    }

    func updateFavorite(mealId: String, isFavorite: Bool) {
        var currentFavorites = favorites
        if isFavorite {
            currentFavorites.insert(mealId)
        } else {
            currentFavorites.remove(mealId)
        }
        favorites = currentFavorites
    }
}
