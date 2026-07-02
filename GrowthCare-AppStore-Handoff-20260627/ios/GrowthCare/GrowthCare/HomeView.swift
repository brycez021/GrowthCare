import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var openSwipeVaccine: String?
    @State private var completedRevealHeight: CGFloat = 0
    @State private var completedRevealDragStartHeight: CGFloat = 0
    @State private var isDraggingCompletedReveal = false

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GCColor.page.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Color.clear.frame(height: topContentSpacer())
                        vaccineList
                        AddVaccineButton {
                            store.openAddVaccine()
                        }
                        Color.clear.frame(height: BottomTabBar.reservedHeight(for: proxy.safeAreaInsets.bottom) + 24)
                    }
                }
                .ignoresSafeArea()
                .simultaneousGesture(completedRevealGesture)

                HomeHeaderView(topInset: proxy.safeAreaInsets.top)

                VStack {
                    Spacer()
                    BottomNavShadow()
                }

                VStack {
                    Spacer()
                    BottomTabBar(bottomInset: proxy.safeAreaInsets.bottom)
                }

                if let overlay = store.activeOverlay {
                    HomeOverlayView(overlay: overlay)
                        .transition(.opacity)
                        .zIndex(30)
                }
            }
        }
        .animation(.easeInOut(duration: 0.22), value: store.activeOverlay)
        .onAppear {
            store.showHomeReviewIfNeeded()
        }
        .onChange(of: store.activeChildID) { _ in
            store.showHomeReviewIfNeeded()
        }
        .alert("提示", isPresented: toastBinding) {
            Button("好", role: .cancel) {
                store.toastMessage = nil
            }
        } message: {
            Text(store.toastMessage ?? "")
        }
    }

    private func topContentSpacer() -> CGFloat {
        guard store.nextAppointmentGroup() != nil else {
            return GCLayout.homeNoAppointmentTopBandHeight
                + GCLayout.homeNoAppointmentVaccineGap
                - GCLayout.vaccineTimelineRowVerticalPadding
        }

        return HomeHeaderView.appointmentCardBottomY
            + GCLayout.homeAppointmentVaccineGap
            - GCLayout.vaccineTimelineRowVerticalPadding
    }

    private var toastBinding: Binding<Bool> {
        Binding(
            get: { store.toastMessage != nil },
            set: { if !$0 { store.toastMessage = nil } }
        )
    }

    private var vaccineList: some View {
        let completed = store.visibleCompletedVaccines()
        let active = store.visibleActiveVaccines()
        let completedHeight = CGFloat(completed.count) * VaccineTimelineRow.rowOuterHeight
        let revealHeight = min(completedHeight, completedRevealHeight)

        return VStack(spacing: 0) {
            CompletedVaccineReveal(
                vaccines: completed,
                revealHeight: revealHeight,
                onHelp: { vaccineName in
                    store.openVaccineDetail(vaccineName)
                }
            )

            ForEach(active) { vaccine in
                VaccineTimelineRow(
                    vaccine: vaccine,
                    isOpen: openSwipeVaccine == vaccine.name,
                    onOpenSwipe: {
                        openSwipeVaccine = vaccine.name
                    },
                    onCloseSwipe: {
                        if openSwipeVaccine == vaccine.name {
                            openSwipeVaccine = nil
                        }
                    },
                    onHide: {
                        store.activeOverlay = .hideConfirm(vaccine.name)
                    },
                    onDoseTap: { dose in
                        switch dose.status {
                        case .future:
                            store.startBooking(vaccine: vaccine.name, dose: dose.number)
                        case .booked:
                            if let appointment = dose.appointment {
                                store.openEditPlan(appointment)
                            }
                        case .done:
                            break
                        }
                    },
                    onHelp: {
                        store.openVaccineDetail(vaccine.name)
                    }
                )
            }
        }
    }

    private var completedRevealGesture: some Gesture {
        DragGesture(minimumDistance: 8)
            .onChanged { value in
                let completedHeight = CGFloat(store.visibleCompletedVaccines().count) * VaccineTimelineRow.rowOuterHeight
                guard completedHeight > 0 else { return }
                if !isDraggingCompletedReveal {
                    completedRevealDragStartHeight = completedRevealHeight
                    isDraggingCompletedReveal = true
                }
                let nextHeight = completedRevealDragStartHeight + value.translation.height
                completedRevealHeight = min(completedHeight, max(0, nextHeight))
            }
            .onEnded { value in
                let completedHeight = CGFloat(store.visibleCompletedVaccines().count) * VaccineTimelineRow.rowOuterHeight
                guard completedHeight > 0 else {
                    completedRevealHeight = 0
                    completedRevealDragStartHeight = 0
                    isDraggingCompletedReveal = false
                    return
                }
                let projectedHeight = completedRevealDragStartHeight + value.predictedEndTranslation.height
                let threshold = min(80, completedHeight * 0.45)
                withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                    completedRevealHeight = projectedHeight > threshold ? completedHeight : 0
                }
                completedRevealDragStartHeight = 0
                isDraggingCompletedReveal = false
            }
    }
}

