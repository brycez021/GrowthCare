import SwiftUI

private enum GrowthSegment {
    case curve
    case records
}

struct GrowthCurveView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var selectedSegment: GrowthSegment = .curve
    @State private var showsAddRecordOverlay = false
    @Namespace private var growthSegmentSelection

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                pageBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    header()
                    if selectedSegment == .curve {
                        bodyArea(bottomInset: proxy.safeAreaInsets.bottom)
                    } else {
                        GrowthRecordsTimeline(bottomInset: proxy.safeAreaInsets.bottom) {
                            showsAddRecordOverlay = true
                        }
                    }
                }
                .ignoresSafeArea(edges: .top)

                BottomNavShadow()

                if selectedSegment == .curve {
                    legend
                        .padding(.bottom, max(0, BottomTabBar.reservedHeight(for: proxy.safeAreaInsets.bottom) - 17))
                }

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
        .alert("提示", isPresented: toastBinding) {
            Button("好", role: .cancel) {
                store.toastMessage = nil
            }
        } message: {
            Text(store.toastMessage ?? "")
        }
    }

    private var pageBackground: Color {
        selectedSegment == .curve ? GrowthColor.page : GrowthRecordColor.page
    }

    private var headerHeight: CGFloat {
        GCLayout.growthTopBandHeight
    }

    private var tabsBottomPadding: CGFloat {
        GCLayout.growthSegmentBottomPadding
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

                growthTabs
                    .padding(.horizontal, 20)
                    .padding(.bottom, tabsBottomPadding)
            }
        }
        .frame(height: headerHeight)
    }

    private var growthTabs: some View {
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
                segmentControl(.curve, title: "曲线")
                segmentControl(.records, title: "记录")
            }
            .padding(.horizontal, 4)
            .frame(height: GCLayout.growthSegmentHeight)
        }
        .frame(height: GCLayout.growthSegmentHeight)
    }

    private func segmentControl(_ segment: GrowthSegment, title: String) -> some View {
        Button {
            if selectedSegment != segment {
                switchSegment(segment)
            }
        } label: {
            ZStack {
                if selectedSegment == segment {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.75), Color.white.opacity(0.9)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4)
                        .matchedGeometryEffect(id: "growthSegmentSelection", in: growthSegmentSelection)
                }

                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity)
            .frame(height: GCLayout.growthSegmentButtonHeight)
        }
        .buttonStyle(.plain)
    }

    private func switchSegment(_ segment: GrowthSegment) {
        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
            selectedSegment = segment
        }
    }

    private func bodyArea(bottomInset: CGFloat) -> some View {
        GeometryReader { proxy in
            let contentWidth = GCLayout.contentWidth(for: proxy.size.width)
            let horizontalPadding: CGFloat = 23
            let chartWidth = max(0, contentWidth - horizontalPadding * 2)

            ZStack(alignment: .top) {
                GrowthColor.page

                VStack(alignment: .leading, spacing: 0) {
                    Text("WHO 生长标准（儿童，0-60个月）")
                        .font(.system(size: 12))
                        .foregroundColor(GrowthColor.subText)
                        .padding(.top, 16)
                        .padding(.bottom, 22)

                    GrowthChartCard(
                        child: store.activeChild,
                        records: store.activeGrowthRecords(),
                        availableWidth: chartWidth
                    )

                    Spacer(minLength: 0)
                }
                .padding(.horizontal, horizontalPadding)
                .frame(width: contentWidth, alignment: .topLeading)
                .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .padding(.bottom, BottomTabBar.reservedHeight(for: bottomInset))
    }

    private var legend: some View {
        HStack(spacing: 48) {
            legendItem(color: GrowthColor.heightLine, title: "身高")
            legendItem(color: GrowthColor.weightLine, title: "体重")
        }
        .frame(height: 55)
        .frame(maxWidth: .infinity)
    }

    private func legendItem(color: Color, title: String) -> some View {
        HStack(spacing: 8) {
            Capsule()
                .fill(color)
                .frame(width: 76, height: 8)
            Text(title)
                .font(.system(size: 12))
                .foregroundColor(GrowthColor.darkText)
        }
    }
}

private struct GrowthChartCard: View {
    let child: ChildProfile
    let records: [GrowthRecord]
    let availableWidth: CGFloat
    @State private var visibleStartMonth: CGFloat = 0
    @State private var dragStartMonth: CGFloat?

    private let baseWidth: CGFloat = 394
    private let baseHeight: CGFloat = 525

    private var scale: CGFloat {
        min(1, max(0, availableWidth) / baseWidth)
    }

    private var viewport: GrowthChartViewport {
        GrowthChartViewport(startMonth: visibleStartMonth, spanMonths: GrowthChart.visibleSpanMonths)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            GrowthChartCanvas(child: child, records: records, viewport: viewport)
                .frame(width: baseWidth, height: baseHeight)
                .contentShape(Rectangle())
                .gesture(chartDragGesture)
                .scaleEffect(scale, anchor: .topLeading)
        }
        .frame(width: baseWidth * scale, height: baseHeight * scale, alignment: .topLeading)
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: baseHeight * scale)
        .onAppear {
            visibleStartMonth = latestRecordStartMonth()
        }
        .onChange(of: child.id) { _ in
            visibleStartMonth = latestRecordStartMonth()
        }
        .onChange(of: records) { _ in
            visibleStartMonth = latestRecordStartMonth()
        }
    }

    private var chartDragGesture: some Gesture {
        DragGesture(minimumDistance: 2)
            .onChanged { value in
                if dragStartMonth == nil {
                    dragStartMonth = visibleStartMonth
                }

                let monthDelta = -value.translation.width / GrowthChart.plotWidth * GrowthChart.visibleSpanMonths
                visibleStartMonth = clampedStart((dragStartMonth ?? 0) + monthDelta)
            }
            .onEnded { _ in
                visibleStartMonth = clampedStart(visibleStartMonth)
                dragStartMonth = nil
            }
    }

    private func clampedStart(_ start: CGFloat) -> CGFloat {
        min(max(0, start), GrowthChart.maximumTimelineMonths - GrowthChart.visibleSpanMonths)
    }

    private func latestRecordStartMonth() -> CGFloat {
        let latestMonth = GrowthChart.maxRecordMonth(child: child, records: records)
        guard latestMonth > GrowthChart.visibleSpanMonths else {
            return 0
        }

        return clampedStart(ceil(latestMonth - GrowthChart.visibleSpanMonths))
    }
}

