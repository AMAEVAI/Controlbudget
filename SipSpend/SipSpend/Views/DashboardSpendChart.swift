import SwiftUI
import Charts

struct DashboardSpendChart: View {
    let points: [DailySpendPoint]

    @State private var barsVisible = false

    private var maxAmount: Double {
        max(points.map(\.amount).max() ?? 0, 1)
    }

    var body: some View {
        Chart(points) { point in
            BarMark(
                x: .value("Day", point.label),
                y: .value("Spent", barsVisible ? point.amount : 0)
            )
            .foregroundStyle(
                LinearGradient(
                    colors: [DS.Colors.accent, DS.Colors.accent.opacity(0.55)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(6)
        }
        .chartYScale(domain: 0 ... maxAmount * 1.15)
        .chartYAxis {
            AxisMarks(position: .leading) { value in
                AxisGridLine()
                AxisValueLabel {
                    if let amount = value.as(Double.self) {
                        Text(amount, format: .currency(code: "EUR").precision(.fractionLength(0)))
                            .font(.caption2)
                    }
                }
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel()
                    .font(.caption2)
            }
        }
        .frame(height: 168)
        .onAppear {
            withAnimation(DS.Motion.chartSpring) {
                barsVisible = true
            }
        }
        .onChange(of: points.map(\.amount)) { _, _ in
            barsVisible = false
            withAnimation(DS.Motion.chartSpring) {
                barsVisible = true
            }
        }
    }
}

#Preview {
    DashboardSpendChart(points: [
        DailySpendPoint(date: .now, label: "Mon", amount: 12),
        DailySpendPoint(date: .now, label: "Tue", amount: 4),
        DailySpendPoint(date: .now, label: "Wed", amount: 0),
    ])
    .padding()
}
