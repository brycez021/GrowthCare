import SwiftUI

struct GrowthRecordsView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var showsAddRecordOverlay = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                GrowthRecordColor.page.ignoresSafeArea()

                VStack(spacing: 0) {
                    header()
                    GrowthRecordsTimeline(bottomInset: proxy.safeAreaInsets.bottom) {
                        showsAddRecordOverlay = true
                    }
                }
                .ignoresSafeArea(edges: .top)

                BottomTabBar(bottomInset: proxy.safeAreaInsets.bottom)

                if showsAddRecordOverlay {
                    GrowthRecordAddOverlay {
                        showsAddRecordOverlay = false
                    }
                    .transition(.opacity)
                    .zIndex(30)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: showsAddRecordOverlay)
        .navigationBarBackButtonHidden(true)
        .alert("提示", isPresented: toastBinding) {
            Button("好", role: .cancel) {
                store.toastMessage = nil
            }
        } message: {
            Text(store.toastMessage ?? "")
        }
    }

    private var toastBinding: Binding<Bool> {
        Binding(
            get: { store.toastMessage != nil },
            set: { if !$0 { store.toastMessage = nil } }
        )
    }

    private func header() -> some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Color.clear.frame(height: GCLayout.topSwitcherY)

                HStack {
                    ChildSwitcher()
                    Spacer()
                }
                .frame(height: GCLayout.childSwitcherHeight)
                .padding(.horizontal, 20)

                Spacer(minLength: 0)

                recordTabs
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
        .frame(height: GCLayout.growthRecordsTopBandHeight)
    }

    private var recordTabs: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xFFF0EB).opacity(0.6),
                            Color(hex: 0xFFF0EB).opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                )

            HStack(spacing: 0) {
                Button {
                    store.popNavigation()
                } label: {
                    Text("曲线")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: GCLayout.growthSegmentButtonHeight)
                }
                .buttonStyle(.plain)

                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4)

                    Text("记录")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: GCLayout.growthSegmentButtonHeight)
            }
            .padding(.horizontal, 4)
            .frame(height: GCLayout.growthSegmentHeight)
        }
        .frame(height: GCLayout.growthSegmentHeight)
    }
}

struct GrowthRecordsTimeline: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var openRecordID: String?

    let bottomInset: CGFloat
    let onAddRecord: () -> Void

    init(bottomInset: CGFloat, onAddRecord: @escaping () -> Void = {}) {
        self.bottomInset = bottomInset
        self.onAddRecord = onAddRecord
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                let records = store.activeGrowthRecords()
                ForEach(records) { record in
                    GrowthRecordTimelineRow(
                        record: record,
                        ageLabel: store.growthAgeLabel(for: record.date),
                        isOpen: openRecordID == record.id,
                        onOpen: { openRecordID = record.id },
                        onClose: {
                            if openRecordID == record.id {
                                openRecordID = nil
                            }
                        },
                        onDelete: {
                            openRecordID = nil
                            store.removeGrowthRecord(id: record.id)
                        }
                    )
                    .padding(.bottom, 24)
                }

                GrowthRecordAddTimelineItem(
                    ageLabel: store.growthAgeLabel(for: Date()),
                    action: {
                        openRecordID = nil
                        onAddRecord()
                    }
                )
            }
            .padding(.top, 16)
            .padding(.leading, 54)
            .padding(.trailing, 20)
            .padding(.bottom, BottomTabBar.reservedHeight(for: bottomInset) + 24)
        }
        .background(GrowthRecordColor.page)
    }
}

private struct GrowthRecordTimelineRow: View {
    let record: GrowthRecord
    let ageLabel: String
    let isOpen: Bool
    let onOpen: () -> Void
    let onClose: () -> Void
    let onDelete: () -> Void

    @State private var dragOffset: CGFloat = 0

    private var effectiveOffset: CGFloat {
        isOpen ? -110 + dragOffset : dragOffset
    }

