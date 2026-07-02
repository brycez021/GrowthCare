import SwiftUI

struct VaccineDetailView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let vaccineName: String
    @State private var selectedTab: VaccineDetailTab
    @Namespace private var vaccineDetailSegmentSelection

    private var info: VaccineInfo? {
        VaccineInfoStore.info(for: vaccineName)
    }

    init(vaccineName: String, initialTab: VaccineDetailTab = .intro) {
        self.vaccineName = vaccineName
        _selectedTab = State(initialValue: initialTab)
    }

    var body: some View {
        GeometryReader { proxy in
            VStack(spacing: 0) {
                header()
                content(bottomInset: proxy.safeAreaInsets.bottom)
            }
            .frame(width: proxy.size.width, height: proxy.size.height, alignment: .top)
            .background(VaccineDetailColor.page.ignoresSafeArea())
        }
        .navigationBarBackButtonHidden(true)
    }

    private func header() -> some View {
        ZStack(alignment: .topLeading) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
                .ignoresSafeArea(edges: .top)

            Button {
                store.popNavigation()
            } label: {
                Image("fanhui")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.75))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("返回")
            .padding(.leading, 20)
            .padding(.top, 14)

            detailSegment
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        }
        .frame(height: 143)
    }

    private var detailSegment: some View {
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
                ForEach(VaccineDetailTab.allCases) { tab in
                    Button {
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                            selectedTab = tab
                        }
                    } label: {
                        ZStack {
                            if selectedTab == tab {
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.75), Color.white.opacity(0.9)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                    .shadow(color: .black.opacity(0.1), radius: 4)
                                    .matchedGeometryEffect(id: "vaccineDetailSegmentSelection", in: vaccineDetailSegmentSelection)
                            }

                            Text(tab.title)
                                .font(.system(size: 16))
                                .foregroundColor(.black)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: GCLayout.growthSegmentButtonHeight)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 4)
            .frame(height: GCLayout.growthSegmentHeight)
        }
        .frame(height: GCLayout.growthSegmentHeight)
    }

    private func content(bottomInset: CGFloat) -> some View {
        Group {
            if selectedTab == .intro {
                introContent(bottomInset: bottomInset)
            } else {
                precautionsContent(bottomInset: bottomInset)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(VaccineDetailColor.page)
    }

    private func introContent(bottomInset: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 28) {
                Text(info?.intro ?? "暂无「\(vaccineName)」的科普内容，请咨询接种门诊。")
                    .font(.system(size: 16))
                    .lineSpacing(8)
                    .foregroundColor(VaccineDetailColor.bodyText)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 32)

                VStack(alignment: .leading, spacing: 26) {
                    DetailSectionLabel("什么时候接种？")

                    VaccineScheduleInfoTable(rows: info?.schedule ?? [])

                    DetailSectionLabel("为什么要接种？")
                        .padding(.top, 8)

                    reasonsList

                    DetailSectionLabel("有哪些副作用？")
                        .padding(.top, 14)

                    sideEffectsList
                }
                .padding(24)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .padding(.horizontal, 24)
            }
            .padding(.top, 32)
            .padding(.bottom, bottomInset + 48)
        }
    }

    private var reasonsList: some View {
        VStack(alignment: .leading, spacing: 30) {
            ForEach(Array((info?.reasons ?? []).enumerated()), id: \.offset) { index, reason in
                HStack(alignment: .top, spacing: 18) {
                    Text("\(index + 1)")
                        .font(.system(size: 24))
                        .foregroundColor(.black)
                        .frame(width: 54, height: 54)
                        .background(VaccineDetailColor.numberBackground)
                        .overlay(
                            Circle()
                                .stroke(VaccineDetailColor.numberBorder, lineWidth: 1)
                        )
                        .clipShape(Circle())

                    Text(reason)
                        .font(.system(size: 16))
                        .lineSpacing(8)
                        .foregroundColor(VaccineDetailColor.bodyText)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    private var sideEffectsList: some View {
        VStack(alignment: .leading, spacing: 18) {
            SideEffectBlock(title: "常见反应：", text: info?.sideEffects.common ?? "请咨询接种门诊。")
            SideEffectBlock(title: "极罕见反应：", text: info?.sideEffects.rare ?? "请咨询接种门诊。")
        }
    }

    private func precautionsContent(bottomInset: CGFloat) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 26) {
                if let precautions = info?.precautions {
                    PrecautionBlock(label: precautions.health.title, text: precautions.health.text)
                    PrecautionBlock(label: precautions.allergy.title, text: precautions.allergy.text)
                    DelayPrecautionBlock(delay: precautions.delay)
                } else {
                    Text("请咨询接种门诊了解注意事项。")
                        .font(.system(size: 16))
                        .lineSpacing(8)
                        .foregroundColor(VaccineDetailColor.bodyText)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, bottomInset + 48)
        }
    }
}

private enum VaccineDetailColor {
    static let page = Color(hex: 0xF5F1F1)
    static let arrow = Color(hex: 0x4A4A4A)
    static let text = Color.black
    static let bodyText = Color(hex: 0x555555)
    static let sectionLabel = Color(hex: 0xD6E4D8)
    static let sectionDot = Color(hex: 0x617363)
    static let tableHeader = Color(hex: 0xF3EDE7)
    static let tableBorder = Color(hex: 0xCFCFCF)
    static let numberBackground = Color(hex: 0xEFE4DA)
    static let numberBorder = Color(hex: 0xD0C4B8)
}

private struct DetailSectionLabel: View {
    let title: String

    init(_ title: String) {
        self.title = title
    }

    var body: some View {
        HStack(spacing: 9) {
            Circle()
                .fill(VaccineDetailColor.sectionDot)
                .frame(width: 6, height: 6)
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.black)
        }
        .padding(.horizontal, 14)
        .frame(height: 30)
        .background(VaccineDetailColor.sectionLabel)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .fixedSize(horizontal: true, vertical: false)
    }
}

