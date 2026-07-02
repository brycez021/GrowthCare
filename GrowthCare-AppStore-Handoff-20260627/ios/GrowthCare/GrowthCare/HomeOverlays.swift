import SwiftUI

struct HomeOverlayView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let overlay: HomeOverlay

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    if case .pastDoseReview = overlay {
                        return
                    }
                    if case .appointmentReview = overlay {
                        return
                    }
                    store.activeOverlay = nil
                }

            VStack(spacing: 16) {
                switch overlay {
                case .bookingDate(let booking):
                    BookingDateOverlay(booking: booking)
                case .clinic(let booking):
                    ClinicOverlay(booking: booking)
                case .clinicSelect(let booking):
                    ClinicSelectOverlay(booking: booking)
                case .clinicAddressInput(let booking):
                    ClinicAddressInputOverlay(booking: booking)
                case .confirm(let booking):
                    ConfirmBookingOverlay(booking: booking)
                case .editPlan(let appointment, let displayMode):
                    EditPlanOverlay(appointment: appointment, displayMode: displayMode)
                case .pastDoseReview(let childID):
                    PastDoseReviewOverlay(childID: childID)
                case .appointmentReview:
                    AppointmentReviewOverlay()
                case .hideConfirm(let vaccine):
                    HideConfirmOverlay(vaccineName: vaccine)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

private struct AppointmentReviewOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var selectedIDs: Set<String> = []

    private var items: [AppointmentReviewItem] {
        store.dueAppointmentReviewItems()
    }

    var body: some View {
        ModalCard {
            VStack(spacing: 0) {
                Text("确认已接种疫苗")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 24)

                Text("请勾选预约日后已经完成接种的针次；未勾选的针次会回到未预约状态，并在首页标红提醒。")
                    .font(.system(size: 13))
                    .foregroundColor(GCColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            appointmentReviewRow(item)
                            if item.id != items.last?.id {
                                Divider()
                                    .background(Color(hex: 0xD3D3D3))
                                    .padding(.leading, 58)
                            }
                        }
                    }
                }
                .frame(maxHeight: 360)
                .padding(.horizontal, 20)
                .padding(.top, 18)

                Button {
                    store.confirmDueAppointmentReview(completedItemIDs: selectedIDs)
                } label: {
                    Text("确认")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(GCColor.headerTop)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 22)
            }
        }
    }

    private func appointmentReviewRow(_ item: AppointmentReviewItem) -> some View {
        Button {
            if selectedIDs.contains(item.id) {
                selectedIDs.remove(item.id)
            } else {
                selectedIDs.insert(item.id)
            }
        } label: {
            HStack(spacing: 12) {
                let isSelected = selectedIDs.contains(item.id)
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(isSelected ? GCColor.headerTop : Color(hex: 0xCCCCCC), lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GCColor.headerTop)
                    }
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Text("预约时间 \(item.appointmentDateText) · \(item.clinic)")
                        .font(.system(size: 12))
                        .foregroundColor(GCColor.textMuted)
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct PastDoseReviewOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let childID: String
    @State private var selectedIDs: Set<String> = []

    private var childName: String {
        store.children.first { $0.id == childID }?.name ?? "孩子"
    }

    private var items: [PastDoseReviewItem] {
        store.pastDoseReviewItems(childID: childID)
    }

    var body: some View {
        ModalCard {
            VStack(spacing: 0) {
                Text("确认已接种疫苗")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.top, 24)

                Text("请勾选\(childName)此前已经接种的剂次；未勾选的疫苗会在首页标红提醒。")
                    .font(.system(size: 13))
                    .foregroundColor(GCColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
                    .padding(.top, 10)

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(items) { item in
                            reviewRow(item)
                            if item.id != items.last?.id {
                                Divider()
                                    .background(Color(hex: 0xD3D3D3))
                                    .padding(.leading, 52)
                            }
                        }
                    }
                }
                .frame(maxHeight: 320)
                .padding(.horizontal, 20)
                .padding(.top, 18)

                Button {
                    store.confirmPastDoseReview(childID: childID, completedItemIDs: selectedIDs)
                } label: {
                    Text("确认")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(GCColor.headerTop)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 22)
            }
        }
    }

    private func reviewRow(_ item: PastDoseReviewItem) -> some View {
        Button {
            if selectedIDs.contains(item.id) {
                selectedIDs.remove(item.id)
            } else {
                selectedIDs.insert(item.id)
            }
        } label: {
            HStack(spacing: 12) {
                let isSelected = selectedIDs.contains(item.id)
                ZStack {
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .strokeBorder(isSelected ? GCColor.headerTop : Color(hex: 0xCCCCCC), lineWidth: 1.5)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(GCColor.headerTop)
                    }
                }
                .frame(width: 30, height: 30)

                VStack(alignment: .leading, spacing: 4) {
                    Text(item.title)
                        .font(.system(size: 16))
                        .foregroundColor(.black)
                    Text("推荐时间 \(item.recommendedDateText)")
                        .font(.system(size: 12))
                        .foregroundColor(GCColor.textMuted)
                }

                Spacer(minLength: 0)
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ProgressCard: View {
    let title: String
    let step: Int
    var showsProgress = true
    var onStepTapped: ((Int) -> Void)?

    var body: some View {
        VStack(spacing: 14) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity, alignment: .center)

            if showsProgress {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(GCColor.progressLine)
                        .frame(height: 3)
                        .padding(.horizontal, 10)

                    Capsule()
                        .fill(Color(hex: 0xF1A7A8))
                        .frame(width: fillWidth, height: 3)
                        .padding(.leading, 10)

                    HStack {
                        ForEach(1...3, id: \.self) { index in
                            progressDot(index)
                            if index < 3 { Spacer() }
                        }
                    }
                }
                .frame(height: 7)
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, showsProgress ? 19 : 22)
        .padding(.bottom, showsProgress ? 16 : 22)
        .frame(maxWidth: GCLayout.maxDesignWidth - 40)
        .background(Color.white.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private var fillWidth: CGFloat {
        switch step {
        case 2: return 170
        case 3: return 340
        default: return 0
        }
    }

    @ViewBuilder
    private func progressDot(_ index: Int) -> some View {
        let dot = Circle()
            .fill(index <= step ? GCColor.headerTop : GCColor.progressLine)
            .frame(width: 7, height: 7)

        if let onStepTapped, index < step {
            Button {
                onStepTapped(index)
            } label: {
                dot
            }
            .buttonStyle(.plain)
            .frame(width: 28, height: 28)
            .contentShape(Rectangle())
        } else {
            dot
        }
    }
}

private struct ModalCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .frame(maxWidth: GCLayout.maxDesignWidth - 40)
            .background(Color.white.opacity(0.98))
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct BookingDateOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let booking: PendingBooking

    @State private var viewMonth: Date
    @State private var selectedDate: Date

    init(booking: PendingBooking) {
        self.booking = booking
        let calendar = Calendar.current
        let bookingMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: booking.date)) ?? booking.date
        let currentMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
        let initialMonth = calendar.compare(bookingMonth, to: currentMonth, toGranularity: .month) == .orderedAscending ? currentMonth : bookingMonth
        let initialDate = calendar.startOfDay(for: booking.date) < calendar.startOfDay(for: Date()) ? Date() : booking.date
        _viewMonth = State(initialValue: initialMonth)
        _selectedDate = State(initialValue: initialDate)
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressCard(
                title: "接种预定时间",
                step: 1,
                showsProgress: !booking.isEditingExistingAppointment
            )

            ModalCard {
                VStack(spacing: 0) {
                    monthHeader
                    weekdays
                    calendarGrid
                    footer
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 24)
                .frame(minHeight: 397, alignment: .top)
            }
        }
    }

    private var monthHeader: some View {
        HStack(spacing: 24) {
            if canGoToPreviousMonth {
                Button {
                    let previous = Calendar.current.date(byAdding: .month, value: -1, to: viewMonth) ?? viewMonth
                    if Calendar.current.compare(previous, to: currentMonthStart, toGranularity: .month) != .orderedAscending {
                        viewMonth = previous
                    }
                } label: {
                    Image("jiantouyihao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 9, height: 14)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            } else {
                Color.clear
                    .frame(width: 28, height: 28)
            }

            Text(monthTitle(viewMonth))
                .font(.system(size: 16))
                .foregroundColor(GCColor.textMuted)
                .frame(width: 120)

            Button {
                viewMonth = Calendar.current.date(byAdding: .month, value: 1, to: viewMonth) ?? viewMonth
            } label: {
                Image("jiantouerhao")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 14)
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 16)
    }

    private var currentMonthStart: Date {
        let calendar = Calendar.current
        return calendar.date(from: calendar.dateComponents([.year, .month], from: Date())) ?? Date()
    }

    private var canGoToPreviousMonth: Bool {
        Calendar.current.compare(viewMonth, to: currentMonthStart, toGranularity: .month) == .orderedDescending
    }

    private var weekdays: some View {
        HStack {
            ForEach(["周日", "周一", "周二", "周三", "周四", "周五", "周六"], id: \.self) { day in
                Text(day)
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textMuted)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 22)
        .padding(.bottom, 8)
    }

    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 0) {
            ForEach(calendarCells.indices, id: \.self) { index in
                let day = calendarCells[index]
                if let day {
                    dayCell(day)
                } else {
                    Color.clear
                        .frame(height: 44)
                        .overlay(alignment: .top) {
                            Divider().background(Color(hex: 0xD3D3D3))
                        }
                }
            }
        }
        .overlay(alignment: .top) {
            Divider().background(Color(hex: 0xD3D3D3))
        }
        .frame(minHeight: 214, alignment: .top)
    }

    private func dayCell(_ day: Int) -> some View {
        let date = dateFor(day: day)
        let disabled = Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: Date())
        let selected = Calendar.current.isDate(date, inSameDayAs: selectedDate)

        return Button {
            if !disabled {
                selectedDate = date
            }
        } label: {
            ZStack {
                if selected {
                    Circle()
                        .fill(GCColor.textSecondary)
                        .frame(width: 28, height: 28)
                    Text("\(day)")
                        .foregroundColor(.white)
                } else {
                    Text("\(day)")
                        .foregroundColor(disabled ? Color(hex: 0xCECCD1) : .black)
                }
            }
            .font(.system(size: 12, weight: .medium))
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .overlay(alignment: .bottom) {
            Divider().background(Color(hex: 0xD3D3D3))
        }
    }

    private var footer: some View {
        HStack(spacing: 20) {
            Button("取消") {
                if booking.isEditingExistingAppointment {
                    store.activeOverlay = .editPlan(appointment(from: booking), booking.editPlanDisplayMode)
                } else {
                    store.activeOverlay = nil
                }
            }
            .modalButton(background: GCColor.cancelButton)

            Button(booking.isEditingExistingAppointment ? "确定" : "下一步") {
                var next = booking
                next.date = selectedDate
                if booking.isEditingExistingAppointment {
                    store.updateAppointmentDateAndReturnToEdit(next)
                } else {
                    store.activeOverlay = .clinic(next)
                }
            }
            .modalButton(
                background: GCColor.headerTop,
                foreground: .white
            )
        }
        .padding(.top, 20)
    }

    private func appointment(from booking: PendingBooking) -> Appointment {
        Appointment(
            childID: store.activeChildID,
            vaccineName: booking.vaccineName,
            doseNumber: booking.doseNumber,
            date: booking.date,
            clinic: booking.clinic,
            remark: booking.remark
        )
    }

    private var calendarCells: [Int?] {
        let calendar = Calendar.current
        let comps = calendar.dateComponents([.year, .month], from: viewMonth)
        let first = calendar.date(from: comps) ?? viewMonth
        let weekday = calendar.component(.weekday, from: first) - 1
        let days = calendar.range(of: .day, in: .month, for: first)?.count ?? 30
        return Array(repeating: nil, count: weekday) + Array(1...days).map(Optional.some)
    }

    private func dateFor(day: Int) -> Date {
        let calendar = Calendar.current
        var comps = calendar.dateComponents([.year, .month], from: viewMonth)
        comps.day = day
        return calendar.date(from: comps) ?? viewMonth
    }

    private func monthTitle(_ date: Date) -> String {
        let comps = Calendar.current.dateComponents([.year, .month], from: date)
        return "\(comps.year ?? 2026) 年 \(comps.month ?? 1) 月"
    }
}

