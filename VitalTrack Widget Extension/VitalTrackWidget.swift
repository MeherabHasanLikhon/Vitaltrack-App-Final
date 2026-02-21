import WidgetKit
import SwiftUI

struct VitalTrackEntry: TimelineEntry {
    let date: Date
    let waterIntake: Double
    let waterTarget: Double
    let calorieTotal: Int
}

struct VitalTrackProvider: TimelineProvider {
    func placeholder(in context: Context) -> VitalTrackEntry {
        VitalTrackEntry(date: Date(), waterIntake: 1200, waterTarget: 2500, calorieTotal: 600)
    }

    func getSnapshot(in context: Context, completion: @escaping (VitalTrackEntry) -> Void) {
        completion(fetchCurrentEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<VitalTrackEntry>) -> Void) {
        let entry = fetchCurrentEntry()
        let nextRefresh = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextRefresh))
        completion(timeline)
    }

    private func fetchCurrentEntry() -> VitalTrackEntry {
        let defaults = AppGroup.defaults
        let waterIntake = defaults.double(forKey: "waterIntake")
        let savedTarget = defaults.double(forKey: "waterTarget")
        let waterTarget = savedTarget > 0 ? savedTarget : 2500
        let calorieTotal = defaults.integer(forKey: "calorieTotal")

        return VitalTrackEntry(
            date: Date(),
            waterIntake: waterIntake,
            waterTarget: waterTarget,
            calorieTotal: calorieTotal
        )
    }
}

struct VitalTrackWidgetEntryView: View {
    var entry: VitalTrackEntry

    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .foregroundStyle(.cyan)
                    .font(.caption2)
                Text("\(Int(entry.waterIntake)) ml")
                    .font(.caption2)
                    .fontWeight(.semibold)
            }

            ProgressView(value: entry.waterIntake, total: entry.waterTarget)
                .progressViewStyle(CircularProgressViewStyle(tint: .cyan))
                .scaleEffect(0.65)

            HStack(spacing: 2) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                    .font(.caption2)
                Text("\(entry.calorieTotal) kcal")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.orange)
            }
        }
        .padding(8)
    }
}

struct VitalTrackWidget: Widget {
    let kind: String = "VitalTrackWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: VitalTrackProvider()) { entry in
            VitalTrackWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("VitalTrack")
        .description("Water intake and calories for today.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryCorner])
    }
}

@main
struct VitalTrackWidgetBundle: WidgetBundle {
    var body: some Widget {
        VitalTrackWidget()
    }
}