private struct VaccineScheduleInfoTable: View {
    let rows: [VaccineScheduleInfoRow]

    var body: some View {
        VStack(spacing: 0) {
            VaccineScheduleInfoTableRow(
                values: ["针次", "推荐接种时间", "说明"],
                isHeader: true,
                isFirstColumnHighlighted: true,
                rowHeight: 44
            )

            if rows.isEmpty {
                VaccineScheduleInfoTableRow(
                    values: ["", "", "请咨询接种门诊了解具体接种时间。"],
                    isHeader: false,
                    isFirstColumnHighlighted: true,
                    rowHeight: 92
                )
            } else {
                ForEach(rows) { row in
                    VaccineScheduleInfoTableRow(
                        values: [row.dose, row.time, row.note],
                        isHeader: false,
                        isFirstColumnHighlighted: true,
                        rowHeight: rowHeight(for: row)
                    )
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 2, style: .continuous))
        .overlay(
            Rectangle()
                .stroke(VaccineDetailColor.tableBorder, lineWidth: 1)
        )
    }

    private func rowHeight(for row: VaccineScheduleInfoRow) -> CGFloat {
        row.note.count > 28 ? 104 : 82
    }
}

private struct VaccineScheduleInfoTableRow: View {
    let values: [String]
    let isHeader: Bool
    let isFirstColumnHighlighted: Bool
    let rowHeight: CGFloat

    var body: some View {
        GeometryReader { proxy in
            HStack(spacing: 0) {
                VaccineScheduleInfoCell(
                    text: values[safe: 0] ?? "",
                    width: proxy.size.width * 0.18,
                    isHighlighted: isHeader || isFirstColumnHighlighted,
                    alignLeading: false
                )
                VaccineScheduleInfoCell(
                    text: values[safe: 1] ?? "",
                    width: proxy.size.width * 0.34,
                    isHighlighted: isHeader,
                    alignLeading: false
                )
                VaccineScheduleInfoCell(
                    text: values[safe: 2] ?? "",
                    width: proxy.size.width * 0.48,
                    isHighlighted: isHeader,
                    alignLeading: !isHeader
                )
            }
        }
        .frame(height: rowHeight)
    }
}

private struct VaccineScheduleInfoCell: View {
    let text: String
    let width: CGFloat
    let isHighlighted: Bool
    let alignLeading: Bool

    var body: some View {
        Text(text)
            .font(.system(size: 16))
            .lineSpacing(5)
            .foregroundColor(VaccineDetailColor.bodyText)
            .multilineTextAlignment(alignLeading ? .leading : .center)
            .padding(.horizontal, alignLeading ? 8 : 4)
            .frame(width: width, alignment: alignLeading ? .leading : .center)
            .frame(maxHeight: .infinity, alignment: alignLeading ? .leading : .center)
            .background(isHighlighted ? VaccineDetailColor.tableHeader : Color.white)
            .overlay(
                Rectangle()
                    .stroke(VaccineDetailColor.tableBorder, lineWidth: 1)
            )
    }
}

private struct SideEffectBlock: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top, spacing: 8) {
                Text("•")
                Text(title)
            }
            .font(.system(size: 16))
            .foregroundColor(.black)

            Text(text)
                .font(.system(size: 16))
                .lineSpacing(8)
                .foregroundColor(VaccineDetailColor.bodyText)
                .padding(.leading, 24)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct PrecautionBlock: View {
    let label: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            DetailSectionLabel(label)
            Text(text)
                .font(.system(size: 16))
                .lineSpacing(8)
                .foregroundColor(VaccineDetailColor.bodyText)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

private struct DelayPrecautionBlock: View {
    let delay: VaccineDelayPrecaution

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            DetailSectionLabel(delay.title)
            Text(delay.intro)
                .font(.system(size: 16))
                .lineSpacing(8)
                .foregroundColor(VaccineDetailColor.bodyText)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(delay.items, id: \.self) { item in
                    HStack(alignment: .top, spacing: 8) {
                        Text("•")
                        Text(item)
                    }
                    .font(.system(size: 16))
                    .lineSpacing(8)
                    .foregroundColor(VaccineDetailColor.bodyText)
                }
            }
            .padding(.leading, 8)
        }
    }
}

private extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

struct VaccineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VaccineDetailView(vaccineName: "乙肝疫苗")
            .environmentObject(GrowthCareStore())
    }
}