private struct ClinicOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let booking: PendingBooking

    var body: some View {
        VStack(spacing: 16) {
            ProgressCard(
                title: "接种门诊",
                step: 2,
                showsProgress: !booking.isEditingExistingAppointment
            )

            ModalCard {
                VStack(spacing: 0) {
                    Button {
                        store.activeOverlay = .clinicSelect(booking)
                    } label: {
                        ClinicInfoRow(
                            icon: "jiezhongmenzhen",
                            title: "接种门诊",
                            detail: booking.clinic,
                            showsArrow: true
                        )
                    }
                    .buttonStyle(.plain)

                    divider

                    ClinicInfoRow(icon: "xiangxidizhi", title: "详细地址", detail: "西岗区高尔基路188-194号")
                    divider
                    ClinicInfoRow(icon: "yingyeshijian", title: "营业时间", detail: "8:00-11:00  13:00-17:00")

                    HStack(spacing: 20) {
                        Button("取消") { store.activeOverlay = nil }
                            .modalButton(background: GCColor.cancelButton)
                        Button("下一步") {
                            store.activeOverlay = .confirm(booking)
                        }
                        .modalButton(background: GCColor.headerTop, foreground: .white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
    }

    private var divider: some View {
        Divider()
            .background(Color(hex: 0xD3D3D3))
            .padding(.horizontal, 20)
    }
}

private struct ClinicInfoRow: View {
    let icon: String
    let title: String
    let detail: String
    var showsArrow = false

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(icon)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
                .padding(.top, 2)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                Text(detail)
                    .font(.system(size: 14))
                    .foregroundColor(GCColor.textSecondary)
                    .lineLimit(2)
            }
            Spacer()

            if showsArrow {
                Image("jiantouerhao")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 9, height: 14)
                    .padding(.top, 8)
            }
        }
        .padding(.leading, 16)
        .padding(.trailing, 20)
        .padding(.vertical, 20)
    }
}

