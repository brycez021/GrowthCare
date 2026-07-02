import SwiftUI
import UIKit
import UserNotifications

@main
struct GrowthCareApp: App {
    @UIApplicationDelegateAdaptor(GrowthCareAppDelegate.self) private var appDelegate
    @StateObject private var store = GrowthCareStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}

final class GrowthCareAppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .list, .sound])
    }
}

enum GrowthCareNotificationScheduler {
    private static let identifierPrefix = "growthcare-vaccine-reminder-"

    static func sync(
        children: [ChildProfile],
        childData: [String: ChildData],
        settings: ReminderSettings,
        now: Date = Date()
    ) {
        let center = UNUserNotificationCenter.current()
        removePendingGrowthCareNotifications(center: center)

        guard settings.isAlarmEnabled else { return }

        center.getNotificationSettings { notificationSettings in
            switch notificationSettings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                schedulePendingReminders(
                    center: center,
                    children: children,
                    childData: childData,
                    settings: settings,
                    now: now
                )
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    schedulePendingReminders(
                        center: center,
                        children: children,
                        childData: childData,
                        settings: settings,
                        now: now
                    )
                }
            case .denied:
                return
            @unknown default:
                return
            }
        }
    }

    private static func removePendingGrowthCareNotifications(center: UNUserNotificationCenter) {
        center.getPendingNotificationRequests { requests in
            let identifiers = requests
                .map(\.identifier)
                .filter { $0.hasPrefix(identifierPrefix) }
            guard !identifiers.isEmpty else { return }
            center.removePendingNotificationRequests(withIdentifiers: identifiers)
            center.removeDeliveredNotifications(withIdentifiers: identifiers)
        }
    }

    private static func schedulePendingReminders(
        center: UNUserNotificationCenter,
        children: [ChildProfile],
        childData: [String: ChildData],
        settings: ReminderSettings,
        now: Date
    ) {
        for child in children {
            let data = childData[child.id, default: ChildData()]
            for (vaccineName, doses) in data.bookedDoses {
                for (doseNumber, appointment) in doses {
                    guard data.completedDoses[vaccineName]?.contains(doseNumber) != true,
                          let reminderDate = reminderDate(for: appointment.date, settings: settings),
                          reminderDate > now
                    else {
                        continue
                    }

                    let content = UNMutableNotificationContent()
                    content.title = "疫苗接种提醒"
                    content.body = "\(child.name) \(appointment.vaccineName) 第\(appointment.doseNumber)剂，预约时间 \(dateText(appointment.date))，接种门诊 \(appointment.clinic)。"
                    content.sound = .default
                    content.userInfo = [
                        "childID": child.id,
                        "vaccineName": appointment.vaccineName,
                        "doseNumber": appointment.doseNumber,
                        "appointmentDate": appointment.date.timeIntervalSince1970
                    ]

                    let components = Calendar.current.dateComponents(
                        [.year, .month, .day, .hour, .minute],
                        from: reminderDate
                    )
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(
                        identifier: identifierPrefix + appointment.id,
                        content: content,
                        trigger: trigger
                    )
                    center.add(request)
                }
            }
        }
    }

    private static func reminderDate(for appointmentDate: Date, settings: ReminderSettings) -> Date? {
        let calendar = Calendar.current
        let offsetDays: Int
        switch settings.mode {
        case .sameDay:
            offsetDays = 0
        case .oneDayBefore:
            offsetDays = 1
        case .twoDaysBefore:
            offsetDays = 2
        case .customDays:
            offsetDays = max(0, settings.customDays)
        }

        guard let reminderDay = calendar.date(
            byAdding: .day,
            value: -offsetDays,
            to: calendar.startOfDay(for: appointmentDate)
        ) else {
            return nil
        }

        let time = reminderTimeComponents(from: settings.timeText)
        return calendar.date(
            bySettingHour: time.hour,
            minute: time.minute,
            second: 0,
            of: reminderDay
        )
    }

    private static func reminderTimeComponents(from text: String) -> (hour: Int, minute: Int) {
        let period = text.hasPrefix("下午") ? "下午" : "上午"
        let stripped = text
            .replacingOccurrences(of: "上午", with: "")
            .replacingOccurrences(of: "下午", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = stripped.split(separator: ":")
        let rawHour = parts.first.flatMap { Int($0) } ?? 10
        let minute = parts.dropFirst().first.flatMap { Int($0) } ?? 0
        let normalizedHour = min(max(rawHour, 1), 12)

        let hour: Int
        if period == "下午" {
            hour = normalizedHour == 12 ? 12 : normalizedHour + 12
        } else {
            hour = normalizedHour == 12 ? 0 : normalizedHour
        }

        return (hour, min(max(minute, 0), 59))
    }

    private static func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
}

struct RootView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        NavigationStack(path: $store.navigationPath) {
            currentTab
                .navigationDestination(for: AppRoute.self) { route in
                    switch route {
                    case .vaccineDetail(let name, let initialTab):
                        VaccineDetailView(vaccineName: name, initialTab: initialTab)
                    case .addVaccine:
                        AddVaccineView()
                    case .vaccineCalendar:
                        VaccineCalendarView()
                    case .clinicList:
                        ClinicListView()
                    case .addClinic:
                        AddClinicView()
                    case .growthRecords:
                        GrowthRecordsView()
                    case .addGrowthRecord:
                        AddGrowthRecordView()
                    case .parentProfile:
                        ParentProfileView()
                    case .childProfile(let childID):
                        ChildProfileView(childID: childID)
                    case .reminderDate:
                        ReminderDateView()
                    case .reminderTime:
                        ReminderTimeView()
                    case .sharedMembers:
                        SharedMembersView()
                    case .addSharedMember:
                        AddSharedMemberView()
                    }
                }
                .navigationBarHidden(true)
        }
    }

    @ViewBuilder
    private var currentTab: some View {
        switch store.selectedTab {
        case .appointment:
            HomeView()
        case .schedule:
            ScheduleView()
        case .growth:
            GrowthCurveView()
        case .profile:
            ProfileView()
        }
    }
}