    var body: some View {
        TimelineShell(showsLine: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text(ageLabel)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(height: 23, alignment: .leading)

                ZStack(alignment: .trailing) {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(Color(hex: 0xF0AD4E))
                            .frame(width: 110, height: 105)
                            .background(Color(hex: 0xFEF9E6))
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 20,
                                    topTrailingRadius: 20
                                )
                            )
                    }
                    .buttonStyle(.plain)

                    GrowthRecordCard(record: record)
                        .offset(x: effectiveOffset)
                        .gesture(
                            DragGesture(minimumDistance: 12)
                                .onChanged { value in
                                    let base: CGFloat = isOpen ? -110 : 0
                                    dragOffset = max(-110 - base, min(0 - base, value.translation.width))
                                }
                                .onEnded { value in
                                    let shouldOpen = (isOpen ? -110 : 0) + value.translation.width < -38
                                    dragOffset = 0
                                    if shouldOpen {
                                        onOpen()
                                    } else {
                                        onClose()
                                    }
                                }
                        )
                        .animation(.easeOut(duration: 0.24), value: isOpen)
                }
                .frame(minHeight: 105)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
        }
    }
}

private struct GrowthRecordCard: View {
    let record: GrowthRecord

    var body: some View {
        VStack(spacing: 14) {
            metricRow(asset: "height", label: "身高", value: String(format: "%.1fcm", record.height))
            metricRow(asset: "weight", label: "体重", value: String(format: "%.1fkg", record.weight))
        }
        .padding(.leading, 14)
        .padding(.trailing, 24)
        .padding(.vertical, 13)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 105)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func metricRow(asset: String, label: String, value: String) -> some View {
        HStack(spacing: 0) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .frame(width: 52, height: 36, alignment: .leading)

            Text(label)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .frame(width: 56, alignment: .leading)

            Spacer(minLength: 12)

            Text(value)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .frame(minWidth: 76, alignment: .trailing)
        }
        .frame(height: 36)
    }
}

private struct GrowthRecordAddTimelineItem: View {
    let ageLabel: String
    let action: () -> Void

    var body: some View {
        TimelineShell(showsLine: false) {
            VStack(alignment: .leading, spacing: 8) {
                Text(ageLabel)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(height: 23, alignment: .leading)

                Button(action: action) {
                    ZStack {
                        Color.white
                        GrowthAddIcon()
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 83)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct TimelineShell<Content: View>: View {
    let showsLine: Bool
    let content: Content

    init(showsLine: Bool, @ViewBuilder content: () -> Content) {
        self.showsLine = showsLine
        self.content = content()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            VStack(spacing: 4) {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color(hex: 0xD3D3D3))
                    .frame(width: 15, height: 15)
                    .padding(.top, 4)

                if showsLine {
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .fill(Color(hex: 0xD3D3D3))
                        .frame(width: 3, height: 122)
                }
            }
            .frame(width: 15)
            .offset(x: -29)

            content
                .frame(maxWidth: .infinity, alignment: .leading)
                .offset(x: -30)
        }
    }
}

private struct GrowthAddIcon: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color(hex: 0x464646))
                .frame(width: 30, height: 2.6)
            Capsule()
                .fill(Color(hex: 0x464646))
                .frame(width: 2.6, height: 30)
        }
        .frame(width: 30, height: 30)
    }
}