private struct ClinicSelectOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let booking: PendingBooking
    @State private var selectedClinic: String

    init(booking: PendingBooking) {
        self.booking = booking
        _selectedClinic = State(initialValue: booking.clinic)
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressCard(
                title: "接种门诊",
                step: 2,
                showsProgress: !booking.isEditingExistingAppointment
            )

            ModalCard {
                VStack(spacing: 0) {
                    HStack {
                        Button {
                            if booking.isEditingExistingAppointment {
                                store.activeOverlay = .editPlan(appointment(from: booking), booking.editPlanDisplayMode)
                            } else {
                                store.activeOverlay = .clinic(booking)
                            }
                        } label: {
                            Image("jiantouyihao")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 9, height: 14)
                                .frame(width: 28, height: 28)
                        }
                        .buttonStyle(.plain)
                        .offset(x: -8)
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 2)

                    ForEach(store.clinics) { clinic in
                        Button {
                            if booking.isEditingExistingAppointment {
                                selectedClinic = clinic.name
                            } else {
                                var next = booking
                                next.clinic = clinic.name
                                store.activeOverlay = .clinic(next)
                            }
                        } label: {
                            HStack(spacing: 20) {
                                ZStack {
                                    Circle()
                                        .stroke(clinic.name == selectedClinic ? GCColor.pinkAccent : Color(hex: 0xCCCCCC), lineWidth: 2)
                                        .frame(width: 23, height: 23)
                                    if clinic.name == selectedClinic {
                                        Circle()
                                            .fill(GCColor.pinkAccent)
                                            .frame(width: 11, height: 11)
                                    }
                                }

                                Text(clinic.name)
                                    .font(.system(size: 16))
                                    .foregroundColor(.black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.leading, 16)
                            .padding(.trailing, 20)
                            .padding(.vertical, 18)
                        }
                        .buttonStyle(.plain)

                        if clinic.id != store.clinics.last?.id {
                            Divider()
                                .background(Color(hex: 0xD3D3D3))
                                .padding(.horizontal, 20)
                        }
                    }

                    Button {
                        store.activeOverlay = .clinicAddressInput(booking)
                    } label: {
                        HStack(spacing: 10) {
                            Image("jiahao")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 21, height: 21)
                            Text("新增接种门诊地址")
                                .font(.system(size: 16))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .background(Color(hex: 0xFD898A))
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)
                    .padding(.top, booking.isEditingExistingAppointment ? 46 : 0)
                    .padding(.bottom, booking.isEditingExistingAppointment ? 16 : 12)

                    if booking.isEditingExistingAppointment {
                        HStack(spacing: 20) {
                            Button("取消") {
                                store.activeOverlay = .editPlan(appointment(from: booking), booking.editPlanDisplayMode)
                            }
                            .modalButton(background: GCColor.cancelButton)

                            Button("确定") {
                                var next = booking
                                next.clinic = selectedClinic
                                store.updateAppointmentClinicAndReturnToEdit(next)
                            }
                            .modalButton(background: GCColor.headerTop, foreground: .white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 24)
                    }
                }
                .frame(
                    minHeight: booking.isEditingExistingAppointment ? 397 : 320,
                    alignment: .top
                )
            }
        }
    }

    private func appointment(from booking: PendingBooking) -> Appointment {
        Appointment(
            childID: store.activeChildID,
            vaccineName: booking.vaccineName,
            doseNumber: booking.doseNumber,
            date: booking.date,
            clinic: booking.clinic,
            remark: booking.remark
        )
    }
}

