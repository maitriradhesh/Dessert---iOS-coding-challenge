//
//  ContentView.swift
//  DesertMenu
//
//  Created by Maitri on 05/06/24.
//

import SwiftUI
import LinkPresentation

struct MealsListView: View {
    @State private var meals = [Meal]()
    @State private var searchText = ""
    @State private var showFavoritesOnly = false
    @EnvironmentObject var favoritesManager: FavoritesManager
    
    init() {
        configureNavigationBar()
    }

    var filteredMeals: [Meal] {
        meals.filter { meal in
            (!showFavoritesOnly || favoritesManager.isFavorite(mealId: meal.idMeal)) &&
            (searchText.isEmpty || meal.strMeal.lowercased().contains(searchText.lowercased()))
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                Toggle(isOn: $showFavoritesOnly) {
                    Text("Show Favorites Only")
                }
                .padding()

                List {
                    if filteredMeals.isEmpty {
                        Text("Sorry, recipe not found!")
                            .foregroundColor(.gray)
                            .font(.title)
                    } else {
                        ForEach(filteredMeals, id: \.id) { meal in
                            HStack {
                                NavigationLink(destination: MealDetailView(mealID: meal.idMeal).environmentObject(favoritesManager)) {
                                    MealRow(meal: meal)
                                }
                                Image(systemName: favoritesManager.isFavorite(mealId: meal.idMeal) ? "heart.fill" : "heart")
                                    .foregroundColor(favoritesManager.isFavorite(mealId: meal.idMeal) ? .yellow : .gray)
                            }
                        }
                    }
                }
                .navigationTitle("DESSERTS")
                .navigationBarTitleDisplayMode(.inline)
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .onAppear {
                    APIService.shared.fetchMeals { fetchedMeals in
                        self.meals = fetchedMeals.sorted(by: { $0.strMeal < $1.strMeal })
                    }
                }
            }
        }
    }

    private func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.titleTextAttributes = [.font: UIFont(name: "Times New Roman", size: 40) ?? UIFont.systemFont(ofSize: 40, weight: .bold), .foregroundColor: UIColor.black]
        appearance.shadowColor = .gray
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct MealRow: View {
    @ObservedObject var meal: Meal

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: meal.strMealThumb)) { phase in
                switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image.resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50, height: 50)
                            .cornerRadius(10)
                    @unknown default:
                        EmptyView()
                }
            }
            .frame(width: 50, height: 50)
            .cornerRadius(10)

            Text(meal.strMeal).font(.custom("Chalkboard", size: 18)).bold()
//
            Spacer()
        }
    }
}

import SwiftUI

struct MealDetailView: View {
    let mealID: String
    @State private var mealDetail: MealDetail?
    @State private var tempRating: Double?  // Temporary storage for the rating
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var showingAddComment = false
    @State private var newComment = ""
    @State private var isSharing = false

    var body: some View {
        List {
            if let mealDetail = mealDetail {
                MealDetailsSection(mealDetail: mealDetail, tempRating: $tempRating)
                MealImageView(mealDetail: mealDetail)
                DetailSections(mealDetail: mealDetail, mealID: mealID)
                CommentSection(mealDetail: mealDetail, showingAddComment: $showingAddComment) // Pass the binding here
                HStack {
                    FavoriteButton(mealID: mealID)
                    Spacer()
                    shareButton(mealDetail: mealDetail)
                }
            }
        }
        .sheet(isPresented: $showingAddComment) {
            CommentInputView(newComment: $newComment, showingAddComment: $showingAddComment, mealDetail: $mealDetail)
        }
        .sheet(isPresented: $isSharing) {
            if let mealDetail = mealDetail {
                ActivityView(activityItems: [composeMessage(mealDetail), URL(string: mealDetail.strMealThumb) as Any].compactMap { $0 })
            }
        }
        .navigationTitle(mealDetail?.strMeal ?? "Meal Details")
        .onAppear {
            APIService.shared.fetchMealDetails(mealID: mealID) { detail in
                self.mealDetail = detail
                self.tempRating = detail?.rating
            }
        }
        .onChange(of: tempRating) { newValue, oldValue in
            updateMealDetailRating(with: newValue)
        }
    }

    private func shareButton(mealDetail: MealDetail) -> some View {
        Button(action: {
            isSharing = true
        }) {
            HStack {
                Text("Share Recipe")
                Text("📤")
            }
        }
        .padding()
        .buttonStyle(BorderedButtonStyle())
    }