struct AddGrowthRecordView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            let bottomInset = proxy.safeAreaInsets.bottom

            ZStack {
                GrowthRecordAddBackdrop(bottomInset: bottomInset)
                    .allowsHitTesting(false)

                GrowthRecordAddOverlay {
                    store.popNavigation()
                }
            }
            .ignoresSafeArea()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct GrowthRecordAddOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var selectedDate = Date()
    @State private var height = 70.0
    @State private var weight = 4.0

    let dismiss: () -> Void

    private var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let birthDate = Calendar.current.startOfDay(for: store.activeChild.birthDate)
        return min(birthDate, today)...today
    }

    var body: some View {
        GeometryReader { proxy in
            let panelWidth = min(proxy.size.width * 0.90, 420)
            let panelHeight = min(proxy.size.height * 0.80, proxy.size.height - 92)

            ZStack {
                Color.black.opacity(0.30)
                    .ignoresSafeArea()
                    .onTapGesture {
                        dismiss()
                    }

                AddGrowthRecordPanel(
                    selectedDate: $selectedDate,
                    height: $height,
                    weight: $weight,
                    dateRange: dateRange,
                    save: save
                )
                .frame(width: panelWidth, height: panelHeight)
                .onTapGesture { }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            selectedDate = Calendar.current.startOfDay(for: Date())
            height = roundedMetric(height, step: 0.5, lower: 1, upper: 100)
            if let latest = store.activeGrowthRecords().last {
                weight = roundedMetric(latest.weight, step: 0.1, lower: 1, upper: 100)
            } else {
                weight = 4.0
            }
        }
    }

    private func save() {
        let today = Calendar.current.startOfDay(for: Date())
        let clampedDate = min(max(Calendar.current.startOfDay(for: selectedDate), dateRange.lowerBound), today)
        store.addGrowthRecord(
            date: clampedDate,
            height: roundedMetric(height, step: 0.5, lower: 1, upper: 100),
            weight: roundedMetric(weight, step: 0.1, lower: 1, upper: 100),
            popAfterSave: false
        )
        dismiss()
    }
}

private struct GrowthRecordAddBackdrop: View {
    let bottomInset: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            GrowthRecordColor.page.ignoresSafeArea()

            VStack(spacing: 0) {
                GrowthRecordAddBackdropHeader()
                GrowthRecordsTimeline(bottomInset: bottomInset)
            }
            .disabled(true)
            .ignoresSafeArea(edges: .top)

            BottomNavShadow()
            BottomTabBar(bottomInset: bottomInset)
                .disabled(true)
        }
    }
}

private struct GrowthRecordAddBackdropHeader: View {
    var body: some View {
        ZStack(alignment: .top) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(spacing: 0) {
                Color.clear.frame(height: GCLayout.topSwitcherY)

                HStack {
                    ChildSwitcher()
                    Spacer()
                }
                .frame(height: GCLayout.childSwitcherHeight)
                .padding(.horizontal, 20)

                Spacer(minLength: 0)

                GrowthRecordAddBackdropTabs()
                    .padding(.horizontal, 20)
                    .padding(.bottom, 2)
            }
        }
        .frame(height: GCLayout.growthRecordsTopBandHeight)
    }
}

private struct GrowthRecordAddBackdropTabs: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: 0xFFF0EB).opacity(0.6),
                            Color(hex: 0xFFF0EB).opacity(0.8)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                )

            HStack(spacing: 0) {
                Text("曲线")
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)

                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4)

                    Text("记录")
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                }
                .frame(maxWidth: .infinity)
                .frame(height: GCLayout.growthSegmentButtonHeight)
            }
            .padding(.horizontal, 4)
        }
        .frame(height: GCLayout.growthSegmentHeight)
    }
}

private struct AddGrowthRecordPanel: View {
    @Binding var selectedDate: Date
    @Binding var height: Double
    @Binding var weight: Double

    let dateRange: ClosedRange<Date>
    let save: () -> Void

    var body: some View {
        GeometryReader { proxy in
            let panelHeight = proxy.size.height
            let dateHeight = max(112, min(132, panelHeight * 0.17))
            let heightPickerHeight = max(170, min(224, panelHeight * 0.29))
            let weightHeight = max(205, panelHeight - dateHeight - heightPickerHeight - 158)

            ZStack(alignment: .topTrailing) {
                Color.white

                VStack(spacing: 0) {
                    Color.clear.frame(height: 28)

                    FigmaAddGrowthHeader(title: "日期", unit: "年/月/日")
                        .frame(height: 28)

                    DateWheelVisual(date: $selectedDate, range: dateRange)
                        .frame(height: dateHeight)
                        .padding(.top, 8)

                    Spacer(minLength: 14)

                    FigmaAddGrowthHeader(title: "身高", unit: "CM")
                        .frame(height: 28)

                    HeightMetricWheel(value: $height)
                        .frame(height: heightPickerHeight)
                        .padding(.top, 8)

                    Spacer(minLength: 12)

                    FigmaAddGrowthHeader(title: "体重", unit: "KG")
                        .frame(height: 28)
                        .offset(y: 20)

                    WeightMetricDial(value: $weight)
                        .frame(height: weightHeight)
                        .padding(.top, 4)
                        .padding(.horizontal, -18)
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 0)

                Button(action: save) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 27, weight: .regular))
                        .foregroundColor(.white)
                        .frame(width: 46, height: 46)
                        .background(Color(hex: 0xFFCF76))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("保存成长记录")
                .padding(.top, 16)
                .padding(.trailing, 16)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
        .background(Color.white.clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous)))
    }
}