private struct GrowthChartCanvas: View {
    let child: ChildProfile
    let records: [GrowthRecord]
    let viewport: GrowthChartViewport

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white)

            ZStack(alignment: .topLeading) {
                GrowthStandardBand(metric: .height, viewport: viewport, sex: GrowthSex(child: child))
                    .fill(GrowthColor.heightBand)

                GrowthStandardBand(metric: .weight, viewport: viewport, sex: GrowthSex(child: child))
                    .fill(GrowthColor.weightBand)

                GrowthGrid()
                    .stroke(GrowthColor.grid, lineWidth: 0.5)

                GrowthDataLayer(child: child, records: records, viewport: viewport)
            }
            .frame(width: GrowthChart.plotWidth, height: GrowthChart.plotHeight)
            .offset(x: 37, y: 24)

            yAxisLeft
            yAxisRight
            xAxis
        }
        .frame(width: 394, height: 525)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var yAxisLeft: some View {
        ZStack(alignment: .topLeading) {
            ForEach(GrowthChart.weightAxisTicks(for: viewport)) { tick in
                Text(tick.label)
                    .font(.system(size: 10))
                    .foregroundColor(GrowthColor.axisText)
                    .frame(width: 22, alignment: .trailing)
                    .position(x: 11, y: tick.position)
            }
        }
        .frame(width: 22, height: GrowthChart.plotHeight)
        .offset(x: 14, y: 24)
    }

    private var yAxisRight: some View {
        ZStack(alignment: .topLeading) {
            ForEach(GrowthChart.heightAxisTicks(for: viewport)) { tick in
                Text(tick.label)
                    .font(.system(size: 10))
                    .foregroundColor(GrowthColor.axisText)
                    .frame(width: 25, alignment: .leading)
                    .position(x: 12.5, y: tick.position)
            }
        }
        .frame(width: 25, height: GrowthChart.plotHeight)
        .offset(x: 360, y: 24)
    }

    private var xAxis: some View {
        ZStack(alignment: .topLeading) {
            ForEach(GrowthChart.monthAxisTicks(for: viewport)) { tick in
                Text(tick.label)
                    .font(.system(size: 12))
                    .foregroundColor(GrowthColor.axisText)
                    .position(x: tick.position, y: 6)
            }

            Text(GrowthChart.xAxisUnitTitle(for: viewport))
                .font(.system(size: 10))
                .foregroundColor(GrowthColor.axisText)
                .position(x: 340, y: 25)
        }
        .frame(width: GrowthChart.plotWidth, height: 36)
        .offset(x: 37, y: 475)
    }
}