    private func composeMessage(_ mealDetail: MealDetail) -> String {
        var message = "Check out this recipe: \(mealDetail.strMeal)\n"
        message += "\nInstructions: \(mealDetail.strInstructions)\n"
        if !mealDetail.ingredients.isEmpty {
            message += "\nIngredients:\n"
            mealDetail.ingredients.forEach { ingredient in
                message += "- \(ingredient)\n"
            }
        }
        message += "\nEnjoy cooking!"
        return message
    }

    private func updateMealDetailRating(with newRating: Double?) {
        if let rating = newRating {
            mealDetail?.rating = rating
            // Save these changes to your data store or backend as needed.
        }
    }
}

struct MealDetailsSection: View {
    let mealDetail: MealDetail
    @Binding var tempRating: Double?

    var body: some View {
        Section(header: Text("Details").font(.headline)) {
            Text("Area: ") + Text(mealDetail.strArea).foregroundColor(.yellow)
            Text("Category: ") + Text(mealDetail.strCategory).foregroundColor(.yellow)
            if let rating = tempRating ?? mealDetail.rating {
                Text("Rating: \(rating, specifier: "%.1f") ⭐️")
            } else {
                Text("Rating: Not rated")
            }
            RatingView(rating: $tempRating)
        }
    }
}

struct RatingView: View {
    @Binding var rating: Double?

    var body: some View {
        HStack {
            ForEach(1...5, id: \.self) { star in
                starImage(for: star)
                    .onTapGesture {
                        rating = Double(star)
                    }
            }
        }
    }

    private func starImage(for star: Int) -> some View {
        let imageName = star <= Int((rating ?? 0)) ? "star.fill" : "star"
        return Image(systemName: imageName)
            .foregroundColor(star <= Int((rating ?? 0)) ? .yellow : .gray)
    }
}

struct MealImageView: View {
    let mealDetail: MealDetail

    var body: some View {
        AsyncImage(url: URL(string: mealDetail.strMealThumb)) { phase in
            switch phase {
                case .success(let image):
                    image.resizable()
                case .failure:
                    Text("There was an error loading the image.")
                default:
                    ProgressView()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: 300, height: 300)
        .cornerRadius(15)
        .padding()
    }
}

struct DetailSections: View {
    let mealDetail: MealDetail
    let mealID: String
    @EnvironmentObject var favoritesManager: FavoritesManager

    var body: some View {
        Section(header: Text("Instructions").font(.headline)) {
            Text(mealDetail.strInstructions)
        }
        Section(header: Text("Ingredients").font(.headline)) {
            ForEach(mealDetail.ingredients, id: \.self) { ingredientLine in
                HStack {
                    Text(getMeasure(from: ingredientLine)).bold()
                    Text("of").italic()
                    Text(getIngredient(from: ingredientLine)).bold()
                }
            }
        }
    }

    func getMeasure(from ingredientLine: String) -> String {
        let components = ingredientLine.components(separatedBy: " of ")
        return components.first ?? ""
    }

    func getIngredient(from ingredientLine: String) -> String {
        let components = ingredientLine.components(separatedBy: " of ")
        return components.count > 1 ? components[1] : ""
    }
}

struct FavoriteButton: View {
    let mealID: String
    @EnvironmentObject var favoritesManager: FavoritesManager
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { // Delay to mimic button press effect
                    isPressed = false
                    favoritesManager.updateFavorite(mealId: mealID, isFavorite: !(favoritesManager.isFavorite(mealId: mealID)))
                }
            }
        }) {
            HStack {
                Text(favoritesManager.isFavorite(mealId: mealID) ? "Unmark as Favorite" : "Mark as Favorite")
                Text("❤️")
            }
        }
        .padding()
        .buttonStyle(BorderedButtonStyle())
    }
}

struct CommentSection: View {
    let mealDetail: MealDetail
    @Binding var showingAddComment: Bool  // Add this binding

    var body: some View {
        Section(header: Text("Comments").font(.headline)) {
            if !mealDetail.comments.isEmpty {
                ForEach(mealDetail.comments, id: \.self) { comment in
                    Text(comment)
                }
            } else {
                Text("No comments yet")
            }
            Button("Add Comment") {
                showingAddComment = true
            }
        }
    }
}

struct CommentInputView: View {
    @Binding var newComment: String
    @Binding var showingAddComment: Bool
    @Binding var mealDetail: MealDetail?

    var body: some View {
        VStack {
            TextField("Type your comment here", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Post") {
                if !newComment.isEmpty {
                    mealDetail?.comments.append(newComment)
                    newComment = ""  // Clear the text field after posting
                    showingAddComment = false
                }
            }
            .buttonStyle(DefaultButtonStyle())
            .padding()
        }
    }
}

struct ActivityView: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]?

    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {
        // No update code needed
    }
}