private struct FigmaAddGrowthHeader: View {
    let title: String
    let unit: String

    var body: some View {
        HStack(spacing: 9) {
            Text(title)
                .font(.system(size: 22))
                .foregroundColor(.black)
            Text(unit)
                .font(.system(size: 10))
                .foregroundColor(.black)
                .tracking(0.35)
                .padding(.horizontal, 6)
                .frame(height: 21)
                .overlay {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(Color(hex: 0xCCCCCC), lineWidth: 0.5)
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct DateWheelVisual: View {
    @Binding var date: Date

    let range: ClosedRange<Date>

    private var calendar: Calendar {
        Calendar.current
    }

    var body: some View {
        GeometryReader { proxy in
            let spacing = min(34, proxy.size.width * 0.10)
            let yearWidth = min(96, proxy.size.width * 0.27)
            let otherWidth = min(76, (proxy.size.width - yearWidth - spacing * 2) / 2)

            HStack(spacing: spacing) {
                DateWheelColumn(
                    text: { yearText(offset: $0) },
                    lineWidth: yearWidth,
                    adjust: { adjust(.year, by: $0) }
                )
                DateWheelColumn(
                    text: { monthText(offset: $0) },
                    lineWidth: otherWidth,
                    adjust: { adjust(.month, by: $0) }
                )
                DateWheelColumn(
                    text: { dayText(offset: $0) },
                    lineWidth: otherWidth,
                    adjust: { adjust(.day, by: $0) }
                )
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
        }
        .onAppear {
            date = boundedStartOfDay(date)
        }
        .onChange(of: date) { newValue in
            let bounded = boundedStartOfDay(newValue)
            if bounded != newValue {
                date = bounded
            }
        }
    }

    private func yearText(offset: Int) -> String {
        let targetYear = component(.year, from: date) + offset
        guard targetYear >= component(.year, from: range.lowerBound),
              targetYear <= component(.year, from: range.upperBound) else { return "" }
        return "\(targetYear)"
    }

    private func monthText(offset: Int) -> String {
        let target = shiftedMonth(by: offset)
        guard target.monthIndex >= monthIndex(for: range.lowerBound),
              target.monthIndex <= monthIndex(for: range.upperBound) else { return "" }
        return String(format: "%02d", target.month)
    }

    private func dayText(offset: Int) -> String {
        guard let date = shiftedBounded(.day, by: offset) else { return "" }
        return String(format: "%02d", calendar.component(.day, from: date))
    }

    private func shiftedBounded(_ component: Calendar.Component, by value: Int) -> Date? {
        guard let newDate = calendar.date(byAdding: component, value: value, to: date) else { return nil }
        let day = calendar.startOfDay(for: newDate)
        guard day >= calendar.startOfDay(for: range.lowerBound),
              day <= calendar.startOfDay(for: range.upperBound) else { return nil }
        return day
    }

    private func adjust(_ component: Calendar.Component, by value: Int) {
        switch component {
        case .year:
            let targetYear = self.component(.year, from: date) + value
            let currentMonth = self.component(.month, from: date)
            let currentDay = self.component(.day, from: date)
            date = boundedDate(year: targetYear, month: currentMonth, day: currentDay)
        case .month:
            let target = shiftedMonth(by: value)
            let currentDay = self.component(.day, from: date)
            date = boundedDate(year: target.year, month: target.month, day: currentDay)
        default:
            guard let newDate = calendar.date(byAdding: component, value: value, to: date) else { return }
            date = boundedStartOfDay(newDate)
        }
    }

    private func boundedStartOfDay(_ value: Date) -> Date {
        let day = calendar.startOfDay(for: value)
        return min(max(day, calendar.startOfDay(for: range.lowerBound)), calendar.startOfDay(for: range.upperBound))
    }

    private func component(_ component: Calendar.Component, from value: Date) -> Int {
        calendar.component(component, from: value)
    }

    private func shiftedMonth(by offset: Int) -> (year: Int, month: Int, monthIndex: Int) {
        let index = monthIndex(for: date) + offset
        let year = Int(floor(Double(index) / 12.0))
        let month = ((index % 12) + 12) % 12 + 1
        return (year, month, index)
    }

    private func monthIndex(for value: Date) -> Int {
        component(.year, from: value) * 12 + component(.month, from: value) - 1
    }

    private func boundedDate(year: Int, month: Int, day: Int) -> Date {
        let clampedDay = min(day, daysInMonth(year: year, month: month))
        let raw = calendar.date(from: DateComponents(year: year, month: month, day: clampedDay)) ?? date
        return boundedStartOfDay(raw)
    }

    private func daysInMonth(year: Int, month: Int) -> Int {
        guard let monthDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: monthDate) else {
            return 28
        }
        return range.count
    }
}

private struct DateWheelColumn: View {
    let text: (Int) -> String
    let lineWidth: CGFloat
    let adjust: (Int) -> Void

    @State private var dragOffset: CGFloat = 0

    var body: some View {
        GeometryReader { proxy in
            let rowHeight = proxy.size.height / 3
            let centerY = proxy.size.height / 2
            let activeFont = min(30, max(24, rowHeight * 0.72))
            let passiveFont = min(18, max(14, rowHeight * 0.43))

            ZStack(alignment: .top) {
                Rectangle()
                    .fill(Color.clear)

                ForEach(-2...2, id: \.self) { row in
                    let distance = abs(CGFloat(row) * rowHeight + dragOffset)
                    let isActive = distance < rowHeight * 0.45

                    Text(text(row))
                        .font(.system(size: isActive ? activeFont : passiveFont, weight: .semibold))
                        .foregroundColor(isActive ? Color(hex: 0x464646) : Color(hex: 0xCCCCCC))
                        .frame(width: lineWidth, height: rowHeight)
                        .position(
                            x: lineWidth / 2,
                            y: centerY + CGFloat(row) * rowHeight + dragOffset
                        )
                }

                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: lineWidth, height: 1)
                    .offset(y: rowHeight)

                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: lineWidth, height: 1)
                    .offset(y: rowHeight * 2)
            }
            .frame(width: lineWidth, height: proxy.size.height)
            .clipped()
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        dragOffset = value.translation.height
                    }
                    .onEnded { value in
                        let projected = value.predictedEndTranslation.height
                        let combined = abs(projected) > abs(dragOffset) ? projected : dragOffset
                        let rowShift = Int((combined / rowHeight).rounded())
                        if rowShift != 0 {
                            adjust(-rowShift)
                        }
                        dragOffset = 0
                    }
            )
        }
        .frame(width: lineWidth)
    }
}