private struct GrowthGrid: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        for y in [35, 83, 130, 178, 225, 273, 320, 368, 415] {
            path.move(to: CGPoint(x: 0, y: CGFloat(y)))
            path.addLine(to: CGPoint(x: GrowthChart.plotWidth, y: CGFloat(y)))
        }

        for x in stride(from: 0, through: Int(GrowthChart.plotWidth), by: 27) {
            path.move(to: CGPoint(x: CGFloat(x), y: 0))
            path.addLine(to: CGPoint(x: CGFloat(x), y: GrowthChart.plotHeight))
        }

        return path
    }
}

private struct GrowthStandardBand: Shape {
    let metric: GrowthMetric
    let viewport: GrowthChartViewport
    let sex: GrowthSex

    func path(in rect: CGRect) -> Path {
        let samples = stride(from: 0, through: 48, by: 1).map { index -> (CGPoint, CGPoint) in
            let ratio = CGFloat(index) / 48
            let month = viewport.startMonth + viewport.spanMonths * ratio
            let range = GrowthChart.standardRange(month: month, metric: metric, sex: sex)
            return (
                GrowthChart.point(month: month, value: range.lower, viewport: viewport, metric: metric),
                GrowthChart.point(month: month, value: range.upper, viewport: viewport, metric: metric)
            )
        }

        var path = Path()
        guard let first = samples.first else { return path }
        path.move(to: first.1)
        samples.dropFirst().forEach { path.addLine(to: $0.1) }
        samples.reversed().forEach { path.addLine(to: $0.0) }
        path.closeSubpath()
        return path
    }
}

private struct GrowthPrototypeBand: Shape {
    let metric: GrowthMetric

    func path(in rect: CGRect) -> Path {
        switch metric {
        case .height:
            return scaledHeightPath(in: rect)
        case .weight:
            return scaledWeightPath(in: rect)
        }
    }

    private func scaledHeightPath(in rect: CGRect) -> Path {
        let sourceHeight: CGFloat = 204
        let point: (CGFloat, CGFloat) -> CGPoint = { x, y in
            CGPoint(
                x: rect.minX + rect.width * x / GrowthChart.plotWidth,
                y: rect.minY + rect.height * y / sourceHeight
            )
        }

        var path = Path()
        path.move(to: point(0, 204))
        path.addLine(to: point(0, 171.545))
        path.addCurve(
            to: point(80.0414, 98.9091),
            control1: point(16.6765, 150.317),
            control2: point(37.8639, 127.5)
        )
        path.addCurve(
            to: point(237.759, 25.8883),
            control1: point(111.966, 77.2682),
            control2: point(168.671, 48.67)
        )
        path.addCurve(
            to: point(324, 0),
            control1: point(293.029, 7.66294),
            control2: point(318.282, 1.03553)
        )
        path.addLine(to: point(324, 59.8372))
        path.addCurve(
            to: point(194.4, 96.3046),
            control1: point(284.698, 69.863),
            control2: point(229.058, 84.7195)
        )
        path.addCurve(
            to: point(71.4706, 147.046),
            control1: point(148.101, 111.781),
            control2: point(95.9441, 131.935)
        )
        path.addCurve(
            to: point(0, 204),
            control1: point(50.5059, 159.99),
            control2: point(20.4882, 177.594)
        )
        path.closeSubpath()
        return path
    }