private struct ClinicAddressInputOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let booking: PendingBooking

    @State private var addressText = ""
    @FocusState private var addressFocused: Bool

    var body: some View {
        ModalCard {
            VStack(spacing: 0) {
                Text("新增接种门诊地址")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.top, 24)
                    .padding(.bottom, 20)

                TextEditor(text: $addressText)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .focused($addressFocused)
                    .padding(14)
                    .frame(height: 205)
                    .background(Color(hex: 0xF7F2EF))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topLeading) {
                        if addressText.isEmpty {
                            Text("请输入接种门诊地址")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: 0x9A9A9A))
                                .padding(.leading, 20)
                                .padding(.top, 22)
                                .allowsHitTesting(false)
                        }
                    }
                    .padding(.horizontal, 20)

                HStack(spacing: 20) {
                    Button("取消") {
                        addressFocused = false
                        store.activeOverlay = .clinicSelect(booking)
                    }
                    .modalButton(background: GCColor.cancelButton)

                    Button("完成") {
                        addAddress()
                    }
                    .modalButton(background: GCColor.headerTop, foreground: .white)
                    .opacity(trimmedAddress.isEmpty ? 0.55 : 1)
                    .disabled(trimmedAddress.isEmpty)
                }
                .padding(.horizontal, 20)
                .padding(.top, 22)
                .padding(.bottom, 20)
            }
            .frame(minHeight: 365)
        }
        .onAppear {
            addressFocused = true
        }
    }

    private var trimmedAddress: String {
        addressText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func addAddress() {
        let address = trimmedAddress
        guard !address.isEmpty else { return }
        store.addClinic(name: address, address: address, hours: "敬请期待")
        var next = booking
        next.clinic = address
        addressFocused = false
        store.activeOverlay = .clinicSelect(next)
    }
}

