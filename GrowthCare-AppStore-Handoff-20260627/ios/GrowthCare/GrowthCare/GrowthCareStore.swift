import Foundation
import SwiftUI

@MainActor
final class GrowthCareStore: ObservableObject {
    static let defaultClinic = "红凌路预防接种站"
    static let defaultRemark = ""

    @Published var selectedTab: AppTab = .appointment
    @Published var activeChildID = "child-1"
    @Published var childData: [String: ChildData]
    @Published var navigationPath: [AppRoute] = []
    @Published var clinics: [Clinic]
    @Published var parentProfile: ParentProfile
    @Published var reminderSettings: ReminderSettings
    @Published var sharedMembers: [SharedMember]
    @Published var children: [ChildProfile]
    @Published var activeOverlay: HomeOverlay?
    @Published var toastMessage: String?

    private let persistence: GrowthCarePersistence

    private let pinnedVaccines: Set<String> = ["卡介苗", "乙肝疫苗"]
    private let homeOrder = [
        "卡介苗",
        "乙肝疫苗",
        "脊髓灰质炎疫苗",
        "百白破疫苗",
        "A群脑流疫苗",
        "麻腮风疫苗",
        "乙脑减毒疫苗",
        "乙脑灭活疫苗",
        "甲肝减毒疫苗",
        "甲肝灭活疫苗",
        "A+C群脑流疫苗"
    ]
    private let optionalVaccines = [
        "五联疫苗",
        "五价轮状疫苗",
        "13价肺炎疫苗",
        "手足口疫苗",
        "水痘疫苗",
        "流感疫苗"
    ]

    private let childColorPalette: [(name: String, hex: UInt)] = [
        ("桃粉", 0xF6B6B8),
        ("天蓝", 0x8FC8F8),
        ("薄荷", 0xBEDDAA),
        ("奶杏", 0xFBE7C6),
        ("丁香", 0xD8C8F2)
    ]

    private let doseAgeMonths: [String: [Int]] = [
        "卡介苗": [0],
        "乙肝疫苗": [0, 1, 6],
        "脊髓灰质炎疫苗": [2, 3, 4, 36],
        "百白破疫苗": [2, 4, 6, 18, 72],
        "A群脑流疫苗": [6, 9],
        "麻腮风疫苗": [8],
        "乙脑减毒疫苗": [8, 48],
        "乙脑灭活疫苗": [2, 4, 6, 12],
        "甲肝减毒疫苗": [18],
        "甲肝灭活疫苗": [18, 24],
        "A+C群脑流疫苗": [6, 9],
        "五联疫苗": [2, 3, 4, 18],
        "五价轮状疫苗": [2, 3, 4],
        "13价肺炎疫苗": [2, 4, 6, 12],
        "手足口疫苗": [6, 7],
        "水痘疫苗": [12, 72],
        "流感疫苗": [6]
    ]

    private let scheduleMonthVaccines: [Int: Set<String>] = [
        0: ["乙肝疫苗", "卡介苗"],
        1: ["乙肝疫苗"],
        2: ["脊髓灰质炎疫苗", "百白破疫苗", "五联疫苗", "五价轮状疫苗", "13价肺炎疫苗"],
        3: ["脊髓灰质炎疫苗", "五联疫苗", "五价轮状疫苗"],
        4: ["脊髓灰质炎疫苗", "百白破疫苗", "五联疫苗", "五价轮状疫苗", "13价肺炎疫苗"],
        6: ["乙肝疫苗", "百白破疫苗", "A群脑流疫苗", "A+C群脑流疫苗", "手足口疫苗", "13价肺炎疫苗"],
        7: ["手足口疫苗"],
        8: ["麻腮风疫苗", "乙脑减毒疫苗"],
        9: ["A群脑流疫苗", "A+C群脑流疫苗"],
        12: ["水痘疫苗", "13价肺炎疫苗"],
        18: ["麻腮风疫苗", "百白破疫苗", "甲肝灭活疫苗", "五联疫苗", "甲肝减毒疫苗"],
        24: ["乙脑减毒疫苗", "甲肝灭活疫苗"],
        36: ["A+C群脑流疫苗"],
        48: ["脊髓灰质炎疫苗", "水痘疫苗"],
        72: ["A+C群脑流疫苗", "百白破疫苗"]
    ]