    private func scaledWeightPath(in rect: CGRect) -> Path {
        let sourceHeight: CGFloat = 246
        let point: (CGFloat, CGFloat) -> CGPoint = { x, y in
            CGPoint(
                x: rect.minX + rect.width * x / GrowthChart.plotWidth,
                y: rect.minY + rect.height * y / sourceHeight
            )
        }

        var path = Path()
        path.move(to: point(0, 246))
        path.addLine(to: point(0, 196.8))
        path.addCurve(
            to: point(75.7278, 114.493),
            control1: point(15.8166, 173.809),
            control2: point(33.5503, 148.52)
        )
        path.addCurve(
            to: point(218.556, 36.785),
            control1: point(107.653, 88.7385),
            control2: point(149.468, 63.8977)
        )
        path.addCurve(
            to: point(324, 0),
            control1: point(273.827, 15.0949),
            control2: point(318.282, 1.23239)
        )
        path.addLine(to: point(324, 117.712))
        path.addCurve(
            to: point(181.651, 145.761),
            control1: point(252.586, 125.989),
            control2: point(229.101, 131.966)
        )
        path.addCurve(
            to: point(70.9349, 189.443),
            control1: point(136.973, 158.749),
            control2: point(96.8166, 173.35)
        )
        path.addCurve(
            to: point(0, 246),
            control1: point(48.7749, 203.222),
            control2: point(24.4438, 218.871)
        )
        path.closeSubpath()
        return path
    }
}

private struct GrowthDataLayer: View {
    let child: ChildProfile
    let records: [GrowthRecord]
    let viewport: GrowthChartViewport

    var body: some View {
        ZStack(alignment: .topLeading) {
            DataLine(points: heightPoints)
                .stroke(
                    GrowthColor.heightLine,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round, dash: [5, 4])
                )

            DataLine(points: weightPoints)
                .stroke(
                    GrowthColor.weightLine,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round, dash: [5, 4])
                )

            ForEach(heightPoints) { point in
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(GrowthColor.heightLine, lineWidth: 1.5))
                    .frame(width: 9, height: 9)
                    .position(point.point)
            }

            ForEach(weightPoints) { point in
                Circle()
                    .fill(Color.white)
                    .overlay(Circle().stroke(GrowthColor.weightLine, lineWidth: 1.5))
                    .frame(width: 9, height: 9)
                    .position(point.point)
            }
        }
    }

    private var heightPoints: [DataPoint] {
        records
            .compactMap {
                GrowthChart.dataPoint(for: $0.date, value: $0.height, birth: child.birthDate, viewport: viewport, metric: .height)
            }
            .sorted { $0.point.x < $1.point.x }
    }

    private var weightPoints: [DataPoint] {
        records
            .compactMap {
                GrowthChart.dataPoint(for: $0.date, value: $0.weight, birth: child.birthDate, viewport: viewport, metric: .weight)
            }
            .sorted { $0.point.x < $1.point.x }
    }
}

private struct DataLine: Shape {
    let points: [DataPoint]

    func path(in rect: CGRect) -> Path {
        var path = Path()
        guard let first = points.first, points.count > 1 else { return path }
        path.move(to: first.point)
        for point in points.dropFirst() {
            path.addLine(to: point.point)
        }
        return path
    }
}

private struct DataPoint: Identifiable {
    let id = UUID()
    let point: CGPoint
}

private struct AxisTick: Identifiable {
    let label: String
    let position: CGFloat
    var id: String { "\(label)-\(position)" }
}

private enum GrowthMetric {
    case height
    case weight
}

private enum GrowthSex {
    case boy
    case girl

    init(child: ChildProfile) {
        self = child.gender == "男" ? .boy : .girl
    }
}

private typealias GrowthRangeSample = (month: CGFloat, lower: CGFloat, upper: CGFloat)

private struct GrowthChartViewport: Equatable {
    let startMonth: CGFloat
    let spanMonths: CGFloat

    var endMonth: CGFloat {
        startMonth + spanMonths
    }
}

