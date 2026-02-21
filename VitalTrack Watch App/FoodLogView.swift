import SwiftUI

private struct MealCategoryPickerView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(categories, id: \.self) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Text(category)
                        Spacer()
                        if category == selectedCategory {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
        }
        .navigationTitle("Category")
    }
}

struct FoodLogView: View {
    @ObservedObject var healthManager: HealthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedCategory = "Breakfast"
    @State private var calorieAmount: Double = 300
    @FocusState private var calorieValueFocused: Bool

    private let minCalories: Double = 0
    private let maxCalories: Double = 9999
    private let calorieStep: Double = 10
    
    let categories = ["Breakfast", "Lunch", "Dinner", "Snack"]

    var body: some View {
        VStack(spacing: 12) {
            Spacer(minLength: 8)

            NavigationLink {
                MealCategoryPickerView(selectedCategory: $selectedCategory, categories: categories)
            } label: {
                HStack(spacing: 6) {
                    Text("Category")
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                    Spacer()
                    Text(selectedCategory)
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    Image(systemName: "chevron.right")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .imageScale(.small)
                }
            }
            .buttonStyle(.plain)

            Spacer(minLength: 0)

            HStack(alignment: .center, spacing: 12) {
                Button {
                    calorieAmount = max(minCalories, calorieAmount - calorieStep)
                    calorieValueFocused = true
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)

                ZStack {
                    Color.clear
                    VStack(spacing: 2) {
                        Text(String(Int(calorieAmount)))
                            .font(.system(size: 50, weight: .bold, design: .rounded))
                            .foregroundStyle(.orange)
                            .monospacedDigit()
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .focusable(true)
                .focused($calorieValueFocused)
                .digitalCrownRotation($calorieAmount, from: minCalories, through: maxCalories, by: calorieStep, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
                .onTapGesture { calorieValueFocused = true }
                .onAppear { DispatchQueue.main.async { calorieValueFocused = true } }
                .onChange(of: calorieAmount) { _, newValue in
                    let clamped = min(max(newValue, minCalories), maxCalories)
                    let stepped = (clamped / calorieStep).rounded() * calorieStep
                    if abs(stepped - calorieAmount) > 0.01 {
                        calorieAmount = stepped
                    }
                }

                Button {
                    calorieAmount = min(maxCalories, calorieAmount + calorieStep)
                    calorieValueFocused = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)

            Spacer(minLength: 0)

            Button(action: {
                healthManager.addFood(category: selectedCategory, calories: Int(calorieAmount))
                dismiss()
            }) {
                Text("Save Meal")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .tint(.orange)
            .buttonBorderShape(.capsule)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
        .navigationTitle("Meal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    FoodLogView(healthManager: HealthManager())
}
