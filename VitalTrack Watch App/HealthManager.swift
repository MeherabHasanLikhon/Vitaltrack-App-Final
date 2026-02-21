import Foundation
import SwiftUI
import Combine
import WidgetKit

private enum AppGroup {
    static let suiteName = "group.com.rajonpt.VitalTrack"

    static var defaults: UserDefaults {
        UserDefaults(suiteName: suiteName) ?? .standard
    }
}

// Model for a single food entry
struct FoodEntry: Identifiable, Codable {
    let id: UUID
    let category: String
    let calories: Int
    let timestamp: Date
}

class HealthManager: ObservableObject {
    static let shared = HealthManager()
    
    // Published properties to update UI
    @Published var waterIntake: Double = 0.0
    @Published var waterTarget: Double = 2500.0 // Default 2.5L
    @Published var calorieTotal: Int = 0
    @Published var foodEntries: [FoodEntry] = []
    @Published private(set) var previousDayWater: Double = 0.0
    @Published private(set) var historicalWaterTotal: Double = 0.0
    @Published private(set) var historicalDayCount: Int = 0
    
    // Keys for UserDefaults
    private let kWaterIntake = "waterIntake"
    private let kWaterTarget = "waterTarget"
    private let kCalorieTotal = "calorieTotal"
    private let kFoodEntries = "foodEntries"
    private let kLastSavedDate = "lastSavedDate"
    private let kPreviousDayWater = "previousDayWater"
    private let kHistoricalWaterTotal = "historicalWaterTotal"
    private let kHistoricalDayCount = "historicalDayCount"
    
    init() {
        loadData()
        checkMidnightReset()
    }
    
    // MARK: - Data Loading & Saving
    
    private func loadData() {
        let defaults = AppGroup.defaults

        waterIntake = defaults.double(forKey: kWaterIntake)

        // Load target (default to 2500 if not set)
        let savedTarget = defaults.double(forKey: kWaterTarget)
        waterTarget = savedTarget > 0 ? savedTarget : 2500.0

        calorieTotal = defaults.integer(forKey: kCalorieTotal)
        previousDayWater = defaults.double(forKey: kPreviousDayWater)
        historicalWaterTotal = defaults.double(forKey: kHistoricalWaterTotal)
        historicalDayCount = defaults.integer(forKey: kHistoricalDayCount)
        
        if let savedFoodData = defaults.data(forKey: kFoodEntries) {
            if let decodedEntries = try? JSONDecoder().decode([FoodEntry].self, from: savedFoodData) {
                foodEntries = decodedEntries
            }
        }
    }
    
    private func saveData() {
        let defaults = AppGroup.defaults
        defaults.set(waterIntake, forKey: kWaterIntake)
        defaults.set(waterTarget, forKey: kWaterTarget)
        defaults.set(calorieTotal, forKey: kCalorieTotal)
        defaults.set(Date(), forKey: kLastSavedDate)
        defaults.set(previousDayWater, forKey: kPreviousDayWater)
        defaults.set(historicalWaterTotal, forKey: kHistoricalWaterTotal)
        defaults.set(historicalDayCount, forKey: kHistoricalDayCount)
        
        if let encodedFood = try? JSONEncoder().encode(foodEntries) {
            defaults.set(encodedFood, forKey: kFoodEntries)
        }
        
        // Update Widget
        WidgetCenter.shared.reloadAllTimelines()
        NotificationManager.shared.scheduleHydrationReminderIfNeeded(waterIntake: waterIntake, target: waterTarget)
    }
    
    // MARK: - Midnight Reset Logic
    
    func checkMidnightReset() {
        let defaults = AppGroup.defaults
        let lastSaved = defaults.object(forKey: kLastSavedDate) as? Date ?? Date.distantPast

        let calendar = Calendar.current
        if !calendar.isDateInToday(lastSaved) {
            // It's a new day (or first run), reset counters
            // Ideally, we could archive yesterday's data here if historical tracking was required.
            previousDayWater = waterIntake
            historicalWaterTotal += waterIntake
            historicalDayCount += 1
            
            waterIntake = 0.0
            calorieTotal = 0
            foodEntries = []
            
            saveData()
        }
    }
    
    // MARK: - Actions
    
    func addWater(amount: Double) {
        waterIntake += amount
        saveData()
    }
    
    func addFood(category: String, calories: Int) {
        let newEntry = FoodEntry(id: UUID(), category: category, calories: calories, timestamp: Date())
        foodEntries.append(newEntry)
        calorieTotal += calories
        saveData()
    }
    
    func resetDailyData() {
        waterIntake = 0.0
        calorieTotal = 0
        foodEntries = []
        saveData()
    }

    func updateWaterTarget(to newValue: Double) {
        let clamped = min(max(newValue, 800), 6000)
        waterTarget = clamped
        saveData()
    }

    var averageWater: Double {
        guard historicalDayCount > 0 else { return 0 }
        return historicalWaterTotal / Double(historicalDayCount)
    }
}