private struct HomeHeaderView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let topInset: CGFloat

    static let appointmentCardTopY: CGFloat = GCLayout.homeAppointmentCardTopY
    static let appointmentCardBottomY: CGFloat = appointmentCardTopY + NextAppointmentCard.height

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [GCColor.headerTop, GCColor.headerBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: headerHeight)
                .offset(y: -topInset)

                profileRow
                    .padding(.top, screenY(GCLayout.topSwitcherY))

                if let appointmentGroup = store.nextAppointmentGroup() {
                    NextAppointmentCard(appointmentGroup: appointmentGroup)
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, screenY(Self.appointmentCardTopY))
                }
            }
            .frame(height: overlayHeight, alignment: .top)

            Spacer(minLength: 0)
        }
    }

    private var headerHeight: CGFloat {
        store.nextAppointmentGroup() == nil ? GCLayout.homeNoAppointmentTopBandHeight : GCLayout.homeAppointmentTopBandHeight
    }

    private var overlayHeight: CGFloat {
        let visibleScreenHeight: CGFloat
        if store.nextAppointmentGroup() == nil {
            visibleScreenHeight = headerHeight
        } else {
            visibleScreenHeight = max(headerHeight, Self.appointmentCardBottomY)
        }
        return max(0, visibleScreenHeight - topInset)
    }

    private func screenY(_ value: CGFloat) -> CGFloat {
        value - topInset
    }

    private var profileRow: some View {
        HStack {
            ChildSwitcher()
            Spacer()
            Button {
                store.openCalendar()
            } label: {
                Image("rili")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .frame(width: 44, height: 44)
                    .background(Color.white.opacity(0.75))
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("日历")
        }
        .frame(height: GCLayout.childSwitcherHeight)
        .padding(.horizontal, 20)
    }
}

struct ChildSwitcher: View {
    @EnvironmentObject private var store: GrowthCareStore
    @Namespace private var childSwitcherNamespace

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(store.children.sorted { $0.birthDate < $1.birthDate }) { child in
                    if child.id == store.activeChild.id {
                        activePill(child)
                            .transition(.scale(scale: 0.96, anchor: .leading).combined(with: .opacity))
                    } else {
                        Button {
                            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                                store.switchChild(to: child.id)
                            }
                        } label: {
                            ChildAvatarImage(child: child)
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                .padding(2)
                                .background(childSwitcherColor(for: child))
                                .clipShape(Circle())
                                .matchedGeometryEffect(id: "child-avatar-\(child.id)", in: childSwitcherNamespace)
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("切换到\(child.name)")
                        .transition(.scale(scale: 0.92).combined(with: .opacity))
                    }
                }
            }
            .padding(.vertical, 1)
        }
        .frame(height: GCLayout.childSwitcherHeight)
        .animation(.spring(response: 0.34, dampingFraction: 0.78), value: store.activeChildID)
    }

    private func activePill(_ child: ChildProfile) -> some View {
        let tint = childSwitcherColor(for: child)

        return ZStack(alignment: .leading) {
            ChildSwitcherPillBackground()
                .fill(tint)
                .overlay {
                    ChildSwitcherPillBackground()
                        .stroke(Color.white.opacity(0.55), lineWidth: 0.8)
                }

            HStack(spacing: 11) {
                ChildAvatarImage(child: child)
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .padding(2)
                    .background(tint)
                    .clipShape(Circle())
                    .matchedGeometryEffect(id: "child-avatar-\(child.id)", in: childSwitcherNamespace)

                Text(child.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.horizontal, 20)
                    .frame(minHeight: 40, alignment: .center)
                    .contentTransition(.opacity)
            }
        }
        .fixedSize(horizontal: true, vertical: false)
        .frame(height: GCLayout.childSwitcherHeight)
    }

    private func childSwitcherColor(for child: ChildProfile) -> Color {
        Color(hex: 0xF47C7E)
    }
}

