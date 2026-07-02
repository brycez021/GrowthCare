import SwiftUI

struct VaccineCalendarView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var visibleMonth: Date = .gcDate(2026, 4, 1)
    @State private var selectedDay = 1
    @State private var didPickInitialMonth = false

    private let calendar = Calendar.current
    private let weekdays = ["周日", "周一", "周二", "周三", "周四", "周五", "周六"]

    var body: some View {
        GeometryReader { _ in
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [Color.white, Color.white, GCColor.headerBottom, GCColor.headerTop],
                    startPoint: .bottom,
                    endPoint: .top
                )
                .ignoresSafeArea()

                VStack(spacing: 0) {
                    topBar
                    monthHeader
                        .padding(.top, 10)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 20) {
                            calendarCard
                            appointmentsSection
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            guard !didPickInitialMonth else { return }
            didPickInitialMonth = true
            if let targetDate = initialAppointmentDate() {
                visibleMonth = monthStart(for: targetDate)
                selectedDay = dayNumber(targetDate)
            }
        }
    }

    private var topBar: some View {
        HStack {
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

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 14)
        .padding(.bottom, 4)
    }

    private var monthHeader: some View {
        HStack(spacing: 20) {
            Text(monthTitle(visibleMonth))
                .font(.system(size: 32, weight: .heavy))
                .foregroundColor(GCColor.textSecondary)
                .lineLimit(1)

            HStack(spacing: 12) {
                monthButton(asset: "qianyige", label: "上个月") {
                    moveMonth(-1)
                }
                monthButton(asset: "houyige", label: "下个月") {
                    moveMonth(1)
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 8)
    }

    private func monthButton(asset: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(asset)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 56)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private var calendarCard: some View {
        VStack(spacing: 12) {
            HStack {
                ForEach(weekdays, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x808080))
                        .frame(maxWidth: .infinity)
                }
            }

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 14) {
                ForEach(calendarDays()) { day in
                    CalendarDayCell(
                        item: day,
                        isSelected: day.isCurrentMonth && day.number == selectedDay,
                        markers: markers(for: day)
                    ) {
                        guard day.isCurrentMonth else { return }
                        selectedDay = day.number
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.60), Color(hex: 0xFFFDFD)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.white, lineWidth: 0.8)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private var appointmentsSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text(monthTitle(visibleMonth))
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .tracking(0.35)

                Spacer()
            }

            let appointments = monthAppointments()
            if appointments.isEmpty {
                Text("本月暂无预约")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x808080))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
            } else {
                ForEach(appointments) { appointment in
                    CalendarAppointmentCard(item: appointment)
                }
            }
        }
    }

    private func moveMonth(_ delta: Int) {
        visibleMonth = calendar.date(byAdding: .month, value: delta, to: visibleMonth) ?? visibleMonth
        selectedDay = initialSelectedDay(for: visibleMonth)
    }

    private func calendarDays() -> [CalendarDayItem] {
        let monthStart = monthStart(for: visibleMonth)
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        let daysInMonth = calendar.range(of: .day, in: .month, for: monthStart)?.count ?? 30
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: monthStart) ?? monthStart
        let previousCount = calendar.range(of: .day, in: .month, for: previousMonth)?.count ?? 30

        var days: [CalendarDayItem] = []
        if firstWeekday > 0 {
            for offset in 0..<firstWeekday {
                days.append(CalendarDayItem(id: "previous-\(offset)", number: previousCount - firstWeekday + offset + 1, isCurrentMonth: false))
            }
        }
        for day in 1...daysInMonth {
            days.append(CalendarDayItem(id: "current-\(day)", number: day, isCurrentMonth: true))
        }
        let trailing = days.count % 7 == 0 ? 0 : 7 - (days.count % 7)
        if trailing > 0 {
            for day in 1...trailing {
                days.append(CalendarDayItem(id: "next-\(day)", number: day, isCurrentMonth: false))
            }
        }
        return days
    }

    private func markers(for day: CalendarDayItem) -> [Color] {
        guard day.isCurrentMonth else { return [] }
        return monthAppointments()
            .filter { dayNumber($0.date) == day.number }
            .map { $0.markerColor() }
    }

    private func initialSelectedDay(for month: Date) -> Int {
        if let first = monthAppointments(for: month).first {
            return dayNumber(first.date)
        }
        let now = Date()
        if calendar.isDate(now, equalTo: month, toGranularity: .month) {
            return dayNumber(now)
        }
        return 1
    }

    private func allAppointments() -> [CalendarAppointmentItem] {
        store.children.flatMap { child in
            let data = store.childData[child.id, default: ChildData()]
            return data.bookedDoses.flatMap { vaccineName, doses in
                doses.compactMap { entry -> CalendarAppointmentItem? in
                    let appointment = entry.value
                    return CalendarAppointmentItem(child: child, appointment: appointment)
                }
            }
        }
        .sorted(by: sortAppointments)
    }

    private func initialAppointmentDate(now: Date = Date()) -> Date? {
        let today = calendar.startOfDay(for: now)
        let appointments = allAppointments()
        return appointments.first { calendar.startOfDay(for: $0.date) >= today }?.date
            ?? appointments.first?.date
    }

    private func monthAppointments() -> [CalendarAppointmentItem] {
        monthAppointments(for: visibleMonth)
    }

    private func monthAppointments(for month: Date) -> [CalendarAppointmentItem] {
        allAppointments()
            .filter { calendar.isDate($0.date, equalTo: month, toGranularity: .month) }
            .sorted(by: sortAppointments)
    }

    private func sortAppointments(_ lhs: CalendarAppointmentItem, _ rhs: CalendarAppointmentItem) -> Bool {
        if !calendar.isDate(lhs.date, inSameDayAs: rhs.date) {
            return lhs.date < rhs.date
        }
        let leftOrder = store.children.firstIndex { $0.id == lhs.child.id } ?? Int.max
        let rightOrder = store.children.firstIndex { $0.id == rhs.child.id } ?? Int.max
        if leftOrder != rightOrder {
            return leftOrder < rightOrder
        }
        if lhs.appointment.vaccineName != rhs.appointment.vaccineName {
            return lhs.appointment.vaccineName.localizedCompare(rhs.appointment.vaccineName) == .orderedAscending
        }
        return lhs.appointment.doseNumber < rhs.appointment.doseNumber
    }

    private func monthTitle(_ date: Date) -> String {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return String(format: "%04d.%02d", parts.year ?? 2026, parts.month ?? 1)
    }

    private func monthStart(for date: Date) -> Date {
        let parts = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: DateComponents(year: parts.year, month: parts.month, day: 1)) ?? date
    }

    private func dayNumber(_ date: Date) -> Int {
        calendar.component(.day, from: date)
    }
}