private enum GrowthChart {
    static let plotWidth: CGFloat = 324
    static let plotHeight: CGFloat = 444
    static let visibleSpanMonths: CGFloat = 12
    static let maximumTimelineMonths: CGFloat = 60
    static let weightYTop: CGFloat = 35
    static let weightYBottom: CGFloat = 415
    static let heightYTop: CGFloat = 28
    static let heightYBottom: CGFloat = 364
    static let baseWeightAxisMax: CGFloat = 18
    static let baseHeightAxisMax: CGFloat = 100
    static let weightAxisHeadroom: CGFloat = 0.8
    static let heightAxisHeadroom: CGFloat = 2

    static func maxRecordMonth(child: ChildProfile, records: [GrowthRecord]) -> CGFloat {
        records
            .map { fractionalMonths(from: child.birthDate, to: $0.date) }
            .max() ?? 0
    }

    static func dataPoint(for date: Date, value: Double, birth: Date, viewport: GrowthChartViewport, metric: GrowthMetric) -> DataPoint? {
        let months = fractionalMonths(from: birth, to: date)
        guard months >= viewport.startMonth, months <= viewport.endMonth else { return nil }
        return DataPoint(point: point(month: months, value: CGFloat(value), viewport: viewport, metric: metric))
    }

    static func point(month: CGFloat, value: CGFloat, viewport: GrowthChartViewport, metric: GrowthMetric) -> CGPoint {
        let x = monthToX(month, viewport: viewport)
        let y: CGFloat
        switch metric {
        case .height:
            y = heightToY(value, viewport: viewport)
        case .weight:
            y = weightToY(value, viewport: viewport)
        }
        return CGPoint(x: x, y: y)
    }

    static func monthAxisTicks(for viewport: GrowthChartViewport) -> [AxisTick] {
        (0...12).map { index in
            let ratio = CGFloat(index) / 12
            let month = viewport.startMonth + viewport.spanMonths * ratio
            return AxisTick(label: formatAgeTick(month, viewport: viewport), position: plotWidth * ratio)
        }
    }

    static func xAxisUnitTitle(for viewport: GrowthChartViewport) -> String {
        "（月龄）"
    }

    static func weightAxisTicks(for viewport: GrowthChartViewport) -> [AxisTick] {
        var ticks = [AxisTick(label: "(KG)", position: 18)]
        let range = weightAxisRange(for: viewport)
        ticks += (0...8).map { index in
            let ratio = CGFloat(index) / 8
            let value = range.max - (range.max - range.min) * ratio
            let y = weightToY(value, viewport: viewport)
            return AxisTick(label: formatAxisValue(value), position: y + 6)
        }
        return ticks
    }

    static func heightAxisTicks(for viewport: GrowthChartViewport) -> [AxisTick] {
        var ticks = [AxisTick(label: "(CM)", position: 12)]
        let range = heightAxisRange(for: viewport)
        ticks += (0...7).map { index in
            let ratio = CGFloat(index) / 7
            let value = range.max - (range.max - range.min) * ratio
            let y = heightToY(value, viewport: viewport)
            return AxisTick(label: formatAxisValue(value), position: y)
        }
        return ticks
    }

    static func standardRange(month: CGFloat, metric: GrowthMetric, sex: GrowthSex) -> (lower: CGFloat, upper: CGFloat) {
        interpolatedRange(month: month, samples: rangeSamples(metric: metric, sex: sex))
    }

    private static func monthToX(_ months: CGFloat, viewport: GrowthChartViewport) -> CGFloat {
        let ratio = (months - viewport.startMonth) / viewport.spanMonths
        return min(max(0, ratio), 1) * plotWidth
    }

    private static func weightToY(_ kg: CGFloat, viewport: GrowthChartViewport) -> CGFloat {
        let range = weightAxisRange(for: viewport)
        let clamped = min(max(range.min, kg), range.max)
        let ratio = (range.max - clamped) / (range.max - range.min)
        return weightYTop + ratio * (weightYBottom - weightYTop)
    }

    private static func heightToY(_ cm: CGFloat, viewport: GrowthChartViewport) -> CGFloat {
        let range = heightAxisRange(for: viewport)
        let clamped = min(max(range.min, cm), range.max)
        let ratio = (range.max - clamped) / (range.max - range.min)
        return heightYTop + ratio * (heightYBottom - heightYTop)
    }