private struct ChildSwitcherPillBackground: Shape {
    func path(in rect: CGRect) -> Path {
        let scale = rect.height / 40
        let minX = rect.minX
        let minY = rect.minY
        let maxX = rect.maxX

        func x(_ value: CGFloat) -> CGFloat { minX + value * scale }
        func y(_ value: CGFloat) -> CGFloat { minY + value * scale }
        func xr(_ value: CGFloat) -> CGFloat { maxX - value * scale }

        var path = Path()
        path.move(to: CGPoint(x: xr(20), y: y(0)))
        path.addCurve(
            to: CGPoint(x: maxX, y: y(20)),
            control1: CGPoint(x: xr(8.954), y: y(0)),
            control2: CGPoint(x: maxX, y: y(8.954))
        )
        path.addCurve(
            to: CGPoint(x: xr(20), y: y(40)),
            control1: CGPoint(x: maxX, y: y(31.046)),
            control2: CGPoint(x: xr(8.954), y: y(40))
        )
        path.addLine(to: CGPoint(x: x(70), y: y(40)))
        path.addCurve(
            to: CGPoint(x: x(54.330), y: y(32.428)),
            control1: CGPoint(x: x(63.651), y: y(40)),
            control2: CGPoint(x: x(57.994), y: y(37.041))
        )
        path.addCurve(
            to: CGPoint(x: x(45), y: y(27)),
            control1: CGPoint(x: x(51.989), y: y(29.479)),
            control2: CGPoint(x: x(48.765), y: y(27))
        )
        path.addCurve(
            to: CGPoint(x: x(35.670), y: y(32.428)),
            control1: CGPoint(x: x(41.235), y: y(27)),
            control2: CGPoint(x: x(38.011), y: y(29.479))
        )
        path.addCurve(
            to: CGPoint(x: x(20), y: y(40)),
            control1: CGPoint(x: x(32.006), y: y(37.041)),
            control2: CGPoint(x: x(26.349), y: y(40))
        )
        path.addCurve(
            to: CGPoint(x: x(0), y: y(20)),
            control1: CGPoint(x: x(8.954), y: y(40)),
            control2: CGPoint(x: x(0), y: y(31.046))
        )
        path.addCurve(
            to: CGPoint(x: x(20), y: y(0)),
            control1: CGPoint(x: x(0), y: y(8.954)),
            control2: CGPoint(x: x(8.954), y: y(0))
        )
        path.addCurve(
            to: CGPoint(x: x(37.216), y: y(9.817)),
            control1: CGPoint(x: x(27.327), y: y(0)),
            control2: CGPoint(x: x(33.733), y: y(3.940))
        )
        path.addCurve(
            to: CGPoint(x: x(45), y: y(15)),
            control1: CGPoint(x: x(38.906), y: y(12.668)),
            control2: CGPoint(x: x(41.686), y: y(15))
        )
        path.addCurve(
            to: CGPoint(x: x(52.784), y: y(9.817)),
            control1: CGPoint(x: x(48.314), y: y(15)),
            control2: CGPoint(x: x(51.094), y: y(12.668))
        )
        path.addCurve(
            to: CGPoint(x: x(70), y: y(0)),
            control1: CGPoint(x: x(56.267), y: y(3.940)),
            control2: CGPoint(x: x(62.673), y: y(0))
        )
        path.closeSubpath()
        return path
    }
}