private struct HeightMetricWheel: View {
    @Binding var value: Double
    @State private var gestureStartValue: Double?
    @State private var dragOffset: CGFloat = 0

    private let visibleValueStep = 0.5
    private let pointsPerStep: CGFloat = 48

    var body: some View {
        GeometryReader { proxy in
            let centerY = proxy.size.height / 2
            let rowGap = min(64, max(48, proxy.size.height * 0.28))
            let numberX = proxy.size.width * 0.50
            let rulerHeight = max(proxy.size.height * 1.32, 220)
            let lineWidth = min(148, proxy.size.width * 0.36)
            let pointerWidth = max(0, lineWidth - 44)
            let current = roundedMetric(value, step: visibleValueStep, lower: 1, upper: 100)

            ZStack(alignment: .topLeading) {
                ZStack(alignment: .topLeading) {
                    ForEach(-1...1, id: \.self) { row in
                        let metric = rowValue(row, current: current)
                        if metric >= 1 && metric <= 100 {
                            let offset = CGFloat(row) * rowGap + dragOffset
                            heightText(metric, progress: selectionProgress(distance: abs(offset), radius: rowGap * 0.72))
                                .position(x: numberX, y: centerY + offset)
                        }
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .clipped()

                ZStack {
                    HeightMetricRuler(majorGap: rowGap)
                        .frame(width: 85, height: rulerHeight)
                        .offset(y: dragOffset)
                }
                .frame(width: 85, height: proxy.size.height)
                .clipped()
                .position(x: proxy.size.width + 18 - 42.5, y: centerY)

                Image("height-picker-line")
                    .resizable()
                    .frame(width: pointerWidth, height: 4)
                    .position(x: proxy.size.width + 18 - pointerWidth / 2, y: centerY)
            }
        }
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { gesture in
                    if gestureStartValue == nil {
                        gestureStartValue = value
                    }
                    let start = gestureStartValue ?? value
                    let stepShift = Int((gesture.translation.height / pointsPerStep).rounded())
                    value = roundedMetric(start + Double(stepShift) * visibleValueStep, step: visibleValueStep, lower: 1, upper: 100)
                    dragOffset = gesture.translation.height - CGFloat(stepShift) * pointsPerStep
                }
                .onEnded { _ in
                    value = roundedMetric(value, step: visibleValueStep, lower: 1, upper: 100)
                    gestureStartValue = nil
                    dragOffset = 0
                }
        )
    }

    private func heightText(_ value: Double, progress: CGFloat) -> some View {
        Text(String(format: "%.1f", value))
            .font(.system(size: 20 + 8 * progress, weight: .semibold))
            .foregroundColor(grayRamp(progress: progress, activeValue: 0))
            .frame(width: 106, height: 39)
    }

    private func rowValue(_ row: Int, current: Double) -> Double {
        roundedMetric(current - Double(row) * visibleValueStep, step: visibleValueStep, lower: 1, upper: 100)
    }
}

private struct HeightMetricRuler: View {
    let majorGap: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let spacing = majorGap / 5
            let centerY = proxy.size.height / 2
            let rightX = proxy.size.width