    init(persistence: GrowthCarePersistence = FileGrowthCarePersistence()) {
        self.persistence = persistence

        let defaultBirthDate = Calendar.current.startOfDay(for: Date())
        let defaultChildren: [ChildProfile] = [
            ChildProfile(
                id: "child-1",
                name: "孩子1",
                birthText: Self.birthText(for: defaultBirthDate),
                birthDate: defaultBirthDate,
                avatarAsset: "unsplash_JfolIjRnveY",
                gender: "男",
                relationship: "母子",
                colorName: "桃粉",
                colorHex: 0xF6B6B8
            )
        ]

        let defaultChildData: [String: ChildData] = [
            "child-1": ChildData()
        ]

        let defaultClinics = [
            Clinic(
                id: "hongling-road",
                name: Self.defaultClinic,
                address: "西岗区高尔基路188-194号",
                hours: "8:00-11:00  13:00-17:00"
            ),
            Clinic(
                id: "taoyuan-community",
                name: "中山区桃源街道社区卫生服务中心",
                address: "中山区桃源街道",
                hours: "8:00-11:00  13:00-17:00"
            ),
            Clinic(
                id: "nanshan-street",
                name: "南山街预防接种门诊",
                address: "南山街",
                hours: "8:00-11:00  13:00-17:00"
            )
        ]
        let defaultParentProfile = ParentProfile(
            name: "妈妈小丽",
            phone: "123 5678 9000",
            idNumber: "123456 20260409 7890",
            address: "翻斗大街翻斗花园二号楼1001室",
            avatarAsset: "profile-avatar-mom"
        )
        let defaultReminderSettings = ReminderSettings(isAlarmEnabled: true, mode: .sameDay, customDays: 10, timeText: "上午10:00")
        let defaultSharedMembers = [
            SharedMember(id: "dad", name: "爸爸", role: "家人", phone: "13900000000"),
            SharedMember(id: "grandpa", name: "爷爷", role: "家人", phone: "13700000000")
        ]

        if let snapshot = persistence.loadSnapshot(), !snapshot.children.isEmpty {
            children = snapshot.children
            activeChildID = snapshot.children.contains { $0.id == snapshot.activeChildID }
                ? snapshot.activeChildID
                : snapshot.children[0].id

            var restoredChildData = snapshot.childData
            for child in snapshot.children where restoredChildData[child.id] == nil {
                restoredChildData[child.id] = ChildData()
            }
            childData = restoredChildData

            clinics = snapshot.clinics.isEmpty ? defaultClinics : snapshot.clinics
            parentProfile = snapshot.parentProfile
            reminderSettings = snapshot.reminderSettings
            sharedMembers = snapshot.sharedMembers
            syncReminderNotifications()
        } else {
            children = defaultChildren
            childData = defaultChildData
            clinics = defaultClinics
            parentProfile = defaultParentProfile
            reminderSettings = defaultReminderSettings
            sharedMembers = defaultSharedMembers
            persistSnapshot()
        }
    }

    var activeChild: ChildProfile {
        children.first { $0.id == activeChildID } ?? children[0]
    }

    var inactiveChildren: [ChildProfile] {
        children
            .sorted { $0.birthDate < $1.birthDate }
            .filter { $0.id != activeChildID }
    }

    var currentChildData: ChildData {
        childData[activeChildID, default: ChildData()]
    }

    func switchChild(to childID: String) {
        guard children.contains(where: { $0.id == childID }) else { return }
        activeChildID = childID
        persistSnapshot()
        showHomeReviewIfNeeded()
    }

    func selectTab(_ tab: AppTab) {
        selectedTab = tab
        navigationPath = []
        if tab == .appointment {
            showHomeReviewIfNeeded()
        }
    }

    func isDoseDone(vaccineName: String, doseNumber: Int, now: Date = Date()) -> Bool {
        isDone(vaccineName: vaccineName, doseNumber: doseNumber, now: now)
    }

    func activeChildAgeParts(now: Date = Date()) -> (months: Int, days: Int) {
        ageParts(now: now, birth: activeChild.birthDate)
    }

    func activeGrowthRecords() -> [GrowthRecord] {
        currentChildData.growthRecords.sorted {
            if $0.date == $1.date { return $0.id < $1.id }
            return $0.date < $1.date
        }
    }

    func visibleActiveVaccines(now: Date = Date()) -> [VaccineCardData] {
        allVaccines(now: now)
            .filter { !$0.isCompleted }
            .filter { !currentChildData.hiddenVaccines.contains($0.name) || $0.pinned }
    }

    func visibleCompletedVaccines(now: Date = Date()) -> [VaccineCardData] {
        allVaccines(now: now)
            .filter { $0.isCompleted }
    }

    func addPageVaccines() -> [String] {
        let hidden = currentChildData.hiddenVaccines.filter { !pinnedVaccines.contains($0) }
        return Array(Set(optionalVaccines).union(hidden))
            .sorted { displayOrder($0) == displayOrder($1) ? $0.localizedCompare($1) == .orderedAscending : displayOrder($0) < displayOrder($1) }
    }

