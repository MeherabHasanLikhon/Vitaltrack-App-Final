import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    private let suiteName = "group.com.rajonpt.VitalTrack"

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), waterIntake: 1200, waterTarget: 2500, calorieTotal: 450)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = fetchCurrentEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = fetchCurrentEntry(date: Date())
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func fetchCurrentEntry(date: Date) -> SimpleEntry {
        let defaults = UserDefaults(suiteName: suiteName)
        let intake = defaults?.double(forKey: "waterIntake") ?? 0
        let target = defaults?.double(forKey: "waterTarget") ?? 2500
        let calories = defaults?.integer(forKey: "calorieTotal") ?? 0
        
        return SimpleEntry(
            date: date,
            waterIntake: intake,
            waterTarget: target > 0 ? target : 2500,
            calorieTotal: calories
        )
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let waterTarget: Double
    let calorieTotal: Int
}

struct VitalTrackWidgetEntryView : View {
    @Environment(\.widgetFamily) var family
    var entry: Provider.Entry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularView(entry: entry)
        case .accessoryRectangular:
            RectangularView(entry: entry)
        case .accessoryCorner:
            CornerView(entry: entry)
        case .accessoryInline:
            InlineView(entry: entry)
        default:
            CircularView(entry: entry)
        }
    }
}

// MARK: - Subviews

struct CircularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        Gauge(value: entry.waterIntake, in: 0...entry.waterTarget) {
            Image(systemName: "drop.fill")
                .foregroundColor(.cyan)
        } currentValueLabel: {
            Text("\(Int(entry.waterIntake))")
                .font(.system(size: 10, weight: .bold))
        }
        .gaugeStyle(.accessoryCircular)
        .tint(.cyan)
    }
}

struct RectangularView: View {
    let entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Water Section
            HStack {
                Image(systemName: "drop.fill")
                    .foregroundColor(.cyan)
                Text("\(Int(entry.waterIntake)) / \(Int(entry.waterTarget)) ml")
                    .font(.caption2)
                    .bold()
            }
            
            ProgressView(value: entry.waterIntake, total: entry.waterTarget)
                .progressViewStyle(.linear)
                .tint(.cyan)
            
            // Calorie Section
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(.orange)
                Text("\(entry.calorieTotal) kcal")
                    .font(.caption2)
                    .bold()
                Spacer()
            }
        }
    }
}

struct CornerView: View {
    let entry: SimpleEntry
    
    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Image(systemName: "drop.fill")
                .foregroundColor(.cyan)
                .font(.title3)
        }
        .widgetLabel {
            Gauge(value: entry.waterIntake, in: 0...entry.waterTarget) {
                Text("Water")
            } currentValueLabel: {
                Text("\(Int(entry.waterIntake))")
            }
            .tint(.cyan)
        }
    }
}

struct InlineView: View {
    let entry: SimpleEntry
    
    var body: some View {
        HStack {
            Image(systemName: "drop.fill")
            Text("\(Int(entry.waterIntake))ml")
            Text("|")
            Image(systemName: "flame.fill")
            Text("\(entry.calorieTotal)kcal")
        }
    }
}

struct VitalTrackWidget: Widget {
    let kind: String = "VitalTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(watchOS 10.0, *) {
                VitalTrackWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                VitalTrackWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("VitalTrack Summary")
        .description("Track your water and calorie progress.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner, .accessoryInline])
    }
}

#Preview(as: .accessoryRectangular) {
    VitalTrackWidget()
} timeline: {
    SimpleEntry(date: .now, waterIntake: 1200, waterTarget: 2500, calorieTotal: 450)
    SimpleEntry(date: .now, waterIntake: 1800, waterTarget: 2500, calorieTotal: 850)
}