private struct NextAppointmentCard: View {
    static let height: CGFloat = 166

    @EnvironmentObject private var store: GrowthCareStore
    let appointmentGroup: NextAppointmentGroup

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: 0xFFF0EB).opacity(0.15), location: 0),
                                    .init(color: Color(hex: 0xFFF0EB).opacity(0.15), location: 0.4952),
                                    .init(color: Color(hex: 0xE9DDD9).opacity(0.3), location: 1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .stroke(Color.white.opacity(0.6), lineWidth: 0.8)
                }
                .shadow(color: Color(hex: 0xE2CAC2).opacity(0.30), radius: 13, x: 0, y: 9)

            Text("下一针预约时间")
                .font(.system(size: 16))
                .foregroundColor(.black)
                .padding(.leading, 32)
                .padding(.top, 26)

            HStack {
                ZStack {
                    Image("next-card-inner")
                        .resizable()
                        .scaledToFill()

                    HStack(spacing: 12) {
                        Capsule()
                            .fill(GCColor.textSecondary)
                            .frame(width: 2, height: 52)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .firstTextBaseline, spacing: 8) {
                                Text(store.fullDateText(appointmentGroup.date))
                                    .font(.system(size: 22, weight: .heavy))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.82)
                                    .fixedSize(horizontal: true, vertical: false)
                                Text(store.weekdayText(appointmentGroup.date))
                                    .font(.system(size: 14))
                                    .lineLimit(1)
                                    .fixedSize(horizontal: true, vertical: false)
                            }
                            .layoutPriority(2)

                            VStack(alignment: .leading, spacing: appointmentGroup.appointments.count > 2 ? 0 : 2) {
                                ForEach(appointmentGroup.appointments) { appointment in
                                    HStack(spacing: 8) {
                                        Text("\(appointment.vaccineName) 第\(appointment.doseNumber)剂")
                                            .font(.system(size: appointmentGroup.appointments.count > 2 ? 12 : 14))
                                            .foregroundColor(GCColor.textSecondary)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.76)
                                        Text("免费")
                                            .font(.system(size: 10))
                                            .foregroundColor(GCColor.textSecondary)
                                            .padding(.horizontal, 4)
                                            .frame(height: 14)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 3)
                                                    .stroke(GCColor.textSecondary, lineWidth: 0.5)
                                            )
                                    }
                                }
                            }
                        }
                        .layoutPriority(1)

                        Spacer(minLength: 8)

                        Button("修改计划") {
                            store.openEditPlan()
                        }
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 119, height: 44)
                        .background(GCColor.textSecondary)
                        .clipShape(Capsule())
                    }
                    .padding(.horizontal, 18)
                }
                .frame(height: 96)
            }
            .padding(.top, 56)
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
        }
        .frame(maxWidth: GCLayout.maxDesignWidth - 40)
        .frame(height: Self.height)
    }
}

private struct VaccineTimelineRow: View {
    static let rowOuterHeight: CGFloat = 118 + GCLayout.vaccineTimelineRowVerticalPadding * 2

    let vaccine: VaccineCardData
    let isOpen: Bool
    let onOpenSwipe: () -> Void
    let onCloseSwipe: () -> Void
    let onHide: () -> Void
    let onDoseTap: (VaccineDose) -> Void
    let onHelp: () -> Void

    @State private var dragOffset: CGFloat = 0

    private var effectiveOffset: CGFloat {
        isOpen ? -110 + dragOffset : dragOffset
    }