    func optionalVaccineSummaries() -> [OptionalVaccine] {
        addPageVaccines().map { vaccine in
            OptionalVaccine(
                name: vaccine,
                doseCount: doseAgeMonths[vaccine]?.count ?? 1,
                isAdded: isVaccineVisible(vaccine),
                isHidden: currentChildData.hiddenVaccines.contains(vaccine)
            )
        }
    }

    func isVaccineVisible(_ vaccineName: String) -> Bool {
        if pinnedVaccines.contains(vaccineName) { return true }
        if currentChildData.hiddenVaccines.contains(vaccineName) { return false }
        return homeOrder.contains(vaccineName) || currentChildData.addedVaccines.contains(vaccineName)
    }

    func openVaccineDetail(_ vaccineName: String, initialTab: VaccineDetailTab = .intro) {
        activeOverlay = nil
        navigationPath.append(.vaccineDetail(name: vaccineName, initialTab: initialTab))
    }

    func openAddVaccine() {
        activeOverlay = nil
        navigationPath.append(.addVaccine)
    }

    func openCalendar() {
        activeOverlay = nil
        navigationPath.append(.vaccineCalendar)
    }

    func openClinicList() {
        activeOverlay = nil
        navigationPath.append(.clinicList)
    }

    func openAddClinic() {
        activeOverlay = nil
        navigationPath.append(.addClinic)
    }

    func openGrowthRecords() {
        activeOverlay = nil
        navigationPath.append(.growthRecords)
    }

    func openAddGrowthRecord() {
        activeOverlay = nil
        navigationPath.append(.addGrowthRecord)
    }

    func openParentProfile() {
        activeOverlay = nil
        navigationPath.append(.parentProfile)
    }

    func openChildProfile(childID: String? = nil) {
        activeOverlay = nil
        navigationPath.append(.childProfile(childID: childID))
    }

    func openReminderDate() {
        activeOverlay = nil
        navigationPath.append(.reminderDate)
    }

    func openReminderTime() {
        activeOverlay = nil
        navigationPath.append(.reminderTime)
    }

    func openSharedMembers() {
        activeOverlay = nil
        navigationPath.append(.sharedMembers)
    }

    func openAddSharedMember() {
        activeOverlay = nil
        navigationPath.append(.addSharedMember)
    }

    func popNavigation() {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
    }

    func nextAppointment(now: Date = Date()) -> Appointment? {
        nextAppointments(now: now).first
    }

