//
//  Meal.swift
//  DesertMenu
//
//  Created by Maitri on 05/06/24.
//
import Foundation
import SwiftUI
import Combine

class Meal: Identifiable, ObservableObject, Decodable {
    let idMeal: String
    let strMeal: String
    let strMealThumb: String
    let strArea: String?
    @Published var comments: [String] = []
    @Published var rating: Double?


    @Published var isFavorite: Bool {
        willSet {
                    objectWillChange.send()
                }
        didSet {
            if oldValue != isFavorite {
                FavoritesManager.shared.updateFavorite(mealId: idMeal, isFavorite: isFavorite)
            }
        }    }

    var id: String { idMeal }

    enum CodingKeys: CodingKey {
        case idMeal, strMeal, strMealThumb, strArea
    }

    init(idMeal: String, strMeal: String, strMealThumb: String, strArea: String?, isFavorite: Bool = false) {
        self.idMeal = idMeal
        self.strMeal = strMeal
        self.strMealThumb = strMealThumb
        self.strArea = strArea
        self.isFavorite = isFavorite
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        idMeal = try container.decode(String.self, forKey: .idMeal)
        strMeal = try container.decode(String.self, forKey: .strMeal)
        strMealThumb = try container.decode(String.self, forKey: .strMealThumb)
        strArea = try container.decodeIfPresent(String.self, forKey: .strArea)
        isFavorite = FavoritesManager.shared.isFavorite(mealId: idMeal)
        comments = []
        rating = nil

    }
}

struct MealDetail: Decodable {
    let idMeal: String
    let strMeal: String
    let strInstructions: String
    let strMealThumb: String
    var ingredients: [String]
    let strArea: String
    let strCategory: String
    let strYoutube: String
    var comments: [String] = []
    var rating: Double?

    
    private struct DynamicCodingKeys: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int?
        init?(intValue: Int) {
            return nil
        }
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKeys.self)
        idMeal = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "idMeal")!)
        strMeal = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strMeal")!)
        strInstructions = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strInstructions")!)
        strMealThumb = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strMealThumb")!)
        strArea = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strArea")!)
        strCategory = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strCategory")!)
        strYoutube = try container.decode(String.self, forKey: DynamicCodingKeys(stringValue: "strYoutube")!)
       


        var ingredientsTemp: [String] = []
        
        for i in 1...20 {
            let ingredientKey = DynamicCodingKeys(stringValue: "strIngredient\(i)")!
            let measureKey = DynamicCodingKeys(stringValue: "strMeasure\(i)")!
            
            if let ingredient = try container.decodeIfPresent(String.self, forKey: ingredientKey),
               let measure = try container.decodeIfPresent(String.self, forKey: measureKey),
               !ingredient.isEmpty, !measure.isEmpty {
                ingredientsTemp.append("\(measure) of \(ingredient)")
            }
        }

        ingredients = ingredientsTemp
    }
}