private struct CalendarDayItem: Identifiable {
    let id: String
    let number: Int
    let isCurrentMonth: Bool
}

private struct CalendarAppointmentItem: Identifiable {
    let child: ChildProfile
    let appointment: Appointment

    var id: String { appointment.id }
    var date: Date { appointment.date }
    var cardColor: Color { CalendarChildColor.card(for: child) }

    func markerColor(now: Date = Date()) -> Color {
        let isPast = Calendar.current.startOfDay(for: date) < Calendar.current.startOfDay(for: now)
        return CalendarChildColor.marker(for: child, isPast: isPast)
    }
}

private enum CalendarChildColor {
    static func marker(for child: ChildProfile, isPast: Bool) -> Color {
        let color = Color(hex: child.colorHex)
        return isPast ? color.opacity(0.35) : color
    }

    static func card(for child: ChildProfile) -> Color {
        switch child.colorHex {
        case 0xF6B6B8:
            return Color(hex: 0xFCEEEE)
        case 0x8FC8F8:
            return Color(hex: 0xE5F0FF)
        case 0xBEDDAA:
            return Color(hex: 0xEEF8E8)
        case 0xFBE7C6:
            return Color(hex: 0xFFF4DD)
        case 0xD8C8F2:
            return Color(hex: 0xF1ECFF)
        default:
            return Color(hex: child.colorHex).opacity(0.24)
        }
    }
}

private struct CalendarDayCell: View {
    let item: CalendarDayItem
    let isSelected: Bool
    let markers: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text("\(item.number)")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : (item.isCurrentMonth ? GCColor.textSecondary : Color(hex: 0x808080)))
                    .frame(width: 26, height: 26)
                    .background(isSelected ? GCColor.textSecondary : Color.clear)
                    .clipShape(Circle())

                VStack(spacing: 2) {
                    ForEach(Array(markers.enumerated()), id: \.offset) { _, marker in
                        Capsule()
                            .fill(marker)
                            .frame(width: 34, height: 7)
                    }
                    if markers.isEmpty {
                        Color.clear.frame(width: 34, height: 7)
                    }
                }
                .frame(width: 34, alignment: .top)
            }
            .frame(minHeight: 52)
        }
        .buttonStyle(.plain)
        .disabled(!item.isCurrentMonth)
    }
}

private struct CalendarAppointmentCard: View {
    let item: CalendarAppointmentItem

    var body: some View {
        HStack(spacing: 16) {
            ChildAvatarImage(child: item.child)
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.white, lineWidth: 1))

            VStack(alignment: .leading, spacing: 6) {
                Text(item.child.name)
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: 0x2B2B2B))

                Text(dateText(item.date))
                    .font(.system(size: 12))
                    .foregroundColor(Color(hex: 0x808080))

                HStack(spacing: 6) {
                    Image("zhentou")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                        .opacity(0.6)
                    Text(item.appointment.vaccineName)
                        .lineLimit(1)
                    Text("第\(item.appointment.doseNumber)剂")
                }
                .font(.system(size: 10))
                .foregroundColor(GCColor.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .frame(minHeight: 80)
        .background(item.cardColor)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }

    private func dateText(_ date: Date) -> String {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(parts.year ?? 2026).\(parts.month ?? 1).\(parts.day ?? 1)"
    }
}