            Canvas { context, _ in
                for index in -12...12 {
                    let y = centerY + CGFloat(index) * spacing
                    guard y >= -2 && y <= proxy.size.height + 2 else { continue }
                    let isMajor = index.isMultiple(of: 5)
                    let length: CGFloat = isMajor ? 85 : 45
                    var path = Path()
                    path.move(to: CGPoint(x: rightX - length, y: y))
                    path.addLine(to: CGPoint(x: rightX, y: y))
                    context.stroke(
                        path,
                        with: .color(Color(hex: 0xCCCCCC)),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                }
            }
        }
    }
}

private struct WeightMetricDial: View {
    @Binding var value: Double
    @State private var gestureStartIndex: Int?
    @State private var dragFraction: Double = 0

    private let minTenths = 10
    private let maxTenths = 1000
    private let diameter: CGFloat = 525
    private let labelAngleStep: Double = 10
    private let pointsPerTenth: CGFloat = 10

    private var totalSteps: Int {
        maxTenths - minTenths
    }

    private var selectedIndex: Int {
        clampIndex(Int((value * 10).rounded()) - minTenths)
    }

    var body: some View {
        GeometryReader { proxy in
            let radius = diameter / 2
            let topPointY = proxy.size.height - 135
            let center = CGPoint(x: proxy.size.width / 2, y: topPointY + radius)

            ZStack {
                WeightDialTicks(center: center, radius: radius, dragFraction: dragFraction)

                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(GCColor.headerTop)
                    .frame(width: 6, height: radius)
                    .position(x: center.x, y: topPointY + radius / 2)

                ForEach(-6...6, id: \.self) { offset in
                    weightLabel(offset: offset, center: center, radius: radius)
                }
            }
            .frame(width: proxy.size.width, height: proxy.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        if gestureStartIndex == nil {
                            gestureStartIndex = selectedIndex
                        }
                        let rawDelta = -gesture.translation.width / pointsPerTenth
                        let roundedDelta = rawDelta.rounded()
                        let deltaTenths = Int(roundedDelta)
                        let nextIndex = clampIndex((gestureStartIndex ?? selectedIndex) + deltaTenths)
                        value = Double(minTenths + nextIndex) / 10
                        dragFraction = rawDelta - roundedDelta
                    }
                    .onEnded { _ in
                        value = roundedMetric(value, step: 0.1, lower: 1, upper: 100)
                        gestureStartIndex = nil
                        withAnimation(.easeOut(duration: 0.16)) {
                            dragFraction = 0
                        }
                    }
            )
        }
    }

    private func weightLabel(offset: Int, center: CGPoint, radius: CGFloat) -> some View {
        let index = selectedIndex + offset
        let point = labelPoint(offset: offset, center: center, radius: radius)
        let progress = selectionProgress(distance: abs(CGFloat(Double(offset) - dragFraction)), radius: 0.78)
        let isVisible = index >= 0 && index <= totalSteps

        return Text(formatIndex(index))
            .font(.system(size: 20 + 8 * progress, weight: .semibold))
            .foregroundColor(grayRamp(progress: progress, activeValue: 70.0 / 255.0))
            .frame(width: 78, height: 46)
            .opacity(isVisible ? 1 : 0)
            .position(point)
    }

    private func labelPoint(offset: Int, center: CGPoint, radius: CGFloat) -> CGPoint {
        let angle = (-90 + (Double(offset) - dragFraction) * labelAngleStep) * Double.pi / 180
        let labelRadius = radius + 43
        return CGPoint(
            x: center.x + labelRadius * CGFloat(cos(angle)),
            y: center.y + labelRadius * CGFloat(sin(angle)) + 11
        )
    }

    private func formatIndex(_ index: Int) -> String {
        guard index >= 0 && index <= totalSteps else { return "" }
        return String(format: "%.1f", Double(minTenths + index) / 10)
    }

    private func clampIndex(_ index: Int) -> Int {
        max(0, min(totalSteps, index))
    }
}

