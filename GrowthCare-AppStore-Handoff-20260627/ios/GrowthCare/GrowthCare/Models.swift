import Foundation

struct ChildProfile: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var birthText: String
    var birthDate: Date
    var avatarAsset: String
    var avatarData: Data? = nil
    var gender: String = "女"
    var relationship: String = "母女"
    var colorName: String = "默认"
    var colorHex: UInt = 0xD89698
}

struct ChildData: Equatable, Codable {
    var addedVaccines: [String] = []
    var hiddenVaccines: Set<String> = []
    var bookedDoses: [String: [Int: Appointment]] = [:]
    var completedDoses: [String: Set<Int>] = [:]
    var missedDoses: [String: Set<Int>] = [:]
    var needsPastDoseReview: Bool = false
    var growthRecords: [GrowthRecord] = []
}

struct Clinic: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var address: String
    var hours: String
}

struct ParentProfile: Equatable, Codable {
    var name: String
    var phone: String
    var idNumber: String
    var address: String
    var avatarAsset: String
    var avatarData: Data? = nil
}

enum ReminderMode: String, CaseIterable, Identifiable, Equatable, Codable {
    case sameDay
    case oneDayBefore
    case twoDaysBefore
    case customDays

    var id: String { rawValue }

    var title: String {
        switch self {
        case .sameDay: return "当天提醒"
        case .oneDayBefore: return "提前1天"
        case .twoDaysBefore: return "提前2天"
        case .customDays: return "自定义"
        }
    }
}

struct ReminderSettings: Equatable, Codable {
    var isAlarmEnabled: Bool
    var mode: ReminderMode
    var customDays: Int
    var timeText: String
}

struct SharedMember: Identifiable, Equatable, Codable {
    let id: String
    var name: String
    var role: String
    var phone: String
}

struct OptionalVaccine: Identifiable, Equatable, Codable {
    let name: String
    var doseCount: Int
    var isAdded: Bool
    var isHidden: Bool

    var id: String { name }
}

struct GrowthRecord: Identifiable, Equatable, Codable {
    let id: String
    let date: Date
    var height: Double
    var weight: Double
}

struct Appointment: Identifiable, Equatable, Codable {
    let childID: String
    let vaccineName: String
    let doseNumber: Int
    var date: Date
    var clinic: String
    var remark: String

    var id: String {
        "\(childID)-\(vaccineName)-\(doseNumber)"
    }
}

struct NextAppointmentGroup: Equatable, Codable {
    let date: Date
    var appointments: [Appointment]
}

enum DoseStatus: Equatable, Codable {
    case future
    case booked
    case done
}

struct VaccineDose: Identifiable, Equatable, Codable {
    let number: Int
    var status: DoseStatus
    var dateText: String
    var appointment: Appointment?

    var id: Int { number }
}

struct VaccineCardData: Identifiable, Equatable, Codable {
    let name: String
    var doses: [VaccineDose]
    var dueNow: Bool
    var hasMissedDose: Bool
    var pinned: Bool

    var id: String { name }
    var isCompleted: Bool { doses.allSatisfy { $0.status == .done } }
}

struct PastDoseReviewItem: Identifiable, Equatable, Codable {
    let vaccineName: String
    let doseNumber: Int
    let recommendedDateText: String

    var id: String { "\(vaccineName)-\(doseNumber)" }
    var title: String { "\(vaccineName) 第\(doseNumber)剂" }
}

struct AppointmentReviewItem: Identifiable, Equatable, Codable {
    let childID: String
    let childName: String
    let vaccineName: String
    let doseNumber: Int
    let appointmentDate: Date
    let appointmentDateText: String
    let clinic: String

    var id: String { "\(childID)-\(vaccineName)-\(doseNumber)" }
    var title: String { "\(childName) · \(vaccineName) 第\(doseNumber)剂" }
}

struct PendingBooking: Equatable, Codable {
    var vaccineName: String
    var doseNumber: Int
    var date: Date
    var clinic: String
    var remark: String
    var isEditingExistingAppointment = false
    var editPlanDisplayMode: EditPlanDisplayMode = .dateGroup
}