    func nextAppointmentGroup(now: Date = Date()) -> NextAppointmentGroup? {
        let appointments = nextAppointments(now: now)
        guard let first = appointments.first else { return nil }

        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: first.date)
        return NextAppointmentGroup(
            date: first.date,
            appointments: appointments.filter { calendar.startOfDay(for: $0.date) == targetDay }
        )
    }

    func appointmentGroup(containing appointment: Appointment) -> NextAppointmentGroup {
        let calendar = Calendar.current
        let targetDay = calendar.startOfDay(for: appointment.date)
        let appointments = currentChildData.bookedDoses.flatMap { vaccineName, doses in
            doses.compactMap { doseNumber, booked -> Appointment? in
                guard currentChildData.completedDoses[vaccineName]?.contains(doseNumber) != true,
                      calendar.startOfDay(for: booked.date) == targetDay
                else {
                    return nil
                }

                return booked
            }
        }
        .sorted {
            if displayOrder($0.vaccineName) != displayOrder($1.vaccineName) {
                return displayOrder($0.vaccineName) < displayOrder($1.vaccineName)
            }
            return $0.doseNumber < $1.doseNumber
        }

        return NextAppointmentGroup(date: appointment.date, appointments: appointments.isEmpty ? [appointment] : appointments)
    }

    private func nextAppointments(now: Date = Date()) -> [Appointment] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        return currentChildData.bookedDoses.flatMap { vaccineName, doses in
            doses.compactMap { doseNumber, appointment -> Appointment? in
                guard currentChildData.completedDoses[vaccineName]?.contains(doseNumber) != true,
                      calendar.startOfDay(for: appointment.date) >= today
                else {
                    return nil
                }

                return appointment
            }
        }
        .sorted {
            if $0.date != $1.date {
                return $0.date < $1.date
            }
            if displayOrder($0.vaccineName) != displayOrder($1.vaccineName) {
                return displayOrder($0.vaccineName) < displayOrder($1.vaccineName)
            }
            return $0.doseNumber < $1.doseNumber
        }
    }

    func startBooking(vaccine: String, dose: Int) {
        activeOverlay = .bookingDate(
            PendingBooking(
                vaccineName: vaccine,
                doseNumber: dose,
                date: Calendar.current.startOfDay(for: Date()),
                clinic: Self.defaultClinic,
                remark: Self.defaultRemark
            )
        )
    }

    func confirmBooking(_ booking: PendingBooking) {
        var data = currentChildData
        let appointment = Appointment(
            childID: activeChildID,
            vaccineName: booking.vaccineName,
            doseNumber: booking.doseNumber,
            date: booking.date,
            clinic: booking.clinic,
            remark: booking.remark
        )
        var doseMap = data.bookedDoses[booking.vaccineName, default: [:]]
        doseMap[booking.doseNumber] = appointment
        data.bookedDoses[booking.vaccineName] = doseMap
        childData[activeChildID] = data
        activeOverlay = nil
        persistSnapshot()
    }

    func openEditPlan() {
        guard let appointment = nextAppointment() else {
            toastMessage = "暂无待修改的预约"
            return
        }
        activeOverlay = .editPlan(appointment, .dateGroup)
    }

    func openEditPlan(_ appointment: Appointment) {
        activeOverlay = .editPlan(appointment, .singleDose)
    }

    func deleteAppointment(_ appointment: Appointment) {
        var data = currentChildData
        data.bookedDoses[appointment.vaccineName]?[appointment.doseNumber] = nil
        if data.bookedDoses[appointment.vaccineName]?.isEmpty == true {
            data.bookedDoses[appointment.vaccineName] = nil
        }
        childData[activeChildID] = data
        activeOverlay = nil
        persistSnapshot()
    }

    func completeAppointment(_ appointment: Appointment) {
        var data = currentChildData
        data.bookedDoses[appointment.vaccineName]?[appointment.doseNumber] = nil
        if data.bookedDoses[appointment.vaccineName]?.isEmpty == true {
            data.bookedDoses[appointment.vaccineName] = nil
        }
        var completed = data.completedDoses[appointment.vaccineName, default: []]
        completed.insert(appointment.doseNumber)
        data.completedDoses[appointment.vaccineName] = completed
        data.missedDoses[appointment.vaccineName]?.remove(appointment.doseNumber)
        if data.missedDoses[appointment.vaccineName]?.isEmpty == true {
            data.missedDoses[appointment.vaccineName] = nil
        }
        childData[activeChildID] = data
        activeOverlay = nil
        persistSnapshot()
    }

    func updateAppointmentRemark(_ appointment: Appointment, remark: String) {
        var data = currentChildData
        var updated = appointment
        updated.remark = remark

        var doseMap = data.bookedDoses[appointment.vaccineName, default: [:]]
        doseMap[appointment.doseNumber] = updated
        data.bookedDoses[appointment.vaccineName] = doseMap
        childData[activeChildID] = data
        persistSnapshot()
    }

    func updateAppointmentDateAndReturnToEdit(_ booking: PendingBooking) {
        updateAppointmentAndReturnToEdit(booking)
    }

    func updateAppointmentClinicAndReturnToEdit(_ booking: PendingBooking) {
        updateAppointmentAndReturnToEdit(booking)
    }

    private func updateAppointmentAndReturnToEdit(_ booking: PendingBooking) {
        var data = currentChildData
        let updated = Appointment(
            childID: activeChildID,
            vaccineName: booking.vaccineName,
            doseNumber: booking.doseNumber,
            date: booking.date,
            clinic: booking.clinic,
            remark: booking.remark
        )

        var doseMap = data.bookedDoses[booking.vaccineName, default: [:]]
        doseMap[booking.doseNumber] = updated
        data.bookedDoses[booking.vaccineName] = doseMap
        childData[activeChildID] = data
        activeOverlay = .editPlan(updated, booking.editPlanDisplayMode)
        persistSnapshot()
    }

    func hideVaccine(_ vaccine: String) {
        guard !pinnedVaccines.contains(vaccine) else {
            toastMessage = "\(vaccine) 为固定展示疫苗，不能隐藏"
            activeOverlay = nil
            return
        }
        var data = currentChildData
        data.hiddenVaccines.insert(vaccine)
        childData[activeChildID] = data
        activeOverlay = nil
        persistSnapshot()
    }

    func addOrRestoreVaccine(_ vaccine: String) {
        var data = currentChildData
        data.hiddenVaccines.remove(vaccine)

        if !homeOrder.contains(vaccine), !data.addedVaccines.contains(vaccine) {
            data.addedVaccines.append(vaccine)
            data.addedVaccines.sort { displayOrder($0) == displayOrder($1) ? $0.localizedCompare($1) == .orderedAscending : displayOrder($0) < displayOrder($1) }
        }

        childData[activeChildID] = data
        toastMessage = "已添加\(vaccine)"
        persistSnapshot()
        popNavigation()
    }

    func showPlaceholder(_ message: String) {
        toastMessage = message
    }

    func addGrowthRecord(date: Date, height: Double, weight: Double, popAfterSave: Bool = true) {
        var data = currentChildData
        let normalizedHeight = min(max(height, 50.0), 100.0)
        let normalizedWeight = min(max(weight, 1.0), 100.0)
        let normalizedDate = min(date, Date())
        let timestamp = Int(Date().timeIntervalSince1970 * 1000)
        data.growthRecords.append(
            GrowthRecord(
                id: "gr-\(activeChildID)-\(timestamp)",
                date: Calendar.current.startOfDay(for: normalizedDate),
                height: (normalizedHeight * 10).rounded() / 10,
                weight: (normalizedWeight * 10).rounded() / 10
            )
        )
        data.growthRecords.sort {
            if $0.date == $1.date { return $0.id < $1.id }
            return $0.date < $1.date
        }
        childData[activeChildID] = data
        toastMessage = "已保存成长记录"
        persistSnapshot()
        if popAfterSave {
            popNavigation()
        }
    }

    func removeGrowthRecord(id: String) {
        var data = currentChildData
        let originalCount = data.growthRecords.count
        data.growthRecords.removeAll { $0.id == id }
        guard data.growthRecords.count != originalCount else { return }
        childData[activeChildID] = data
        toastMessage = "已删除成长记录"
        persistSnapshot()
    }

    func growthAgeLabel(for date: Date, child: ChildProfile? = nil) -> String {
        let targetChild = child ?? activeChild
        let calendar = Calendar.current
        if calendar.isDate(date, inSameDayAs: targetChild.birthDate) {
            return "出生24小时"
        }
        return formatAgeZh(now: date, birth: targetChild.birthDate)
    }

    func updateReminder(mode: ReminderMode? = nil, customDays: Int? = nil, timeText: String? = nil, isAlarmEnabled: Bool? = nil) {
        if let mode {
            reminderSettings.mode = mode
        }
        if let customDays {
            reminderSettings.customDays = customDays
        }
        if let timeText {
            reminderSettings.timeText = timeText
        }
        if let isAlarmEnabled {
            reminderSettings.isAlarmEnabled = isAlarmEnabled
        }
        persistSnapshot()
    }

    func updateParentProfile(name: String, phone: String, idNumber: String, address: String, avatarData: Data? = nil) {
        parentProfile.name = name
        parentProfile.phone = phone
        parentProfile.idNumber = idNumber
        parentProfile.address = address
        parentProfile.avatarData = avatarData
        toastMessage = "已保存家长信息"
        persistSnapshot()
        popNavigation()
    }

    func saveChildProfile(
        childID: String?,
        name: String,
        birthDate: Date,
        gender: String,
        relationship: String,
        colorName: String,
        colorHex: UInt,
        avatarData: Data? = nil
    ) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = trimmedName.isEmpty ? "未命名" : trimmedName
        let birthText = Self.birthText(for: birthDate)

        if let childID, let index = children.firstIndex(where: { $0.id == childID }) {
            var nextChildren = children
            var child = nextChildren[index]
            let previousBirthDate = Calendar.current.startOfDay(for: child.birthDate)
            let nextBirthDate = Calendar.current.startOfDay(for: birthDate)
            child.name = finalName
            child.birthDate = nextBirthDate
            child.birthText = birthText
            child.gender = gender
            child.relationship = relationship
            child.colorName = colorName
            child.colorHex = colorHex
            child.avatarData = avatarData
            nextChildren[index] = child
            children = nextChildren
            if previousBirthDate != nextBirthDate {
                var data = childData[childID, default: ChildData()]
                data.needsPastDoseReview = true
                childData[childID] = data
            }
        } else {
            let newID = "child-\(Int(Date().timeIntervalSince1970 * 1000))"
            let assignedColor = randomChildColor()
            children.append(
                ChildProfile(
                    id: newID,
                    name: finalName,
                    birthText: birthText,
                    birthDate: Calendar.current.startOfDay(for: birthDate),
                    avatarAsset: "unsplash_JfolIjRnveY",
                    avatarData: avatarData,
                    gender: gender,
                    relationship: relationship,
                    colorName: assignedColor.name,
                    colorHex: assignedColor.hex
                )
            )
            childData[newID] = ChildData(needsPastDoseReview: true)
            activeChildID = newID
        }

        toastMessage = "已保存孩子信息"
        persistSnapshot()
        popNavigation()
    }

    private func randomChildColor() -> (name: String, hex: UInt) {
        let used = Set(children.map(\.colorHex))
        let available = childColorPalette.filter { !used.contains($0.hex) }
        return (available.randomElement() ?? childColorPalette.randomElement()) ?? ("桃粉", 0xF6B6B8)
    }

    func addSharedMember(name: String, role: String, phone: String) {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            toastMessage = "请输入成员姓名"
            return
        }
        sharedMembers.append(
            SharedMember(
                id: "member-\(Int(Date().timeIntervalSince1970 * 1000))",
                name: trimmedName,
                role: role.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "家人" : role,
                phone: phone
            )
        )
        toastMessage = "已添加共享成员"
        persistSnapshot()
        popNavigation()
    }

    func removeSharedMember(id: String) {
        sharedMembers.removeAll { $0.id == id }
        persistSnapshot()
    }

    func addClinic(name: String, address: String, hours: String) {
        clinics.append(
            Clinic(
                id: "clinic-\(clinics.count + 1)",
                name: name,
                address: address,
                hours: hours
            )
        )
        persistSnapshot()
    }

    private func persistSnapshot() {
        persistence.saveSnapshot(
            GrowthCareSnapshot(
                activeChildID: activeChildID,
                children: children,
                childData: childData,
                clinics: clinics,
                parentProfile: parentProfile,
                reminderSettings: reminderSettings,
                sharedMembers: sharedMembers
            )
        )
        syncReminderNotifications()
    }

    private func syncReminderNotifications() {
        GrowthCareNotificationScheduler.sync(
            children: children,
            childData: childData,
            settings: reminderSettings
        )
    }

    func showHomeReviewIfNeeded(now: Date = Date()) {
        showPastDoseReviewIfNeeded(now: now)
        showDueAppointmentReviewIfNeeded(now: now)
    }

    func showPastDoseReviewIfNeeded(now: Date = Date()) {
        guard selectedTab == .appointment, activeOverlay == nil else { return }
        var data = currentChildData
        guard data.needsPastDoseReview else { return }

        let items = pastDoseReviewItems(childID: activeChildID, now: now)
        if items.isEmpty {
            data.needsPastDoseReview = false
            childData[activeChildID] = data
            persistSnapshot()
        } else {
            activeOverlay = .pastDoseReview(activeChildID)
        }
    }

    func pastDoseReviewItems(childID: String, now: Date = Date()) -> [PastDoseReviewItem] {
        guard let child = children.first(where: { $0.id == childID }) else { return [] }
        let data = childData[childID, default: ChildData()]
        let today = Calendar.current.startOfDay(for: now)

        return baseVaccines(for: data)
            .flatMap { vaccine in
                vaccine.doses.compactMap { doseNumber -> PastDoseReviewItem? in
                    guard data.completedDoses[vaccine.name]?.contains(doseNumber) != true,
                          data.bookedDoses[vaccine.name]?[doseNumber] == nil,
                          let recommended = recommendedDate(vaccineName: vaccine.name, doseNumber: doseNumber, child: child),
                          Calendar.current.startOfDay(for: recommended) < today
                    else {
                        return nil
                    }

                    return PastDoseReviewItem(
                        vaccineName: vaccine.name,
                        doseNumber: doseNumber,
                        recommendedDateText: shortDateText(recommended)
                    )
                }
            }
    }

    func confirmPastDoseReview(childID: String, completedItemIDs: Set<String>) {
        let items = pastDoseReviewItems(childID: childID)
        var data = childData[childID, default: ChildData()]

        for item in items {
            if completedItemIDs.contains(item.id) {
                var completed = data.completedDoses[item.vaccineName, default: []]
                completed.insert(item.doseNumber)
                data.completedDoses[item.vaccineName] = completed
                data.missedDoses[item.vaccineName]?.remove(item.doseNumber)
                if data.missedDoses[item.vaccineName]?.isEmpty == true {
                    data.missedDoses[item.vaccineName] = nil
                }
            } else {
                var missed = data.missedDoses[item.vaccineName, default: []]
                missed.insert(item.doseNumber)
                data.missedDoses[item.vaccineName] = missed
            }
        }

        data.needsPastDoseReview = false
        childData[childID] = data
        activeOverlay = nil
        persistSnapshot()
        showDueAppointmentReviewIfNeeded()
    }

    func showDueAppointmentReviewIfNeeded(now: Date = Date()) {
        guard selectedTab == .appointment, activeOverlay == nil else { return }
        guard !dueAppointmentReviewItems(now: now).isEmpty else { return }
        activeOverlay = .appointmentReview
    }

    func dueAppointmentReviewItems(now: Date = Date()) -> [AppointmentReviewItem] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        return children.flatMap { child in
            let data = childData[child.id, default: ChildData()]
            return data.bookedDoses.flatMap { vaccineName, doses in
                doses.compactMap { doseNumber, appointment -> AppointmentReviewItem? in
                    guard data.completedDoses[vaccineName]?.contains(doseNumber) != true,
                          calendar.startOfDay(for: appointment.date) < today
                    else {
                        return nil
                    }

                    return AppointmentReviewItem(
                        childID: child.id,
                        childName: child.name,
                        vaccineName: vaccineName,
                        doseNumber: doseNumber,
                        appointmentDate: appointment.date,
                        appointmentDateText: shortDateText(appointment.date),
                        clinic: appointment.clinic
                    )
                }
            }
        }
        .sorted {
            if $0.appointmentDate != $1.appointmentDate {
                return $0.appointmentDate < $1.appointmentDate
            }
            if $0.childName != $1.childName {
                return $0.childName.localizedCompare($1.childName) == .orderedAscending
            }
            if $0.vaccineName != $1.vaccineName {
                return $0.vaccineName.localizedCompare($1.vaccineName) == .orderedAscending
            }
            return $0.doseNumber < $1.doseNumber
        }
    }

    func confirmDueAppointmentReview(completedItemIDs: Set<String>) {
        let items = dueAppointmentReviewItems()

        for item in items {
            var data = childData[item.childID, default: ChildData()]

            if completedItemIDs.contains(item.id) {
                var completed = data.completedDoses[item.vaccineName, default: []]
                completed.insert(item.doseNumber)
                data.completedDoses[item.vaccineName] = completed
                data.missedDoses[item.vaccineName]?.remove(item.doseNumber)
                if data.missedDoses[item.vaccineName]?.isEmpty == true {
                    data.missedDoses[item.vaccineName] = nil
                }
            } else {
                var missed = data.missedDoses[item.vaccineName, default: []]
                missed.insert(item.doseNumber)
                data.missedDoses[item.vaccineName] = missed
                data.bookedDoses[item.vaccineName]?[item.doseNumber] = nil
                if data.bookedDoses[item.vaccineName]?.isEmpty == true {
                    data.bookedDoses[item.vaccineName] = nil
                }
            }

            childData[item.childID] = data
        }

        activeOverlay = nil
        persistSnapshot()
    }

    private func allVaccines(now: Date) -> [VaccineCardData] {
        baseVaccines(for: currentChildData)
            .sorted {
                displayOrder($0.name) == displayOrder($1.name)
                    ? $0.name.localizedCompare($1.name) == .orderedAscending
                    : displayOrder($0.name) < displayOrder($1.name)
            }
            .map { raw in
                VaccineCardData(
                    name: raw.name,
                    doses: raw.doses.map { doseNumber in
                        makeDose(vaccineName: raw.name, doseNumber: doseNumber, now: now)
                    },
                    dueNow: currentScheduleVaccines(now: now).contains(raw.name),
                    hasMissedDose: currentChildData.missedDoses[raw.name]?.isEmpty == false
                        || hasOverdueUnconfirmedDose(vaccineName: raw.name, doses: raw.doses, now: now),
                    pinned: pinnedVaccines.contains(raw.name)
                )
            }
    }

    private func baseVaccines(for data: ChildData) -> [(name: String, doses: [Int])] {
        let defaultVaccines = [
            ("卡介苗", [1]),
            ("乙肝疫苗", [1, 2, 3]),
            ("脊髓灰质炎疫苗", [1, 2, 3, 4]),
            ("百白破疫苗", [1, 2, 3, 4, 5]),
            ("A群脑流疫苗", [1, 2]),
            ("麻腮风疫苗", [1]),
            ("乙脑减毒疫苗", [1, 2]),
            ("乙脑灭活疫苗", [1, 2, 3, 4]),
            ("甲肝减毒疫苗", [1]),
            ("甲肝灭活疫苗", [1, 2]),
            ("A+C群脑流疫苗", [1, 2])
        ]

        let added = data.addedVaccines.map { vaccine in
            (name: vaccine, doses: Array(1...(doseAgeMonths[vaccine]?.count ?? 1)))
        }

        return defaultVaccines + added
    }

    private func makeDose(vaccineName: String, doseNumber: Int, now: Date) -> VaccineDose {
        if isDone(vaccineName: vaccineName, doseNumber: doseNumber, now: now) {
            return VaccineDose(
                number: doseNumber,
                status: .done,
                dateText: doneDateText(vaccineName: vaccineName, doseNumber: doseNumber),
                appointment: nil
            )
        }

        if let appointment = currentChildData.bookedDoses[vaccineName]?[doseNumber] {
            return VaccineDose(
                number: doseNumber,
                status: .booked,
                dateText: shortDateText(appointment.date),
                appointment: appointment
            )
        }

        return VaccineDose(number: doseNumber, status: .future, dateText: "--/--/--", appointment: nil)
    }

    private func isDone(vaccineName: String, doseNumber: Int, now: Date) -> Bool {
        currentChildData.completedDoses[vaccineName]?.contains(doseNumber) == true
    }

    private func hasOverdueUnconfirmedDose(vaccineName: String, doses: [Int], now: Date) -> Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)

        return doses.contains { doseNumber in
            guard currentChildData.completedDoses[vaccineName]?.contains(doseNumber) != true,
                  let recommended = recommendedDate(vaccineName: vaccineName, doseNumber: doseNumber)
            else {
                return false
            }

            return calendar.startOfDay(for: recommended) < today
        }
    }

    private func doneDateText(vaccineName: String, doseNumber: Int) -> String {
        guard let date = recommendedDate(vaccineName: vaccineName, doseNumber: doseNumber) else {
            return "--/--/--"
        }
        return shortDateText(date)
    }

    private func recommendedDate(vaccineName: String, doseNumber: Int) -> Date? {
        guard let months = doseAgeMonths[vaccineName], months.indices.contains(doseNumber - 1) else {
            return nil
        }
        return Calendar.current.date(byAdding: .month, value: months[doseNumber - 1], to: activeChild.birthDate)
    }

    private func recommendedDate(vaccineName: String, doseNumber: Int, child: ChildProfile) -> Date? {
        guard let months = doseAgeMonths[vaccineName], months.indices.contains(doseNumber - 1) else {
            return nil
        }
        return Calendar.current.date(byAdding: .month, value: months[doseNumber - 1], to: child.birthDate)
    }

    private func currentScheduleVaccines(now: Date) -> Set<String> {
        let age = ageParts(now: now, birth: activeChild.birthDate)
        let targetMonth: Int
        if age.months == 0 && age.days == 0 {
            targetMonth = 0
        } else if age.days > 0 {
            targetMonth = age.months + 1
        } else {
            targetMonth = age.months
        }

        if let exact = scheduleMonthVaccines[targetMonth] {
            return exact
        }

        let previous = scheduleMonthVaccines.keys.filter { $0 <= targetMonth }.max()
        return previous.flatMap { scheduleMonthVaccines[$0] } ?? []
    }

    private func ageParts(now: Date, birth: Date) -> (months: Int, days: Int) {
        let calendar = Calendar.current
        let birthComponents = calendar.dateComponents([.year, .month, .day], from: birth)
        let nowComponents = calendar.dateComponents([.year, .month, .day], from: now)
        let yearDelta = (nowComponents.year ?? 0) - (birthComponents.year ?? 0)
        var months = yearDelta * 12 + ((nowComponents.month ?? 0) - (birthComponents.month ?? 0))
        if (nowComponents.day ?? 0) < (birthComponents.day ?? 0) {
            months -= 1
        }
        months = max(0, months)
        let anchor = calendar.date(byAdding: .month, value: months, to: birth) ?? birth
        let days = calendar.dateComponents([.day], from: anchor, to: now).day ?? 0
        return (months, max(0, days))
    }

    private func formatAgeZh(now: Date, birth: Date) -> String {
        let parts = ageParts(now: now, birth: birth)
        if parts.months >= 12 {
            let years = parts.months / 12
            let remainingMonths = parts.months % 12
            if remainingMonths == 0 {
                return "\(years)岁\(parts.days)天"
            }
            return "\(years)岁\(remainingMonths)个月\(parts.days)天"
        }
        return "\(parts.months)个月\(parts.days)天"
    }

    private func displayOrder(_ vaccineName: String) -> Int {
        homeOrder.firstIndex(of: vaccineName) ?? homeOrder.count
    }

    func shortDateText(_ date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year.map { $0 % 100 } ?? 0)/\(components.month ?? 0)/\(components.day ?? 0)"
    }

    func fullDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }

    static func birthText(for date: Date) -> String {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return "\(components.year ?? 0)年\(components.month ?? 0)月\(components.day ?? 0)号出生"
    }

    func dottedDateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar.current
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }

    func weekdayText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}