private struct WeightDialTicks: View {
    let center: CGPoint
    let radius: CGFloat
    let dragFraction: Double

    var body: some View {
        Canvas { context, size in
            for degrees in stride(from: -170.0, through: -10.0, by: 2.0) {
                let shiftedDegrees = degrees - dragFraction * 10
                let offsetFromTop = abs(shiftedDegrees + 90)
                let isSelected = offsetFromTop < 0.1
                let isMajor = abs(degrees.truncatingRemainder(dividingBy: 10)) < 0.1
                let isMid = abs(degrees.truncatingRemainder(dividingBy: 5)) < 0.1
                let innerRadius: CGFloat = isMajor ? radius - 31 : (isMid ? radius - 25 : radius - 16)
                let lineWidth: CGFloat = isSelected ? 2.3 : (isMajor ? 1.6 : (isMid ? 1.1 : 0.6))
                let angle = CGFloat(shiftedDegrees * .pi / 180)
                let outer = CGPoint(
                    x: center.x + cos(angle) * radius,
                    y: center.y + sin(angle) * radius
                )
                let inner = CGPoint(
                    x: center.x + cos(angle) * innerRadius,
                    y: center.y + sin(angle) * innerRadius
                )
                var path = Path()
                path.move(to: inner)
                path.addLine(to: outer)
                context.stroke(
                    path,
                    with: .color(Color(hex: 0xCCCCCC)),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .butt)
                )
            }
        }
    }
}

private func selectionProgress(distance: CGFloat, radius: CGFloat) -> CGFloat {
    guard radius > 0 else { return 0 }
    let linear = max(0, min(1, 1 - distance / radius))
    return linear * linear * (3 - 2 * linear)
}

private func grayRamp(progress: CGFloat, activeValue: CGFloat) -> Color {
    let gray = 0.8 + (activeValue - 0.8) * max(0, min(1, progress))
    return Color(red: Double(gray), green: Double(gray), blue: Double(gray))
}

private func roundedMetric(_ value: Double, step: Double, lower: Double, upper: Double) -> Double {
    min(max((value / step).rounded() * step, lower), upper)
}

enum GrowthRecordColor {
    static let page = Color(hex: 0xF7F2EF)
}