enum EditPlanDisplayMode: Equatable, Codable {
    case dateGroup
    case singleDose
}

enum AppTab: String, CaseIterable, Identifiable {
    case appointment
    case schedule
    case growth
    case profile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .appointment: return "预约"
        case .schedule: return "接种时间表"
        case .growth: return "成长记录"
        case .profile: return "我的"
        }
    }

    var selectedAsset: String {
        switch self {
        case .appointment: return "yuyue"
        case .schedule: return "jiezhongshijianbiao"
        case .growth: return "chengzhangquxian"
        case .profile: return "wode"
        }
    }

    var unselectedAsset: String {
        switch self {
        case .appointment: return "yuyueweidianji"
        case .schedule: return "jiezhongshijianbiaoweidianji"
        case .growth: return "chengzhangquxianno"
        case .profile: return "wodeweidianji"
        }
    }
}

enum AppRoute: Hashable {
    case vaccineDetail(name: String, initialTab: VaccineDetailTab)
    case addVaccine
    case vaccineCalendar
    case clinicList
    case addClinic
    case growthRecords
    case addGrowthRecord
    case parentProfile
    case childProfile(childID: String?)
    case reminderDate
    case reminderTime
    case sharedMembers
    case addSharedMember

    var title: String {
        switch self {
        case .vaccineDetail: return "疫苗详情"
        case .addVaccine: return "添加预约疫苗"
        case .vaccineCalendar: return "疫苗日历"
        case .clinicList: return "接种单位"
        case .addClinic: return "添加诊所"
        case .growthRecords: return "成长记录"
        case .addGrowthRecord: return "添加成长记录"
        case .parentProfile: return "个人信息"
        case .childProfile: return "孩子信息"
        case .reminderDate: return "提醒日期"
        case .reminderTime: return "提醒时间"
        case .sharedMembers: return "共享成员"
        case .addSharedMember: return "添加共享成员"
        }
    }
}

enum VaccineDetailTab: String, CaseIterable, Identifiable, Hashable {
    case intro
    case precautions

    var id: String { rawValue }

    var title: String {
        switch self {
        case .intro: return "疫苗简介"
        case .precautions: return "注意事项"
        }
    }
}

struct VaccineInfo: Equatable {
    let title: String
    let intro: String
    let schedule: [VaccineScheduleInfoRow]
    let reasons: [String]
    let sideEffects: VaccineSideEffects
    let precautions: VaccinePrecautions
}

struct VaccineScheduleInfoRow: Identifiable, Equatable {
    let dose: String
    let time: String
    let note: String

    var id: String { "\(dose)-\(time)-\(note)" }
}

struct VaccineSideEffects: Equatable {
    let common: String
    let rare: String
}

struct VaccinePrecautions: Equatable {
    let health: VaccinePrecautionBlock
    let allergy: VaccinePrecautionBlock
    let delay: VaccineDelayPrecaution
}

struct VaccinePrecautionBlock: Equatable {
    let title: String
    let text: String
}

struct VaccineDelayPrecaution: Equatable {
    let title: String
    let intro: String
    let items: [String]
}

enum HomeOverlay: Identifiable, Equatable {
    case bookingDate(PendingBooking)
    case confirm(PendingBooking)
    case editPlan(Appointment, EditPlanDisplayMode)
    case pastDoseReview(String)
    case appointmentReview
    case hideConfirm(String)

    var id: String {
        switch self {
        case .bookingDate(let booking):
            return "booking-date-\(booking.vaccineName)-\(booking.doseNumber)"
        case .confirm(let booking):
            return "confirm-\(booking.vaccineName)-\(booking.doseNumber)"
        case .editPlan(let appointment, let displayMode):
            return "edit-\(appointment.id)-\(displayMode)"
        case .pastDoseReview(let childID):
            return "past-dose-review-\(childID)"
        case .appointmentReview:
            return "appointment-review"
        case .hideConfirm(let vaccine):
            return "hide-\(vaccine)"
        }
    }
}