    private var swipeGesture: some Gesture {
        DragGesture(minimumDistance: 12)
            .onChanged { value in
                let base: CGFloat = isOpen ? -110 : 0
                dragOffset = max(-110 - base, min(0 - base, value.translation.width))
            }
            .onEnded { value in
                let shouldOpen = (isOpen ? -110 : 0) + value.translation.width < -38
                dragOffset = 0
                if shouldOpen {
                    onOpenSwipe()
                } else {
                    onCloseSwipe()
                }
            }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            VStack(spacing: 15) {
                Image("zhentou")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 22)

                RoundedRectangle(cornerRadius: 8)
                    .fill(timelineColor)
                    .frame(width: 14, height: 72)
            }
            .frame(width: 18, height: 94)

            ZStack(alignment: .trailing) {
                HStack {
                    Spacer()
                    Button {
                        onHide()
                    } label: {
                        Image(systemName: "eye.slash")
                            .font(.system(size: 26, weight: .regular))
                            .foregroundColor(Color(hex: 0xF0AD4E))
                            .frame(width: 110, height: 118)
                            .background(Color(hex: 0xFEF9E6))
                            .clipShape(
                                UnevenRoundedRectangle(
                                    topLeadingRadius: 0,
                                    bottomLeadingRadius: 0,
                                    bottomTrailingRadius: 30,
                                    topTrailingRadius: 30
                                )
                            )
                    }
                    .buttonStyle(.plain)
                }

                VaccineCard(
                    vaccine: vaccine,
                    onDoseTap: onDoseTap,
                    onHelp: onHelp
                )
                .offset(x: effectiveOffset)
                .animation(.easeOut(duration: 0.24), value: isOpen)
            }
            .contentShape(Rectangle())
            .highPriorityGesture(swipeGesture)
            .frame(minHeight: 118)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, GCLayout.vaccineTimelineRowVerticalPadding)
    }

    private var timelineColor: Color {
        if vaccine.hasMissedDose {
            return GCColor.headerTop
        }
        if vaccine.dueNow {
            return GCColor.pinkAccent
        }
        return Color(hex: 0xE1E1E1)
    }
}

private struct CompletedVaccineReveal: View {
    let vaccines: [VaccineCardData]
    let revealHeight: CGFloat
    let onHelp: (String) -> Void

    private var fullHeight: CGFloat {
        CGFloat(vaccines.count) * VaccineTimelineRow.rowOuterHeight
    }

    var body: some View {
        VStack(spacing: 0) {
            ForEach(vaccines) { vaccine in
                VaccineTimelineRow(
                    vaccine: vaccine,
                    isOpen: false,
                    onOpenSwipe: {},
                    onCloseSwipe: {},
                    onHide: {},
                    onDoseTap: { _ in },
                    onHelp: {
                        onHelp(vaccine.name)
                    }
                )
                .allowsHitTesting(revealHeight > VaccineTimelineRow.rowOuterHeight * 0.6)
            }
        }
        .frame(height: fullHeight, alignment: .bottom)
        .frame(height: revealHeight, alignment: .bottom)
        .clipped()
    }
}

private struct VaccineCard: View {
    let vaccine: VaccineCardData
    let onDoseTap: (VaccineDose) -> Void
    let onHelp: () -> Void

    var body: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(vaccine.isCompleted ? Color(hex: 0xFAFAFA) : Color.white)

            if vaccine.doses.count > 1 && !vaccine.isCompleted {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.white)
                    .frame(width: 14.5, height: 65)
                    .offset(x: 14.5, y: 40)
            }

            VStack(alignment: .leading, spacing: 7) {
                HStack {
                    Text(vaccine.name)
                        .font(.system(size: 18))
                        .foregroundColor(vaccine.isCompleted ? Color(hex: 0x8D8D8D) : .black)
                    Spacer()
                    Button {
                        onHelp()
                    } label: {
                        Image("kepuwenhao")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                            .opacity(0.6)
                    }
                    .buttonStyle(.plain)
                }
                .frame(height: 24)

                HStack(alignment: .top, spacing: 16) {
                    ForEach(vaccine.doses) { dose in
                        DoseCircleView(dose: dose) {
                            if dose.status != .done {
                                onDoseTap(dose)
                            }
                        }
                    }
                }
                .padding(.leading, 2)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 118)
    }
}