    private static func weightAxisRange(for viewport: GrowthChartViewport) -> (min: CGFloat, max: CGFloat) {
        let end = min(maximumTimelineMonths, max(0, viewport.endMonth))
        let boys = standardRange(month: end, metric: .weight, sex: .boy).upper
        let girls = standardRange(month: end, metric: .weight, sex: .girl).upper
        let maxValue = max(baseWeightAxisMax, max(boys, girls) + weightAxisHeadroom)
        return (2, maxValue)
    }

    private static func heightAxisRange(for viewport: GrowthChartViewport) -> (min: CGFloat, max: CGFloat) {
        let end = min(maximumTimelineMonths, max(0, viewport.endMonth))
        let boys = standardRange(month: end, metric: .height, sex: .boy).upper
        let girls = standardRange(month: end, metric: .height, sex: .girl).upper
        let maxValue = max(baseHeightAxisMax, max(boys, girls) + heightAxisHeadroom)
        return (30, maxValue)
    }

    private static func rangeSamples(metric: GrowthMetric, sex: GrowthSex) -> [GrowthRangeSample] {
        switch (metric, sex) {
        case (.height, .boy): return heightBoysRanges
        case (.height, .girl): return heightGirlsRanges
        case (.weight, .boy): return weightBoysRanges
        case (.weight, .girl): return weightGirlsRanges
        }
    }

    private static func interpolatedRange(month: CGFloat, samples: [GrowthRangeSample]) -> (lower: CGFloat, upper: CGFloat) {
        guard let first = samples.first else { return (0, 0) }
        let clampedMonth = min(max(0, month), maximumTimelineMonths)
        if clampedMonth <= first.month {
            return (first.lower, first.upper)
        }

        for index in 1..<samples.count {
            let previous = samples[index - 1]
            let current = samples[index]
            if clampedMonth <= current.month {
                let ratio = (clampedMonth - previous.month) / (current.month - previous.month)
                return (
                    previous.lower + (current.lower - previous.lower) * ratio,
                    previous.upper + (current.upper - previous.upper) * ratio
                )
            }
        }

        guard let last = samples.last else { return (first.lower, first.upper) }
        return (last.lower, last.upper)
    }

    private static let heightBoysRanges: [GrowthRangeSample] = [
        (0, 46.1, 53.7), (1, 50.8, 58.6), (2, 54.4, 62.4), (3, 57.3, 65.5), (4, 59.7, 68.0), (5, 61.7, 70.1),
        (6, 63.3, 71.9), (7, 64.8, 73.5), (8, 66.2, 75.0), (9, 67.5, 76.5), (10, 68.7, 77.9),
        (11, 69.9, 79.2), (12, 71.0, 80.5), (13, 72.1, 81.8), (14, 73.1, 83.0), (15, 74.1, 84.2),
        (16, 75.0, 85.4), (17, 76.0, 86.5), (18, 76.9, 87.7), (19, 77.7, 88.8), (20, 78.6, 89.8),
        (21, 79.4, 90.9), (22, 80.2, 91.9), (23, 81.0, 92.9), (24, 81.0, 93.2), (25, 81.7, 94.2),
        (26, 82.5, 95.2), (27, 83.1, 96.1), (28, 83.8, 97.0), (29, 84.5, 97.9), (30, 85.1, 98.7),
        (31, 85.7, 99.6), (32, 86.4, 100.4), (33, 86.9, 101.2), (34, 87.5, 102.0), (35, 88.1, 102.7),
        (36, 88.7, 103.5), (37, 89.2, 104.2), (38, 89.8, 105.0), (39, 90.3, 105.7), (40, 90.9, 106.4),
        (41, 91.4, 107.1), (42, 91.9, 107.8), (43, 92.4, 108.5), (44, 93.0, 109.1), (45, 93.5, 109.8),
        (46, 94.0, 110.4), (47, 94.4, 111.1), (48, 94.9, 111.7), (49, 95.4, 112.4), (50, 95.9, 113.0),
        (51, 96.4, 113.6), (52, 96.9, 114.2), (53, 97.4, 114.9), (54, 97.8, 115.5), (55, 98.3, 116.1),
        (56, 98.8, 116.7), (57, 99.3, 117.4), (58, 99.7, 118.0), (59, 100.2, 118.6), (60, 100.7, 119.2)
    ]

