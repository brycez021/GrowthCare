import SwiftUI

struct RoutePlaceholderView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let route: AppRoute

    var body: some View {
        PlaceholderScaffold(title: route.title, subtitle: "Foundation 已接入原生路由，页面由对应功能代理继续转写。") {
            routeDetails
        }
        .navigationBarBackButtonHidden(true)
    }

    @ViewBuilder
    private var routeDetails: some View {
        switch route {
        case .vaccineCalendar:
            PlaceholderInfoRow(title: "接入状态", detail: "Home 日历按钮已连接到此路由")
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/疫苗日历.html")
        case .clinicList:
            PlaceholderInfoRow(title: "默认门诊", detail: store.clinics.first?.name ?? GrowthCareStore.defaultClinic)
            PlaceholderButton(title: "添加诊所") { store.openAddClinic() }
        case .addClinic:
            PlaceholderInfoRow(title: "接入状态", detail: "诊所新增状态边界已在 Store 中预留")
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/添加诊所.html")
        case .growthRecords:
            PlaceholderInfoRow(title: "当前记录", detail: "\(store.activeGrowthRecords().count) 条")
            PlaceholderButton(title: "添加成长记录") { store.openAddGrowthRecord() }
        case .addGrowthRecord:
            PlaceholderInfoRow(title: "接入状态", detail: "成长曲线已读取 child-specific growthRecords")
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/成长记录添加.html")
        case .parentProfile:
            PlaceholderInfoRow(title: "当前用户", detail: store.parentProfile.name)
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/个人信息.html")
        case .childProfile(let childID):
            let child = store.children.first { $0.id == childID } ?? store.activeChild
            PlaceholderInfoRow(title: "当前孩子", detail: child.name)
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/孩子信息.html")
        case .reminderDate:
            PlaceholderInfoRow(title: "提醒模式", detail: store.reminderSettings.mode.title)
            PlaceholderInfoRow(title: "自定义天数", detail: "\(store.reminderSettings.customDays) 天")
        case .reminderTime:
            PlaceholderInfoRow(title: "提醒时间", detail: store.reminderSettings.timeText)
            PlaceholderInfoRow(title: "提醒开关", detail: store.reminderSettings.isAlarmEnabled ? "已开启" : "已关闭")
        case .sharedMembers:
            PlaceholderInfoRow(title: "共享成员", detail: "\(store.sharedMembers.count) 位")
            PlaceholderButton(title: "添加共享成员") { store.openAddSharedMember() }
        case .addSharedMember:
            PlaceholderInfoRow(title: "接入状态", detail: "共享成员模型和路由已预留")
            PlaceholderInfoRow(title: "后续来源", detail: "reference/html/添加共享成员.html")
        case .vaccineDetail, .addVaccine:
            EmptyView()
        }
    }
}

struct ProfileIntegrationView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                GCColor.page.ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 14) {
                        header(topInset: proxy.safeAreaInsets.top)
                        profileCard
                        childCard
                        reminderCard
                        sharingCard
                        Color.clear.frame(height: BottomTabBar.reservedHeight(for: proxy.safeAreaInsets.bottom) + 16)
                    }
                }
                .ignoresSafeArea(edges: .top)

                BottomTabBar(bottomInset: proxy.safeAreaInsets.bottom)
            }
        }
    }

    private func header(topInset: CGFloat) -> some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            Text("我的")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.black)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
        }
        .frame(height: topInset + 110)
    }

    private var profileCard: some View {
        PlaceholderCard {
            PlaceholderInfoRow(title: "个人信息", detail: store.parentProfile.name)
            PlaceholderButton(title: "编辑个人信息") { store.openParentProfile() }
        }
    }

    private var childCard: some View {
        PlaceholderCard {
            PlaceholderInfoRow(title: "当前孩子", detail: store.activeChild.name)
            PlaceholderButton(title: "编辑孩子信息") { store.openChildProfile(childID: store.activeChild.id) }
        }
    }

    private var reminderCard: some View {
        PlaceholderCard {
            PlaceholderInfoRow(title: "提醒", detail: "\(store.reminderSettings.mode.title) \(store.reminderSettings.timeText)")
            PlaceholderButton(title: "提醒日期") { store.openReminderDate() }
            PlaceholderButton(title: "提醒时间") { store.openReminderTime() }
        }
    }

    private var sharingCard: some View {
        PlaceholderCard {
            PlaceholderInfoRow(title: "共享成员", detail: "\(store.sharedMembers.count) 位")
            PlaceholderButton(title: "管理共享成员") { store.openSharedMembers() }
            PlaceholderButton(title: "接种单位") { store.openClinicList() }
        }
    }
}

private struct PlaceholderScaffold<Content: View>: View {
    @EnvironmentObject private var store: GrowthCareStore
    let title: String
    let subtitle: String
    let content: Content

    init(title: String, subtitle: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GCColor.page.ignoresSafeArea()

                VStack(spacing: 0) {
                    header(topInset: proxy.safeAreaInsets.top)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            Text(subtitle)
                                .font(.system(size: 14))
                                .foregroundColor(GCColor.textSecondary)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .lineSpacing(4)
                                .padding(.horizontal, 20)
                                .padding(.top, 22)

                            PlaceholderCard {
                                content
                            }
                        }
                        .padding(.bottom, 32)
                    }
                }
            }
        }
    }

    private func header(topInset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack {
                BackCircleButton {
                    store.popNavigation()
                }

                Spacer()

                Text(title)
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Spacer()
                Color.clear.frame(width: 44, height: 44)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
        .frame(height: topInset + 86)
        .ignoresSafeArea(edges: .top)
    }
}

private struct PlaceholderCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 12) {
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .padding(.horizontal, 20)
    }
}

private struct PlaceholderInfoRow: View {
    let title: String
    let detail: String

    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.black)
                .frame(width: 88, alignment: .leading)

            Text(detail)
                .font(.system(size: 14))
                .foregroundColor(GCColor.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct PlaceholderButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 42)
                .background(GCColor.textSecondary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
