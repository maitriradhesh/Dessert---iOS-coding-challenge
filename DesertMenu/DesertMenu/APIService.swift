//
//  APIService.swift
//  DesertMenu
//
//  Created by Maitri on 05/06/24.
//
import Foundation

class APIService {
    static let shared = APIService()
    
    func fetchMeals(completion: @escaping ([Meal]) -> Void) {
        let url = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion([])
                return
            }
            do {
                let meals = try JSONDecoder().decode([String: [Meal]].self, from: data)["meals"] ?? []
                DispatchQueue.main.async {
                    completion(meals)
                }
            } catch {
                completion([])
            }
        }.resume()
    }

    func fetchMealDetails(mealID: String, completion: @escaping (MealDetail?) -> Void) {
        let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=\(mealID)")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let mealDetails = try JSONDecoder().decode([String: [MealDetail]].self, from: data)["meals"]?.first
                DispatchQueue.main.async {
                    completion(mealDetails)
                }
            } catch {
                completion(nil)
            }
        }.resume()
    }
}