    private static let heightGirlsRanges: [GrowthRangeSample] = [
        (0, 45.4, 52.9), (1, 49.8, 57.6), (2, 53.0, 61.1), (3, 55.6, 64.0), (4, 57.8, 66.4), (5, 59.6, 68.5),
        (6, 61.2, 70.3), (7, 62.7, 71.9), (8, 64.0, 73.5), (9, 65.3, 75.0), (10, 66.5, 76.4),
        (11, 67.7, 77.8), (12, 68.9, 79.2), (13, 70.0, 80.5), (14, 71.0, 81.7), (15, 72.0, 83.0),
        (16, 73.0, 84.2), (17, 74.0, 85.4), (18, 74.9, 86.5), (19, 75.8, 87.6), (20, 76.7, 88.7),
        (21, 77.5, 89.8), (22, 78.4, 90.8), (23, 79.2, 91.9), (24, 79.3, 92.2), (25, 80.0, 93.1),
        (26, 80.8, 94.1), (27, 81.5, 95.0), (28, 82.2, 96.0), (29, 82.9, 96.9), (30, 83.6, 97.7),
        (31, 84.3, 98.6), (32, 84.9, 99.4), (33, 85.6, 100.3), (34, 86.2, 101.1), (35, 86.8, 101.9),
        (36, 87.4, 102.7), (37, 88.0, 103.4), (38, 88.6, 104.2), (39, 89.2, 105.0), (40, 89.8, 105.7),
        (41, 90.4, 106.4), (42, 90.9, 107.2), (43, 91.5, 107.9), (44, 92.0, 108.6), (45, 92.5, 109.3),
        (46, 93.1, 110.0), (47, 93.6, 110.7), (48, 94.1, 111.3), (49, 94.6, 112.0), (50, 95.1, 112.7),
        (51, 95.6, 113.3), (52, 96.1, 114.0), (53, 96.6, 114.6), (54, 97.1, 115.2), (55, 97.6, 115.9),
        (56, 98.1, 116.5), (57, 98.5, 117.1), (58, 99.0, 117.7), (59, 99.5, 118.3), (60, 99.9, 118.9)
    ]

    private static let weightBoysRanges: [GrowthRangeSample] = [
        (0, 2.5, 4.4), (1, 3.4, 5.8), (2, 4.3, 7.1), (3, 5.0, 8.0), (4, 5.6, 8.7), (5, 6.0, 9.3),
        (6, 6.4, 9.8), (7, 6.7, 10.3), (8, 6.9, 10.7), (9, 7.1, 11.0), (10, 7.4, 11.4), (11, 7.6, 11.7),
        (12, 7.7, 12.0), (13, 7.9, 12.3), (14, 8.1, 12.6), (15, 8.3, 12.8), (16, 8.4, 13.1), (17, 8.6, 13.4),
        (18, 8.8, 13.7), (19, 8.9, 13.9), (20, 9.1, 14.2), (21, 9.2, 14.5), (22, 9.4, 14.7), (23, 9.5, 15.0),
        (24, 9.7, 15.3), (25, 9.8, 15.5), (26, 10.0, 15.8), (27, 10.1, 16.1), (28, 10.2, 16.3),
        (29, 10.4, 16.6), (30, 10.5, 16.9), (31, 10.7, 17.1), (32, 10.8, 17.4), (33, 10.9, 17.6),
        (34, 11.0, 17.8), (35, 11.2, 18.1), (36, 11.3, 18.3), (37, 11.4, 18.6), (38, 11.5, 18.8),
        (39, 11.6, 19.0), (40, 11.8, 19.3), (41, 11.9, 19.5), (42, 12.0, 19.7), (43, 12.1, 20.0),
        (44, 12.2, 20.2), (45, 12.4, 20.5), (46, 12.5, 20.7), (47, 12.6, 20.9), (48, 12.7, 21.2),
        (49, 12.8, 21.4), (50, 12.9, 21.7), (51, 13.1, 21.9), (52, 13.2, 22.2), (53, 13.3, 22.4),
        (54, 13.4, 22.7), (55, 13.5, 22.9), (56, 13.6, 23.2), (57, 13.7, 23.4), (58, 13.8, 23.7),
        (59, 14.0, 23.9), (60, 14.1, 24.2)
    ]

