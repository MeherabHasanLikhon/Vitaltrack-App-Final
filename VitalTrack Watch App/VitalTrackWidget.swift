import WidgetKit
import SwiftUI

// NOTE: This file would typically be part of a separate "Widget Extension" target.
// For the data to be shared between the App and the Widget, you must:
// 1. Enable "App Groups" capability in both targets.
// 2. Use UserDefaults(suiteName: "group.your.id") instead of .standard.
// For this prototype, we read from standard defaults, which may not sync perfectly 
// without the App Group setup in a real device environment.

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), waterIntake: 1250, waterTarget: 2500, calorieTotal: 500)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), waterIntake: 1250, waterTarget: 2500, calorieTotal: 500)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Fetch data from UserDefaults (mirroring HealthManager logic)
        let defaults = UserDefaults.standard
        let waterIntake = defaults.double(forKey: "waterIntake")
        // Default target 2500 if 0
        let savedTarget = defaults.double(forKey: "waterTarget")
        let waterTarget = savedTarget > 0 ? savedTarget : 2500.0
        let calorieTotal = defaults.integer(forKey: "calorieTotal")
        
        // Create an entry for "now"
        let entry = SimpleEntry(
            date: Date(),
            waterIntake: waterIntake,
            waterTarget: waterTarget,
            calorieTotal: calorieTotal
        )

        // Refresh the widget every 15 minutes or when reloaded by the app
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let waterTarget: Double
    let calorieTotal: Int
}

struct VitalTrackWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack(spacing: 4) {
            // Simple visual summary
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
                    .font(.caption2)
                Text("\(Int(entry.waterIntake))")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.cyan)
            }
            
            ProgressView(value: entry.waterIntake, total: entry.waterTarget)
                .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                .scaleEffect(0.6)
            
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.caption2)
                Text("\(entry.calorieTotal)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundStyle(.orange)
            }
        }
    }
}

// @main // Uncomment this if you move this file to a separate Widget Extension target
struct VitalTrackWidget: Widget {
    let kind: String = "VitalTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            VitalTrackWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Vital Track")
        .description("Track your daily water and calories.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

#Preview(as: .accessoryRectangular) {
    VitalTrackWidget()
} timeline: {
    SimpleEntry(date: .now, waterIntake: 1500, waterTarget: 2500, calorieTotal: 1200)
}
