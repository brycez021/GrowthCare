import SwiftUI

struct ScheduleView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            let contentWidth = GCLayout.contentWidth(for: proxy.size.width)
            let metrics = ScheduleLayout.metrics(for: contentWidth)

            ZStack(alignment: .bottom) {
                Color.white.ignoresSafeArea()

                VStack(spacing: 0) {
                    Color.clear.frame(height: GCLayout.topSwitcherY)
                    profileRow
                    tableHeader(metrics: metrics)
                    scheduleScroll(bottomInset: proxy.safeAreaInsets.bottom, metrics: metrics)
                }
                .frame(width: contentWidth)
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(edges: .top)

                BottomNavShadow()

                BottomTabBar(bottomInset: proxy.safeAreaInsets.bottom)
            }
        }
    }

    private var profileRow: some View {
        HStack {
            ChildSwitcher()
            Spacer()
        }
        .frame(height: GCLayout.childSwitcherHeight)
        .padding(.horizontal, 20)
        .background(Color.white)
    }

    private func tableHeader(metrics: ScheduleLayoutMetrics) -> some View {
        HStack(spacing: 0) {
            Text("年龄")
                .font(.system(size: 16))
                .foregroundColor(ScheduleColor.text)
                .frame(width: metrics.ageColumn, alignment: .leading)
                .padding(.leading, metrics.ageLabelLeading)

            Text("疫苗种类")
                .font(.system(size: 16))
                .foregroundColor(ScheduleColor.text)
                .frame(width: metrics.vaccineGridWidth, alignment: .center)
        }
        .frame(height: 38, alignment: .bottom)
        .frame(width: metrics.totalWidth, alignment: .leading)
        .padding(.bottom, 8)
        .background(Color.white)
        .overlay(alignment: .bottom) {
            Divider().background(ScheduleColor.grid)
        }
    }

    private func scheduleScroll(bottomInset: CGFloat, metrics: ScheduleLayoutMetrics) -> some View {
        ScrollView(showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                Rectangle()
                    .fill(ScheduleColor.band)
                    .frame(width: metrics.bandWidth)
                    .offset(x: metrics.bandX)
                    .frame(maxHeight: .infinity)

                VStack(spacing: 0) {
                    ForEach(ScheduleData.rows) { row in
                        ScheduleRowView(
                            row: row,
                            highlighted: row.age == highlightedAge,
                            metrics: metrics,
                            isDone: isDone
                        )
                    }
                }
            }
            .frame(width: metrics.totalWidth, alignment: .leading)
            .padding(.bottom, BottomTabBar.reservedHeight(for: bottomInset) + 16)
        }
    }

    private var highlightedAge: String? {
        let parts = store.activeChildAgeParts()
        if parts.months == 0 && parts.days == 0 {
            return "24小时内"
        }

        var match: String?
        for row in ScheduleData.rows {
            if row.monthOffset <= parts.months {
                match = row.age
            }
        }

        if parts.days > 0,
           let next = ScheduleData.rows.first(where: { $0.monthOffset == parts.months + 1 }) {
            return next.age
        }

        return match
    }

    private func isDone(_ pill: SchedulePill) -> Bool {
        guard let vaccineName = pill.homeVaccineName else { return false }
        return store.isDoseDone(vaccineName: vaccineName, doseNumber: pill.doseNumber)
    }
}

private struct ScheduleRowView: View {
    let row: ScheduleRow
    let highlighted: Bool
    let metrics: ScheduleLayoutMetrics
    let isDone: (SchedulePill) -> Bool

    var body: some View {
        HStack(spacing: 0) {
            Text(row.age)
                .font(.system(size: 14))
                .foregroundColor(ScheduleColor.text)
                .multilineTextAlignment(.center)
                .frame(width: metrics.ageColumn)
                .frame(minHeight: row.height)
                .background(highlighted ? ScheduleColor.highlightAge : ScheduleColor.ageColumn)

            ZStack(alignment: .topLeading) {
                if highlighted {
                    ScheduleColor.highlightVaccine
                }

                ForEach(row.vaccines) { pill in
                    SchedulePillView(pill: pill, done: isDone(pill), metrics: metrics)
                        .offset(
                            x: metrics.leftInset + CGFloat(pill.column) * (metrics.pillWidth + metrics.columnGap),
                            y: CGFloat(pill.row) * metrics.pillHeight
                        )
                }
            }
            .frame(width: metrics.vaccineGridWidth, alignment: .topLeading)
            .frame(minHeight: row.height, alignment: .topLeading)
        }
        .frame(width: metrics.totalWidth, alignment: .leading)
        .overlay(alignment: .bottom) {
            Divider().background(ScheduleColor.grid)
        }
    }
}

