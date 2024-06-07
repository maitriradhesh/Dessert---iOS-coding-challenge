//
//  DesertMenuApp.swift
//  DesertMenu
//
//  Created by Maitri on 05/06/24.
//

import SwiftUI

@main
struct DesertMenuApp: App {
    var body: some Scene {
        WindowGroup {
            MealsListView()
                .environmentObject(FavoritesManager.shared)
        }
    }
}