private struct DoseCircleView: View {
    let dose: VaccineDose
    let action: () -> Void

    var body: some View {
        VStack(spacing: 4) {
            Button(action: action) {
                ZStack {
                    Image(assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 48, height: 48)

                    if dose.status == .future {
                        Text("\(dose.number)")
                            .font(.system(size: 32))
                            .foregroundColor(Color(hex: 0xE0E0E0))
                    }
                }
                .frame(width: 48, height: 48)
            }
            .buttonStyle(.plain)
            .allowsHitTesting(dose.status != .done)

            Text(dose.dateText)
                .font(.system(size: 10))
                .foregroundColor(GCColor.textMuted)
                .lineLimit(1)
        }
        .frame(width: 48)
    }

    private var assetName: String {
        switch dose.status {
        case .done:
            return "yizhongqiu"
        case .booked:
            return "yuyueqiu"
        case .future:
            let index = min(5, max(1, dose.number))
            return ["", "xuxianqiuyi", "xuxianqiuer", "xuxianqiusan", "xuxianqiusi", "xuxianqiuwu"][index]
        }
    }
}

private struct AddVaccineButton: View {
    let action: () -> Void

    var body: some View {
        HStack {
            Spacer(minLength: 54)
            Button(action: action) {
                AddVaccinePlusIcon()
                    .frame(maxWidth: .infinity)
                    .frame(height: 113)
                    .background(GCColor.navBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 7)
        .padding(.trailing, 20)
        .padding(.bottom, 24)
    }
}

private struct AddVaccinePlusIcon: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 44, height: 3.6)

            Capsule()
                .fill(Color.black)
                .frame(width: 3.6, height: 44)
        }
        .frame(width: 44, height: 44)
    }
}

struct BottomNavShadow: View {
    var body: some View {
        LinearGradient(
            colors: [Color.black.opacity(0), Color.black.opacity(0.10)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: 64)
        .frame(maxWidth: .infinity)
        .padding(.bottom, BottomTabBar.height)
        .allowsHitTesting(false)
    }
}

struct BottomTabBar: View {
    @EnvironmentObject private var store: GrowthCareStore
    let bottomInset: CGFloat

    static let height: CGFloat = GCLayout.bottomTabBarHeight

    static func reservedHeight(for bottomInset: CGFloat) -> CGFloat {
        height + max(bottomInset, GCLayout.tabBarMinimumBottomInset)
    }

    var body: some View {
        ZStack(alignment: .top) {
            GCColor.navBackground
                .ignoresSafeArea(edges: .bottom)

            HStack {
                ForEach(AppTab.allCases) { tab in
                    tabButton(tab)

                    if tab != AppTab.allCases.last {
                        Spacer()
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, GCLayout.bottomTabBarTopPadding)
            .frame(height: Self.height, alignment: .top)
        }
        .frame(height: Self.height)
    }

    private func tabButton(_ tab: AppTab) -> some View {
        Button {
            store.selectTab(tab)
        } label: {
            ZStack(alignment: .top) {
                Image(store.selectedTab == tab ? tab.selectedAsset : tab.unselectedAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: GCLayout.bottomTabIconSize, height: GCLayout.bottomTabIconSize)
                    .frame(width: GCLayout.bottomTabItemWidth, alignment: .center)

                Text(tab.title)
                    .font(.system(size: 10))
                    .foregroundColor(store.selectedTab == tab ? GCColor.pinkAccent : GCColor.pinkMuted)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(width: GCLayout.bottomTabItemWidth)
                    .offset(y: GCLayout.bottomTabLabelTop)
            }
            .frame(width: GCLayout.bottomTabItemWidth, height: Self.height - GCLayout.bottomTabBarTopPadding, alignment: .top)
        }
        .buttonStyle(.plain)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(GrowthCareStore())
    }
}