private struct SchedulePillView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let pill: SchedulePill
    let done: Bool
    let metrics: ScheduleLayoutMetrics

    var body: some View {
        Button {
            if let vaccineName = pill.homeVaccineName {
                store.openVaccineDetail(vaccineName)
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(pill.dashed ? Color.white : pill.color)
                    .overlay {
                        if pill.dashed {
                            RoundedRectangle(cornerRadius: 15, style: .continuous)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [6, 4]))
                                .foregroundColor(Color(hex: 0xCCCCCC))
                        }
                    }

                Text(pill.name)
                    .font(.system(size: metrics.pillFontSize))
                    .foregroundColor(ScheduleColor.text)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.88)
                    .padding(.horizontal, metrics.pillTextPadding)

                if done {
                    Capsule()
                        .fill(Color.white)
                        .frame(height: 2)
                        .padding(.horizontal, 6)
                }
            }
            .frame(width: metrics.pillWidth, height: metrics.pillHeight)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(pill.name)
    }
}

private struct ScheduleLayoutMetrics {
    let totalWidth: CGFloat
    let ageColumn: CGFloat
    let vaccineGridWidth: CGFloat
    let leftInset: CGFloat
    let rightInset: CGFloat
    let columnGap: CGFloat
    let pillWidth: CGFloat
    let pillHeight: CGFloat

    var ageLabelLeading: CGFloat {
        min(22, max(14, ageColumn * 0.27))
    }

    var pillFontSize: CGFloat {
        if pillWidth < 88 { return 11.5 }
        if pillWidth < 98 { return 12.5 }
        if pillWidth < 108 { return 13 }
        return 14
    }

    var pillTextPadding: CGFloat {
        pillWidth < 98 ? 4 : 8
    }

    var bandX: CGFloat {
        ageColumn + leftInset + pillWidth + columnGap / 2
    }

    var bandWidth: CGFloat {
        pillWidth + columnGap
    }
}

private enum ScheduleLayout {
    static let pillHeight: CGFloat = 42
    static let columnGap: CGFloat = 4
    static let leftInset: CGFloat = 3
    static let rightInset: CGFloat = 4

    static func metrics(for totalWidth: CGFloat) -> ScheduleLayoutMetrics {
        let normalizedWidth = max(320, totalWidth)
        let ageColumn = min(80, max(60, floor(normalizedWidth * 0.19)))
        let vaccineGridWidth = max(0, totalWidth - ageColumn)
        let availableForPills = max(
            0,
            vaccineGridWidth - leftInset - rightInset - columnGap * 2
        )
        let pillWidth = floor(availableForPills / 3)

        return ScheduleLayoutMetrics(
            totalWidth: totalWidth,
            ageColumn: ageColumn,
            vaccineGridWidth: vaccineGridWidth,
            leftInset: leftInset,
            rightInset: rightInset,
            columnGap: columnGap,
            pillWidth: pillWidth,
            pillHeight: pillHeight
        )
    }
}

private enum ScheduleColor {
    static let text = Color(hex: 0x3C3C3C)
    static let grid = Color(hex: 0xD5CBBF)
    static let ageColumn = Color(hex: 0xF4F1EC).opacity(0.6)
    static let band = Color(hex: 0xF4F1EC).opacity(0.6)
    static let highlightAge = Color(hex: 0xFFE9E9)
    static let highlightVaccine = Color(hex: 0xFFF0F0)
}

private struct ScheduleRow: Identifiable {
    let age: String
    let height: CGFloat
    let vaccines: [SchedulePill]

    var id: String { age }
    var monthOffset: Int {
        if age == "24小时内" { return 0 }
        if age.hasSuffix("月龄") {
            return Int(age.dropLast(2)) ?? -1
        }
        if age.hasSuffix("岁") {
            return (Int(age.dropLast()) ?? -1) * 12
        }
        return -1
    }
}

private struct SchedulePill: Identifiable {
    let name: String
    let color: Color
    let dashed: Bool
    let column: Int
    let row: Int

    var id: String { "\(name)-\(column)-\(row)" }

    var doseNumber: Int {
        let pattern = #"(\d+)\s*/\s*\d+"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: name, range: NSRange(name.startIndex..., in: name)),
              let range = Range(match.range(at: 1), in: name) else {
            return 1
        }
        return Int(name[range]) ?? 1
    }

    var homeVaccineName: String? {
        if name.contains("卡介") { return "卡介苗" }
        if name.contains("乙肝疫苗") { return "乙肝疫苗" }
        if name.contains("脊灰疫苗") || name.contains("脊髓灰质炎") { return "脊髓灰质炎疫苗" }
        if name.contains("白破疫苗") { return "白破疫苗" }
        if name.contains("百白破") || name.contains("白破疫苗") { return "百白破疫苗" }
        if name.contains("A群流脑") || name.contains("A群脑流") { return "A群脑流疫苗" }
        if name.contains("A+C结合流脑") { return "A+C结合流脑疫苗" }
        if name.contains("AC流脑多糖") { return "AC流脑多糖疫苗" }
        if name.contains("ACYW135") { return "ACYW135多糖疫苗" }
        if name.contains("麻腮风") { return "麻腮风疫苗" }
        if name.contains("乙脑减毒") { return "乙脑减毒疫苗" }
        if name.contains("乙脑灭活") { return "乙脑灭活疫苗" }
        if name.contains("甲肝减毒") { return "甲肝减毒疫苗" }
        if name.contains("甲肝灭活") { return "甲肝灭活疫苗" }
        if name.contains("五联疫苗") { return "五联疫苗" }
        if name.contains("五价轮状") { return "五价轮状疫苗" }
        if name.contains("13价肺炎") { return "13价肺炎疫苗" }
        if name.contains("手足口") { return "手足口疫苗" }
        if name.contains("水痘疫苗") { return "水痘疫苗" }
        if name.contains("流感") { return "流感疫苗" }
        return nil
    }
}