private struct ConfirmBookingOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let booking: PendingBooking
    @State private var remarkText: String
    @FocusState private var remarkFocused: Bool

    init(booking: PendingBooking) {
        self.booking = booking
        _remarkText = State(initialValue: booking.remark == GrowthCareStore.defaultRemark ? "" : booking.remark)
    }

    var body: some View {
        VStack(spacing: 16) {
            ProgressCard(title: "预定内容确认", step: 3) { index in
                switch index {
                case 1:
                    store.activeOverlay = .bookingDate(updatedBooking())
                case 2:
                    store.activeOverlay = .clinic(updatedBooking())
                default:
                    break
                }
            }

            ModalCard {
                VStack(spacing: 0) {
                    profileRow
                    divider
                    valueRow(label: "接种疫苗", value: booking.vaccineName)
                    divider
                    valueRow(label: "接种时间", value: store.dottedDateText(booking.date))
                    divider
                    valueRow(label: "接种门诊", value: booking.clinic)
                    divider
                    remarkRow

                    HStack(spacing: 20) {
                        Button("取消") { store.activeOverlay = nil }
                            .modalButton(background: GCColor.cancelButton)
                        Button("确定") { store.confirmBooking(updatedBooking()) }
                            .modalButton(background: GCColor.headerTop, foreground: .white)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    if value.translation.width < -60 {
                        store.activeOverlay = .clinic(updatedBooking())
                    }
                }
        )
    }

    private var profileRow: some View {
        HStack(alignment: .top, spacing: 16) {
            ChildAvatarImage(child: store.activeChild)
                .scaledToFill()
                .frame(width: 46, height: 46)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text(store.activeChild.name)
                    .font(.system(size: 16, weight: .medium))
                Text(store.activeChild.birthText)
                    .font(.system(size: 14))
            }
            .foregroundColor(.black)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
    }

    private func valueRow(label: String, value: String) -> some View {
        HStack(spacing: 16) {
            Text(label)
                .font(.system(size: 16))
                .frame(width: 82, alignment: .leading)
            Text(value)
                .font(.system(size: 14))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundColor(.black)
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }

    private var remarkRow: some View {
        HStack(spacing: 0) {
            Text("添加备注")
                .font(.system(size: 16))
                .frame(width: 82, alignment: .leading)

            TextField(
                "",
                text: $remarkText,
                prompt: Text("请输入备注").foregroundColor(Color(hex: 0x9A9A9A))
            )
            .font(.system(size: 14))
            .foregroundColor(.black)
            .lineLimit(1)
            .focused($remarkFocused)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.done)
        }
        .foregroundColor(.black)
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .onTapGesture {
            remarkFocused = true
        }
    }

    private func updatedBooking() -> PendingBooking {
        var next = booking
        next.remark = remarkText.trimmingCharacters(in: .whitespacesAndNewlines)
        return next
    }

    private var divider: some View {
        Divider()
            .background(Color(hex: 0xD3D3D3))
            .padding(.horizontal, 20)
    }
}

private struct EditPlanOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let appointment: Appointment
    let displayMode: EditPlanDisplayMode
    @State private var currentRemark: String
    @FocusState private var remarkFocused: Bool

    init(appointment: Appointment, displayMode: EditPlanDisplayMode) {
        self.appointment = appointment
        self.displayMode = displayMode
        _currentRemark = State(initialValue: appointment.remark)
    }

    var body: some View {
        ZStack {
            ModalCard {
                VStack(spacing: 0) {
                    HStack(spacing: 17) {
                        ChildAvatarImage(child: store.activeChild)
                            .scaledToFill()
                            .frame(width: 46, height: 46)
                            .clipShape(Circle())

                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.activeChild.name)
                                .font(.system(size: 16, weight: .semibold))
                            Text(store.activeChild.birthText)
                                .font(.system(size: 14))
                        }
                        Spacer()
                    }
                    .foregroundColor(.black)
                    .padding(.leading, 30)
                    .padding(.trailing, 10)
                    .padding(.top, 32)
                    .padding(.bottom, 14)

                    divider
                    vaccineGroupRow
                    divider
                    editRow("接种时间", store.dottedDateText(appointment.date), arrow: true) {
                        persistRemark()
                        store.activeOverlay = .bookingDate(
                            PendingBooking(
                                vaccineName: appointment.vaccineName,
                                doseNumber: appointment.doseNumber,
                                date: appointment.date,
                                clinic: appointment.clinic,
                                remark: normalizedRemark,
                                isEditingExistingAppointment: true,
                                editPlanDisplayMode: displayMode
                            )
                        )
                    }
                    divider
                    editRow("接种门诊", appointment.clinic, arrow: true) {
                        persistRemark()
                        store.activeOverlay = .clinicSelect(
                            PendingBooking(
                                vaccineName: appointment.vaccineName,
                                doseNumber: appointment.doseNumber,
                                date: appointment.date,
                                clinic: appointment.clinic,
                                remark: normalizedRemark,
                                isEditingExistingAppointment: true,
                                editPlanDisplayMode: displayMode
                            )
                        )
                    }
                    divider
                    remarkInlineRow

                    HStack(spacing: 20) {
                        Button("删除") {
                            store.deleteAppointment(appointment)
                        }
                        .modalButton(background: GCColor.cancelButton)

                        Button("完成") {
                            persistRemark()
                            remarkFocused = false
                            store.activeOverlay = nil
                        }
                        .modalButton(background: GCColor.headerTop, foreground: .white)
                    }
                    .padding(.horizontal, 22)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
                .frame(minHeight: 397)
            }
        }
    }

    private var divider: some View {
        Divider()
            .background(Color(hex: 0xD3D3D3))
            .padding(.horizontal, 20)
    }

    private func editRow(_ label: String, _ value: String, arrow: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 0) {
                Text(label)
                    .font(.system(size: 16))
                    .frame(width: 82, alignment: .leading)
                Text(value.isEmpty ? "请输入备注" : value)
                    .font(.system(size: 14))
                    .foregroundColor(value.isEmpty ? Color(hex: 0x9A9A9A) : .black)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if arrow {
                    Image("jiantouerhao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 9, height: 14)
                        .padding(.trailing, 10)
                }
            }
            .foregroundColor(.black)
            .padding(.leading, 30)
            .padding(.trailing, 10)
            .frame(height: 48)
        }
        .buttonStyle(.plain)
        .disabled(!arrow)
    }

    private var vaccineGroupRow: some View {
        let appointments = displayMode == .dateGroup
            ? store.appointmentGroup(containing: appointment).appointments
            : [appointment]

        return HStack(spacing: 0) {
            Text("接种疫苗")
                .font(.system(size: 16))
                .frame(width: 82, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(appointments) { item in
                        Text("\(item.vaccineName) 第\(item.doseNumber)剂")
                            .font(.system(size: 14))
                            .foregroundColor(Color(hex: 0x8A8A8A))
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                    }
                }
            }
            .scrollDisabled(appointments.count <= 2)
        }
        .foregroundColor(.black)
        .padding(.leading, 30)
        .padding(.trailing, 20)
        .frame(height: 48)
    }

    private var remarkInlineRow: some View {
        HStack(spacing: 0) {
            Text("添加备注")
                .font(.system(size: 16))
                .frame(width: 82, alignment: .leading)

            TextField(
                "",
                text: $currentRemark,
                prompt: Text("请输入备注").foregroundColor(Color(hex: 0x9A9A9A))
            )
            .font(.system(size: 14))
            .foregroundColor(.black)
            .lineLimit(1)
            .focused($remarkFocused)
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)
            .submitLabel(.done)
            .onSubmit {
                persistRemark()
            }
            .onChange(of: currentRemark) { _ in
                store.updateAppointmentRemark(appointment, remark: currentRemark)
            }
        }
        .foregroundColor(.black)
        .padding(.leading, 30)
        .padding(.trailing, 20)
        .frame(height: 48)
        .contentShape(Rectangle())
        .onTapGesture {
            remarkFocused = true
        }
    }

    private var normalizedRemark: String {
        currentRemark.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func persistRemark() {
        let remark = normalizedRemark
        if remark != currentRemark {
            currentRemark = remark
        }
        if remark != appointment.remark {
            store.updateAppointmentRemark(appointment, remark: remark)
        }
    }
}

