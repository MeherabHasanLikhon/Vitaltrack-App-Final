import SwiftUI
import WatchKit

struct ContentView: View {
    @StateObject private var healthManager = HealthManager()
    @State private var showingTargetEditor = false
    @State private var targetDraft: Double = 2500
    @State private var targetSavedMessage: String?
    @FocusState private var goalValueFocused: Bool

    private let minWaterGoal: Double = 800
    private let maxWaterGoal: Double = 6000
    private let waterGoalStep: Double = 50
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    // MARK: - Hero Progress Section
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Material.regular)
                        
                        HStack(spacing: 12) {
                            // Water Ring
                            ZStack {
                                Circle()
                                    .stroke(Color.cyan.opacity(0.2), lineWidth: 9)
                                
                                Circle()
                                    .trim(from: 0.0, to: CGFloat(min(healthManager.waterIntake / healthManager.waterTarget, 1.0)))
                                    .stroke(
                                        AngularGradient(
                                            gradient: Gradient(colors: [.cyan, .blue]),
                                            center: .center
                                        ),
                                        style: StrokeStyle(lineWidth: 9, lineCap: .round)
                                    )
                                    .rotationEffect(Angle(degrees: 270.0))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: healthManager.waterIntake)
                                
                                VStack(spacing: 0) {
                                    Image(systemName: "drop.fill")
                                        .font(.system(size: 10))
                                        .foregroundStyle(.cyan)
                                    Text("\(Int(healthManager.waterIntake))")
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                        .minimumScaleFactor(0.7)
                                        .lineLimit(1)
                                }
                                .padding(4)
                            }
                            .frame(width: 72, height: 72)
                            
                            // Stats Column - Fixed alignment and truncation
                            VStack(alignment: .leading, spacing: 4) {
                                // Water Goal
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("WATER GOAL")
                                        .font(.system(size: 8, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                    Text("\(Int(healthManager.waterTarget)) ml")
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(.white.opacity(0.9))
                                }
                                
                                Divider()
                                    .background(Color.white.opacity(0.15))
                                    .padding(.vertical, 2)
                                
                                // Calories
                                VStack(alignment: .leading, spacing: 0) {
                                    Text("CALORIES")
                                        .font(.system(size: 8, weight: .bold, design: .rounded))
                                        .foregroundStyle(.secondary)
                                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                                        Text("\(healthManager.calorieTotal)")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                            .foregroundStyle(.orange)
                                            .minimumScaleFactor(0.6) // Prevents "1,0..." truncation
                                            .lineLimit(1)
                                        
                                        Text("kcal")
                                            .font(.system(size: 9, weight: .medium, design: .rounded))
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                    .frame(height: 110)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Yesterday")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(Int(healthManager.previousDayWater)) ml")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        Divider()
                            .frame(height: 34)
                            .background(Color.white.opacity(0.25))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Average")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(Int(healthManager.averageWater)) ml")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                        }
                        Divider()
                            .frame(height: 34)
                            .background(Color.white.opacity(0.25))
                        VStack(alignment: .leading, spacing: 1) {
                            Text("Delta")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                            Text("\(Int(healthManager.waterIntake - healthManager.previousDayWater)) ml")
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .foregroundStyle(healthManager.waterIntake >= healthManager.previousDayWater ? .cyan : .orange)
                        }
                        Spacer()
                    }
                    
                    // MARK: - Quick Actions
                    HStack(spacing: 8) {
                        NavigationLink(destination: WaterLogView(healthManager: healthManager)) {
                            VStack(spacing: 4) {
                                Image(systemName: "drop.fill")
                                    .font(.title3)
                                Text("Water")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.cyan.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        NavigationLink(destination: FoodLogView(healthManager: healthManager)) {
                            VStack(spacing: 4) {
                                Image(systemName: "fork.knife")
                                    .font(.title3)
                                Text("Meal")
                                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.orange.opacity(0.15))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }

                    Button(action: {
                        let current = healthManager.waterTarget
                        targetDraft = (current / waterGoalStep).rounded() * waterGoalStep
                        showingTargetEditor = true
                    }) {
                        HStack {
                            Image(systemName: "target"
                            )
                            Text("Adjust Goal")
                                .font(.system(size: 11, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green.opacity(0.15))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    }
                    .buttonStyle(.plain)

                    // MARK: - Recent History
                    if !healthManager.foodEntries.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("RECENT")
                                .font(.system(size: 9, weight: .bold, design: .rounded))
                                .foregroundStyle(.secondary)
                                .padding(.leading, 4)
                            
                            ForEach(healthManager.foodEntries.suffix(2).reversed()) { entry in
                                HStack {
                                    Text(entry.category)
                                        .font(.system(size: 12, weight: .medium, design: .rounded))
                                    Spacer()
                                    Text("\(entry.calories) kcal")
                                        .font(.system(size: 10, design: .rounded))
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(Material.ultraThin)
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
            }
            .navigationTitle("VitalTrack")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                healthManager.checkMidnightReset()
                NotificationManager.shared.requestPermission()
                NotificationManager.shared.scheduleHydrationReminderIfNeeded(waterIntake: healthManager.waterIntake, target: healthManager.waterTarget)
            }
            .sheet(isPresented: $showingTargetEditor) {
                NavigationStack {
                    VStack(spacing: 10) {
                        Spacer(minLength: 0)

                        HStack(alignment: .center, spacing: 12) {
                            Button {
                                targetDraft = max(minWaterGoal, targetDraft - waterGoalStep)
                                goalValueFocused = true
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.cyan)
                            }
                            .buttonStyle(.plain)

                            ZStack {
                                Color.clear
                                VStack(spacing: 2) {
                                    Text(String(Int(targetDraft)))
                                        .font(.system(size: 46, weight: .bold, design: .rounded))
                                        .foregroundStyle(.cyan)
                                        .monospacedDigit()
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                    Text("ml")
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .contentShape(Rectangle())
                            .focusable(true)
                            .focused($goalValueFocused)
                            .digitalCrownRotation($targetDraft, from: minWaterGoal, through: maxWaterGoal, by: waterGoalStep, sensitivity: .medium, isContinuous: true, isHapticFeedbackEnabled: true)
                            .onTapGesture { goalValueFocused = true }
                            .onAppear { DispatchQueue.main.async { goalValueFocused = true } }
                            .onChange(of: targetDraft) { _, newValue in
                                let clamped = min(max(newValue, minWaterGoal), maxWaterGoal)
                                let stepped = (clamped / waterGoalStep).rounded() * waterGoalStep
                                if abs(stepped - targetDraft) > 0.01 {
                                    targetDraft = stepped
                                }
                            }

                            Button {
                                targetDraft = min(maxWaterGoal, targetDraft + waterGoalStep)
                                goalValueFocused = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                                    .foregroundStyle(.cyan)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, 10)

                        Spacer(minLength: 0)

                        Button(action: {
                            healthManager.updateWaterTarget(to: targetDraft)
                            targetSavedMessage = "Goal saved: \(Int(targetDraft)) ml"
                            WKInterfaceDevice.current().play(.success)
                            showingTargetEditor = false
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                targetSavedMessage = nil
                            }
                        }) {
                            Text("Save Goal")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .tint(.cyan)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                    .padding(.top, 2)
                    .navigationTitle("Water Goal")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
            .overlay(
                Group {
                    if let message = targetSavedMessage {
                        Text(message)
                            .font(.footnote)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.ultraThinMaterial, in: Capsule())
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .animation(.easeInOut, value: targetSavedMessage)
                    }
                }, alignment: .bottom
            )
        }
    }
}

#Preview {
    ContentView()
}