private enum ScheduleData {
    static let rows: [ScheduleRow] = [
        row("24小时内", 42, [
            pill("乙肝疫苗1/3", .pink, 0, 0),
            pill("卡介疫苗", .yellow, 1, 0)
        ]),
        row("1月龄", 42, [pill("乙肝疫苗2/3", .pink, 0, 0)]),
        row("2月龄", 84, [
            pill("脊灰疫苗1/4", .mint, 0, 0),
            pill("百白破1/4", .peach, 1, 0),
            dashed("五联疫苗1/4", 0, 1),
            dashed("五价轮状1/3", 1, 1),
            dashed("13价肺炎1/4", 2, 1)
        ]),
        row("3月龄", 84, [
            pill("脊灰疫苗2/4", .mint, 0, 0),
            dashed("五联疫苗2/4", 0, 1),
            dashed("五价轮状2/3", 1, 1)
        ]),
        row("4月龄", 84, [
            pill("脊灰疫苗3/4", .mint, 0, 0),
            pill("百白破2/4", .peach, 1, 0),
            dashed("五联疫苗3/4", 0, 1),
            dashed("五价轮状1/3", 1, 1),
            dashed("13价肺炎2/4", 2, 1)
        ]),
        row("6月龄", 84, [
            pill("乙肝疫苗3/3", .pink, 0, 0),
            pill("百白破3/4", .peach, 1, 0),
            pill("A群流脑1/2", .lightPink, 2, 0),
            dashed("A+C结合流脑1/2", 0, 1),
            dashed("手足口1/2", 1, 1),
            dashed("13价肺炎3/4", 2, 1)
        ]),
        row("7月龄", 42, [dashed("手足口1/2", 1, 0)]),
        row("8月龄", 42, [
            pill("麻腮风1/2", .cyan, 0, 0),
            pill("乙脑减毒1/2", .lightGreen, 1, 0)
        ]),
        row("9月龄", 84, [
            pill("A群流脑2/2", .lightPink, 2, 0),
            dashed("A+C结合流脑1/2", 0, 1)
        ]),
        row("12月龄", 42, [
            dashed("水痘疫苗1/2", 1, 0),
            dashed("13价肺炎4/4", 2, 0)
        ]),
        row("18月龄", 84, [
            pill("麻腮风2/2", .cyan, 0, 0),
            pill("百白破4/4", .peach, 1, 0),
            pill("甲肝灭活1/2", .blue, 2, 0),
            dashed("五联疫苗4/4", 0, 1),
            dashed("甲肝减毒", 2, 1)
        ]),
        row("2岁", 42, [
            pill("乙脑减毒2/2", .lightGreen, 1, 0),
            pill("甲肝灭活2/2", .blue, 2, 0)
        ]),
        row("3岁", 84, [
            pill("AC流脑多糖1/2", .purple, 0, 0),
            dashed("ACYW135多糖1/2", 0, 1)
        ]),
        row("4岁", 84, [
            pill("脊灰疫苗4/4", .mint, 0, 0),
            dashed("水痘疫苗2/2", 1, 1)
        ]),
        row("6岁", 85, [
            pill("AC流脑多糖2/2", .purple, 0, 0),
            pill("白破疫苗", .peach, 1, 0),
            dashed("ACYW135多糖2/2", 0, 1)
        ])
    ]

    private static func row(_ age: String, _ height: CGFloat, _ vaccines: [SchedulePill]) -> ScheduleRow {
        ScheduleRow(age: age, height: height, vaccines: vaccines)
    }

    private static func pill(_ name: String, _ color: PillColor, _ column: Int, _ row: Int) -> SchedulePill {
        SchedulePill(name: name, color: color.color, dashed: false, column: column, row: row)
    }

    private static func dashed(_ name: String, _ column: Int, _ row: Int) -> SchedulePill {
        SchedulePill(name: name, color: .white, dashed: true, column: column, row: row)
    }
}

private enum PillColor {
    case pink, yellow, mint, peach, lightPink, cyan, blue, purple, lightGreen

    var color: Color {
        switch self {
        case .pink: return Color(hex: 0xFFB7B2)
        case .yellow: return Color(hex: 0xF8E9A1)
        case .mint: return Color(hex: 0xB5EAD7)
        case .peach: return Color(hex: 0xFBE7C6)
        case .lightPink: return Color(hex: 0xFDE2E4)
        case .cyan: return Color(hex: 0xD4F0F0)
        case .blue: return Color(hex: 0xA0E7E5)
        case .purple: return Color(hex: 0xDCD6F7)
        case .lightGreen: return Color(hex: 0xE2F0CB)
        }
    }
}

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView()
            .environmentObject(GrowthCareStore())
    }
}