private struct HideConfirmOverlay: View {
    @EnvironmentObject private var store: GrowthCareStore
    let vaccineName: String

    var body: some View {
        ModalCard {
            VStack(spacing: 0) {
                Text("确定将该剂次疫苗从列表中移除吗？")
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .padding(.top, 56)
                    .padding(.bottom, 20)

                Text("移除后，疫苗会在疫苗页面中隐藏不做显示，后续如需恢复，可前往添加疫苗页面中操作添加显示；")
                    .font(.system(size: 16))
                    .foregroundColor(GCColor.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(5)
                    .padding(.horizontal, 26)
                    .padding(.bottom, 48)

                HStack(spacing: 20) {
                    Button("取消") { store.activeOverlay = nil }
                        .modalButton(background: GCColor.cancelButton)
                    Button("确认") { store.hideVaccine(vaccineName) }
                        .modalButton(background: GCColor.headerTop, foreground: .white)
                }
                .padding(.horizontal, 26)
                .padding(.bottom, 28)
            }
            .frame(minHeight: 257)
        }
    }
}

private extension View {
    func modalButton(background: Color, foreground: Color = GCColor.textSecondary) -> some View {
        self
            .font(.system(size: 16))
            .foregroundColor(foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 40)
            .background(background)
            .clipShape(Capsule())
            .buttonStyle(.plain)
    }
}