    private static let weightGirlsRanges: [GrowthRangeSample] = [
        (0, 2.4, 4.2), (1, 3.2, 5.5), (2, 3.9, 6.6), (3, 4.5, 7.5), (4, 5.0, 8.2), (5, 5.4, 8.8),
        (6, 5.7, 9.3), (7, 6.0, 9.8), (8, 6.3, 10.2), (9, 6.5, 10.5), (10, 6.7, 10.9), (11, 6.9, 11.2),
        (12, 7.0, 11.5), (13, 7.2, 11.8), (14, 7.4, 12.1), (15, 7.6, 12.4), (16, 7.7, 12.6), (17, 7.9, 12.9),
        (18, 8.1, 13.2), (19, 8.2, 13.5), (20, 8.4, 13.7), (21, 8.6, 14.0), (22, 8.7, 14.3), (23, 8.9, 14.6),
        (24, 9.0, 14.8), (25, 9.2, 15.1), (26, 9.4, 15.4), (27, 9.5, 15.7), (28, 9.7, 16.0), (29, 9.8, 16.2),
        (30, 10.0, 16.5), (31, 10.1, 16.8), (32, 10.3, 17.1), (33, 10.4, 17.3), (34, 10.5, 17.6),
        (35, 10.7, 17.9), (36, 10.8, 18.1), (37, 10.9, 18.4), (38, 11.1, 18.7), (39, 11.2, 19.0),
        (40, 11.3, 19.2), (41, 11.5, 19.5), (42, 11.6, 19.8), (43, 11.7, 20.1), (44, 11.8, 20.4),
        (45, 12.0, 20.7), (46, 12.1, 20.9), (47, 12.2, 21.2), (48, 12.3, 21.5), (49, 12.4, 21.8),
        (50, 12.6, 22.1), (51, 12.7, 22.4), (52, 12.8, 22.6), (53, 12.9, 22.9), (54, 13.0, 23.2),
        (55, 13.2, 23.5), (56, 13.3, 23.8), (57, 13.4, 24.1), (58, 13.5, 24.4), (59, 13.6, 24.6),
        (60, 13.7, 24.9)
    ]

    private static func formatAgeTick(_ value: CGFloat, viewport: GrowthChartViewport) -> String {
        "\(Int(value.rounded()))"
    }

    private static func formatAxisValue(_ value: CGFloat) -> String {
        let rounded = value.rounded()
        if abs(value - rounded) < 0.01 {
            return "\(Int(rounded))"
        }
        return String(format: "%.1f", Double(value))
    }

    private static func fractionalMonths(from birth: Date, to date: Date) -> CGFloat {
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.year, .month, .day], from: birth)
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let yearDelta = (dateComponents.year ?? 0) - (birthComponents.year ?? 0)
        var months = yearDelta * 12 + ((dateComponents.month ?? 0) - (birthComponents.month ?? 0))
        if (dateComponents.day ?? 0) < (birthComponents.day ?? 0) {
            months -= 1
        }
        months = max(0, months)
        let anchor = calendar.date(byAdding: .month, value: months, to: birth) ?? birth
        let days = max(0, calendar.dateComponents([.day], from: anchor, to: date).day ?? 0)
        return CGFloat(months) + CGFloat(days) / 30.4375
    }
}

private enum GrowthColor {
    static let page = Color(hex: 0xF7F2EF)
    static let darkText = Color(hex: 0x464646)
    static let axisText = Color(hex: 0x8A8A8E)
    static let subText = Color(hex: 0xA4AAB2)
    static let grid = Color(hex: 0xD6D6D8)
    static let heightBand = Color(hex: 0xFFFBE0).opacity(0.72)
    static let weightBand = Color(hex: 0xEEF9F3).opacity(0.72)
    static let heightLine = Color(hex: 0xF8E56C)
    static let weightLine = Color(hex: 0x9EBDAE)
}

struct GrowthCurveView_Previews: PreviewProvider {
    static var previews: some View {
        GrowthCurveView()
            .environmentObject(GrowthCareStore())
    }
}
