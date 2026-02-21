import SwiftUI

struct WaterLogView: View {
    @ObservedObject var healthManager: HealthManager
    @Environment(\.dismiss) var dismiss
    
    @State private var amountToAdd: Double = 250.0
    
    var body: some View {
        VStack {
            Spacer()
            
            // Native Gauge for visual feedback
            Gauge(value: amountToAdd, in: 0...1000) {
                Text("Volume")
                    .font(.caption2)
            } currentValueLabel: {
                Text("\(Int(amountToAdd))")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(.cyan)
            } minimumValueLabel: {
                Text("0")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } maximumValueLabel: {
                Text("1L")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .gaugeStyle(.accessoryCircular) // The circular gauge style common on watch faces
            .scaleEffect(1.5) // Slightly larger for emphasis
            .tint(Gradient(colors: [.cyan, .blue]))
            
            Spacer()
            
            // Stepper is hidden but drives the Digital Crown
            Stepper(value: $amountToAdd, in: 50...1000, step: 50) {
                EmptyView()
            }
            .labelsHidden()
            .digitalCrownRotation($amountToAdd, from: 50, through: 1000, by: 50, sensitivity: .low, isContinuous: false, isHapticFeedbackEnabled: true)
            
            // Add Button
            Button(action: {
                healthManager.addWater(amount: amountToAdd)
                dismiss()
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Water")
                }
                .fontWeight(.medium)
            }
            .tint(.cyan)
            .buttonBorderShape(.capsule)
            .padding(.horizontal)
        }
    }
}

#Preview {
    WaterLogView(healthManager: HealthManager())
}