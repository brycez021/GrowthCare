import SwiftUI
import UIKit
import PhotosUI

struct ProfileView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                GCColor.page.ignoresSafeArea()

                VStack(spacing: 0) {
                    profileTop(topInset: proxy.safeAreaInsets.top)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            childrenSection
                                .padding(.top, max(0, GCLayout.profileFirstSectionTopY - GCLayout.profileTopBandHeight))
                            reminderSection
                                .padding(.top, 10)
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: GCLayout.maxDesignWidth)
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, BottomTabBar.reservedHeight(for: proxy.safeAreaInsets.bottom) + 24)
                    }
                    .ignoresSafeArea(edges: .top)
                }

                parentProfileOverlay(topInset: proxy.safeAreaInsets.top)

                BottomNavShadow()

                BottomTabBar(bottomInset: proxy.safeAreaInsets.bottom)
            }
        }
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

    private func profileTop(topInset: CGFloat) -> some View {
        LinearGradient(
            colors: [GCColor.headerTop, GCColor.headerBottom],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(height: GCLayout.profileTopBandHeight)
        .offset(y: -topInset)
        .frame(height: max(0, GCLayout.profileTopBandHeight - topInset), alignment: .top)
    }

    private func parentProfileOverlay(topInset: CGFloat) -> some View {
        VStack(spacing: 0) {
            profileCard
                .padding(.horizontal, 20)
                .frame(maxWidth: GCLayout.maxDesignWidth)
                .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .padding(.top, GCLayout.profileCardTopY - topInset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .zIndex(20)
    }

    private var profileCard: some View {
        HStack(spacing: 16) {
            AvatarImage(asset: store.parentProfile.avatarAsset, data: store.parentProfile.avatarData)
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 10) {
                Text(store.parentProfile.name)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)

                Text(store.parentProfile.address)
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .lineSpacing(4)

                Button {
                    store.openParentProfile()
                } label: {
                    HStack(spacing: 7) {
                        Image("xiugaigerenxinxi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("修改家长信息")
                            .font(.system(size: 12))
                    }
                    .foregroundColor(Color(hex: 0x4A6250))
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .frame(height: 133)
        .background {
            RoundedRectangle(cornerRadius: 34, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 34, style: .continuous)
                        .fill(
                            LinearGradient(
                                stops: [
                                    .init(color: Color(hex: 0xFFF0EB).opacity(0.15), location: 0),
                                    .init(color: Color(hex: 0xFFF0EB).opacity(0.15), location: 0.4952),
                                    .init(color: Color(hex: 0xE9DDD9).opacity(0.30), location: 1)
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
        }
        .shadow(color: Color(hex: 0xE2CAC2).opacity(0.30), radius: 13, x: 0, y: 9)
    }

    private var childrenSection: some View {
        ProfileSection(icon: "haizixinxi", title: "孩子信息") {
            ForEach(Array(store.children.enumerated()), id: \.element.id) { index, child in
                ProfileRow(position: rowPosition(index: index, count: store.children.count + 1)) {
                    Button {
                        store.openChildProfile(childID: child.id)
                    } label: {
                        HStack {
                            Text(child.name)
                            Spacer()
                            Text(child.birthText)
                                .font(.system(size: 13))
                                .foregroundColor(GCColor.textSecondary)
                                .lineLimit(1)
                        }
                    }
                    .buttonStyle(.plain)
                    .foregroundColor(.black)
                }
            }

            addRow(position: .last) {
                store.openChildProfile()
            }
        }
    }

    private var reminderSection: some View {
        ProfileSection(icon: "tixing", title: "提醒") {
            ProfileRow(position: .first) {
                HStack {
                    Text("闹钟提醒")
                    Spacer()
                    Button {
                        store.updateReminder(isAlarmEnabled: !store.reminderSettings.isAlarmEnabled)
                    } label: {
                        AlarmToggleView(isOn: store.reminderSettings.isAlarmEnabled)
                    }
                    .buttonStyle(.plain)
                }
            }

            ProfileRow(position: .middle) {
                Button {
                    store.openReminderTime()
                } label: {
                    HStack {
                        Text("提醒时间")
                        Spacer()
                        Text(store.reminderSettings.timeText)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                }
                .buttonStyle(.plain)
                .foregroundColor(.black)
            }

            reminderModeRow(.sameDay, title: "预定当天", position: .middle)
            reminderModeRow(.oneDayBefore, title: "提前一天", position: .middle)
            reminderModeRow(.twoDaysBefore, title: "提前两天", position: .middle)

            reminderModeRow(
                .customDays,
                title: "自定义",
                detail: "提前\(store.reminderSettings.customDays)天",
                position: .last,
                showsDisclosureWhenUnselected: true
            ) {
                store.openReminderDate()
            }
        }
    }

    private func reminderModeRow(
        _ mode: ReminderMode,
        title: String,
        detail: String? = nil,
        position: ProfileRowPosition,
        showsDisclosureWhenUnselected: Bool = false,
        action: (() -> Void)? = nil
    ) -> some View {
        let selected = store.reminderSettings.mode == mode
        return ProfileRow(position: position, highlighted: selected) {
            Button {
                if let action {
                    action()
                } else {
                    store.updateReminder(mode: mode)
                }
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    if let detail {
                        Text(detail)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                    }
                    if selected {
                        Image("profile-icon-check")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 17, height: 17)
                    } else if showsDisclosureWhenUnselected && detail == nil {
                        rowCaret
                    }
                }
            }
            .buttonStyle(.plain)
            .foregroundColor(selected ? Color(hex: 0xFFA728) : .black)
        }
    }

    private var rowCaret: some View {
        Image("profile-icon-caret-right")
            .resizable()
            .scaledToFit()
            .frame(width: 17, height: 17)
    }

    private func addRow(position: ProfileRowPosition, action: @escaping () -> Void) -> some View {
        ProfileRow(position: position) {
            Button(action: action) {
                ProfileAddCenterIcon()
                    .frame(width: 20, height: 20)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.plain)
        }
    }

    private func rowPosition(index: Int, count: Int) -> ProfileRowPosition {
        if count == 1 { return .single }
        if index == 0 { return .first }
        if index == count - 1 { return .last }
        return .middle
    }
}

private struct ProfileAddCenterIcon: View {
    var body: some View {
        GeometryReader { proxy in
            let length = min(proxy.size.width, proxy.size.height)
            Path { path in
                path.move(to: CGPoint(x: proxy.size.width / 2, y: (proxy.size.height - length) / 2))
                path.addLine(to: CGPoint(x: proxy.size.width / 2, y: (proxy.size.height + length) / 2))
                path.move(to: CGPoint(x: (proxy.size.width - length) / 2, y: proxy.size.height / 2))
                path.addLine(to: CGPoint(x: (proxy.size.width + length) / 2, y: proxy.size.height / 2))
            }
            .stroke(
                Color(hex: 0x464646),
                style: StrokeStyle(lineWidth: 1.6, lineCap: .round)
            )
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

struct ParentProfileView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var name = ""
    @State private var phone = ""
    @State private var idNumber = ""
    @State private var address = ""
    @State private var avatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    var body: some View {
        GeometryReader { proxy in
            let headerHeight = GCLayout.formTopBandHeight
            ZStack(alignment: .top) {
                formLayeredBackground(headerHeight: headerHeight)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: headerHeight)
                        .allowsHitTesting(false)

                    VStack(spacing: 0) {
                        parentAvatar
                            .padding(.top, 16)

                        VStack(spacing: 24) {
                            ProfileTextField(title: "昵称", text: $name)
                            ProfileTextField(title: "电话号码", text: $phone)
                            ProfileTextField(title: "证件号码", text: $idNumber)
                            ProfileTextField(title: "家庭地址", text: $address, smallText: true)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                        Button {
                            store.updateParentProfile(
                                name: name,
                                phone: phone,
                                idNumber: idNumber,
                                address: address,
                                avatarData: avatarData
                            )
                        } label: {
                            Text("完成")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 44)
                                .background(Color(hex: 0x464646))
                                .clipShape(Capsule())
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, 39)
                        .padding(.top, 32)

                        Text("App不收集任何用户个人数据，所有数据仅存储在本地设备")
                            .font(.system(size: 12))
                            .foregroundColor(GCColor.textMuted)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.horizontal, 39)
                            .padding(.top, 18)
                    }
                    .frame(maxWidth: GCLayout.maxDesignWidth)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    .offset(y: -60)
                }

                parentProfileHeader
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            name = store.parentProfile.name
            phone = store.parentProfile.phone
            idNumber = store.parentProfile.idNumber
            address = store.parentProfile.address
            avatarData = store.parentProfile.avatarData
        }
        .onChange(of: selectedPhoto) { newItem in
            loadSelectedParentAvatar(from: newItem)
        }
    }

    private func formLayeredBackground(headerHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: headerHeight)

            GCColor.page
        }
        .ignoresSafeArea(edges: [.top, .bottom])
    }

    private var parentProfileHeader: some View {
        GeometryReader { proxy in
            let contentWidth = min(proxy.size.width, GCLayout.maxDesignWidth)
            let contentLeading = (proxy.size.width - contentWidth) / 2

            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [GCColor.headerTop, GCColor.headerBottom],
                    startPoint: .top,
                    endPoint: .bottom
                )

                BackCircleButton {
                    store.popNavigation()
                }
                .position(x: contentLeading + 48, y: 93)

                Text("家长信息")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(.black)
                    .frame(height: 28)
                    .frame(maxWidth: .infinity)
                    .position(x: proxy.size.width / 2, y: 88)
            }
        }
        .frame(height: GCLayout.formTopBandHeight)
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .ignoresSafeArea(edges: .top)
    }

    private var parentAvatar: some View {
        let avatarAsset = store.parentProfile.avatarAsset
        return PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
            avatar(asset: avatarAsset, data: avatarData)
        }
        .buttonStyle(.plain)
    }

    private func loadSelectedParentAvatar(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            if let data = try? await item.loadTransferable(type: Data.self) {
                await MainActor.run {
                    avatarData = data
                }
            }
        }
    }
}

struct ChildProfileView: View {
    @EnvironmentObject private var store: GrowthCareStore
    let childID: String?

    @State private var name = ""
    @State private var gender = "女"
    @State private var birthDate = Date()
    @State private var relationship = "母女"
    @State private var colorName = "默认"
    @State private var colorHex: UInt = 0xD89698
    @State private var avatarData: Data?
    @State private var selectedPhoto: PhotosPickerItem?

    private var relationshipOptions: [String] {
        gender == "男" ? ["母子", "父子", "其他"] : ["母女", "父女", "其他"]
    }

    var body: some View {
        ProfileFormScaffold(
            title: "孩子信息",
            usesAbsoluteTopBand: true,
            isScrollEnabled: false,
            contentTopOffset: -60
        ) {
            VStack(spacing: 24) {
                editableAvatar
                ProfileTextField(title: "姓名", text: $name)
                genderPicker
                birthPicker
                relationshipPicker
                submitButton("完成") {
                    store.saveChildProfile(
                        childID: childID,
                        name: name,
                        birthDate: birthDate,
                        gender: gender,
                        relationship: relationship,
                        colorName: colorName,
                        colorHex: colorHex,
                        avatarData: avatarData
                    )
                }
            }
        }
        .onAppear(perform: loadChild)
        .onChange(of: gender) { _ in
            normalizeRelationship()
        }
        .onChange(of: selectedPhoto) { newItem in
            loadSelectedAvatar(from: newItem)
        }
    }

    private var selectedChild: ChildProfile? {
        childID.flatMap { id in store.children.first { $0.id == id } }
    }

    private var editableAvatar: some View {
        PhotosPicker(selection: $selectedPhoto, matching: .images, photoLibrary: .shared()) {
            avatar(asset: selectedChild?.avatarAsset ?? "unsplash_JfolIjRnveY", data: avatarData)
        }
        .buttonStyle(.plain)
    }

    private var genderPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("性别")
                .font(.system(size: 16))
            HStack(spacing: 0) {
                ForEach(["男", "女"], id: \.self) { option in
                    Button {
                        gender = option
                        normalizeRelationship(for: option)
                    } label: {
                        Text(option)
                            .font(.system(size: 16, weight: gender == option ? .semibold : .regular))
                            .foregroundColor(gender == option ? .black : Color(hex: 0x5C5C5C))
                            .frame(maxWidth: .infinity)
                            .frame(height: 45)
                    }
                    .buttonStyle(.plain)
                    if option == "男" {
                        Rectangle()
                            .fill(Color(hex: 0xD3D3D3))
                            .frame(width: 1, height: 23)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
    }

    private var birthPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("出生日期")
                .font(.system(size: 16))
            DatePicker("", selection: $birthDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .environment(\.locale, Locale(identifier: "zh_CN"))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 18)
                .frame(height: 45)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
    }

    private var relationshipPicker: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("与本人关系")
                .font(.system(size: 16))
            Menu {
                ForEach(relationshipOptions, id: \.self) { option in
                    Button(option) {
                        relationship = option
                    }
                }
            } label: {
                PickerRowLabel(title: relationship)
            }
        }
    }

    private func loadChild() {
        if let child = selectedChild {
            name = child.name
            gender = child.gender
            birthDate = child.birthDate
            relationship = child.relationship
            colorName = child.colorName
            colorHex = child.colorHex
            avatarData = child.avatarData
            normalizeRelationship()
        } else {
            name = ""
            gender = "女"
            birthDate = Date()
            relationship = "母女"
            colorName = "默认"
            colorHex = 0xD89698
            avatarData = nil
        }
    }

    private func normalizeRelationship(for nextGender: String? = nil) {
        let options = nextGender == "男" ? ["母子", "父子", "其他"] : nextGender == "女" ? ["母女", "父女", "其他"] : relationshipOptions
        if !options.contains(relationship) {
            relationship = options[0]
        }
    }

    private func loadSelectedAvatar(from item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self) else { return }
            await MainActor.run {
                avatarData = data
            }
        }
    }
}

struct ReminderDateView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var days = 10

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ProfileView()
                    .environmentObject(store)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                Color.black.opacity(0.30)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.popNavigation()
                    }

                reminderDateCard(width: min(proxy.size.width - 40, 400))
                    .padding(.top, max(proxy.safeAreaInsets.top + 170, proxy.size.height * 0.277))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            days = store.reminderSettings.customDays
        }
    }

    private func reminderDateCard(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 7) {
                Text("提醒日期")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)

                Text("提前\(days)天")
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .frame(width: 60, height: 21)
                    .overlay {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color(hex: 0xCCCCCC), lineWidth: 0.5)
                    }
            }
            .padding(.top, 48)

            ReminderDaysWheelPicker(days: $days)
                .frame(width: 132, height: 168)
                .padding(.top, 25)

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Button {
                    store.popNavigation()
                } label: {
                    Text("取消")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(hex: 0xD9D9D9))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    store.updateReminder(mode: .customDays, customDays: days)
                    store.popNavigation()
                } label: {
                    Text("确定")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(GCColor.headerTop)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: width, height: 398)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct ReminderDaysWheelPicker: View {
    @Binding var days: Int

    var body: some View {
        ZStack {
            ReminderDaysWheel(days: $days)
                .frame(width: 112, height: 168)

            VStack(spacing: 41) {
                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: 65, height: 1)
                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: 65, height: 1)
            }
            .allowsHitTesting(false)

            Text("天")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.black)
                .tracking(0.35)
                .textCase(.uppercase)
                .offset(x: 28, y: -7)
                .allowsHitTesting(false)
        }
    }
}

private struct ReminderDaysWheel: UIViewRepresentable {
    @Binding var days: Int
    private let values = Array(1...30)

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        picker.selectRow(row(for: days), inComponent: 0, animated: false)
        clearSelectionChrome(for: picker)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        let currentRow = picker.selectedRow(inComponent: 0)
        let targetRow = row(for: days)
        if currentRow != targetRow {
            picker.selectRow(targetRow, inComponent: 0, animated: true)
        }
        picker.reloadAllComponents()
        clearSelectionChrome(for: picker)
        DispatchQueue.main.async {
            clearSelectionChrome(for: picker)
        }
    }

    private func row(for value: Int) -> Int {
        values.firstIndex(of: min(max(value, 1), 30)) ?? 0
    }

    private func clearSelectionChrome(for picker: UIPickerView) {
        picker.backgroundColor = .clear
        picker.isOpaque = false
        picker.subviews.forEach { subview in
            subview.backgroundColor = .clear
            subview.isOpaque = false
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ReminderDaysWheel

        init(_ parent: ReminderDaysWheel) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            72
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            104
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.days = parent.values[row]
            pickerView.reloadAllComponents()
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            let value = parent.values[row]
            label.text = "\(value)"
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.isOpaque = false
            label.font = value == parent.days
                ? UIFont.systemFont(ofSize: 28, weight: .semibold)
                : UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = value == parent.days
                ? UIColor(Color(hex: 0x464646))
                : UIColor(Color(hex: 0xCCCCCC))
            return label
        }
    }
}

struct ReminderTimeView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var period = "上午"
    @State private var hour = 10
    @State private var minute = 0

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                ProfileView()
                    .environmentObject(store)
                    .allowsHitTesting(false)
                    .ignoresSafeArea()

                Color.black.opacity(0.30)
                    .ignoresSafeArea()
                    .onTapGesture {
                        store.popNavigation()
                    }

                reminderTimeCard(width: min(proxy.size.width - 40, 400))
                    .padding(.top, max(proxy.safeAreaInsets.top + 170, proxy.size.height * 0.277))
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            let parsed = Self.parse(store.reminderSettings.timeText)
            period = parsed.period
            hour = parsed.hour
            minute = parsed.minute
        }
    }

    private static func parse(_ text: String) -> (period: String, hour: Int, minute: Int) {
        let period = text.hasPrefix("下午") ? "下午" : "上午"
        let stripped = text
            .replacingOccurrences(of: "上午", with: "")
            .replacingOccurrences(of: "下午", with: "")
            .trimmingCharacters(in: .whitespaces)
        let parts = stripped.split(separator: ":")
        let hour = parts.first.flatMap { Int($0) } ?? 10
        let minute = parts.dropFirst().first.flatMap { Int($0) } ?? 0
        return (period, min(max(hour, 1), 12), min(max(minute, 0), 59))
    }

    private var badgeText: String {
        "\(period) \(String(format: "%02d", hour)):\(String(format: "%02d", minute))"
    }

    private func reminderTimeCard(width: CGFloat) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 7) {
                Text("提醒时间")
                    .font(.system(size: 22, weight: .regular))
                    .foregroundColor(.black)

                Text(badgeText)
                    .font(.system(size: 10))
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .frame(width: 68, height: 21)
                    .overlay {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .stroke(Color(hex: 0xCCCCCC), lineWidth: 0.5)
                    }
            }
            .padding(.top, 48)

            ReminderTimeWheelPicker(period: $period, hour: $hour, minute: $minute)
                .frame(width: 276, height: 168)
                .padding(.top, 25)

            Spacer(minLength: 0)

            HStack(spacing: 16) {
                Button {
                    store.popNavigation()
                } label: {
                    Text("取消")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color(hex: 0xD9D9D9))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button {
                    store.updateReminder(timeText: "\(period)\(String(format: "%02d", hour)):\(String(format: "%02d", minute))")
                    store.popNavigation()
                } label: {
                    Text("确定")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(GCColor.headerTop)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .frame(width: width, height: 398)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}

private struct ReminderTimeWheelPicker: View {
    @Binding var period: String
    @Binding var hour: Int
    @Binding var minute: Int

    var body: some View {
        ZStack(alignment: .topLeading) {
            ReminderTimeWheelsView(period: $period, hour: $hour, minute: $minute)
                .frame(width: 276, height: 168)

            pickerLines(width: 86)
                .frame(width: 86, height: 168)
                .position(x: 43, y: 84)

            pickerLines(width: 65)
                .frame(width: 65, height: 168)
                .position(x: 148.5, y: 84)

            pickerLines(width: 65)
                .frame(width: 65, height: 168)
                .position(x: 243.5, y: 84)

            Text("时")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.black)
                .tracking(0.35)
                .position(x: 176.5, y: 77)

            Text("分")
                .font(.system(size: 10, weight: .regular))
                .foregroundColor(.black)
                .tracking(0.35)
                .position(x: 271.5, y: 77)
        }
        .frame(width: 276, height: 168)
        .allowsHitTesting(true)
    }

    private func pickerLines(width: CGFloat) -> some View {
        VStack(spacing: 41) {
            Rectangle()
                .fill(Color(hex: 0xCCCCCC))
                .frame(width: width, height: 1)
            Rectangle()
                .fill(Color(hex: 0xCCCCCC))
                .frame(width: width, height: 1)
        }
        .allowsHitTesting(false)
    }
}

private struct ReminderTimeWheelsView: UIViewRepresentable {
    @Binding var period: String
    @Binding var hour: Int
    @Binding var minute: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> TimeWheelHostView {
        let view = TimeWheelHostView()
        [view.periodPicker, view.hourPicker, view.minutePicker].forEach { picker in
            picker.dataSource = context.coordinator
            picker.delegate = context.coordinator
            picker.backgroundColor = .clear
            clearPickerChrome(for: picker)
        }
        view.periodPicker.selectRow(context.coordinator.periodRow(for: period), inComponent: 0, animated: false)
        view.hourPicker.selectRow(context.coordinator.hourRow(for: hour), inComponent: 0, animated: false)
        view.minutePicker.selectRow(context.coordinator.minuteRow(for: minute), inComponent: 0, animated: false)
        return view
    }

    func updateUIView(_ view: TimeWheelHostView, context: Context) {
        context.coordinator.parent = self
        context.coordinator.sync(view)
        [view.periodPicker, view.hourPicker, view.minutePicker].forEach { picker in
            picker.reloadAllComponents()
            clearPickerChrome(for: picker)
        }
        DispatchQueue.main.async {
            [view.periodPicker, view.hourPicker, view.minutePicker].forEach(clearPickerChrome)
        }
    }

    final class TimeWheelHostView: UIView {
        let periodPicker = UIPickerView()
        let hourPicker = UIPickerView()
        let minutePicker = UIPickerView()

        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = .clear
            isOpaque = false
            clipsToBounds = true
            [periodPicker, hourPicker, minutePicker].forEach { picker in
                picker.backgroundColor = .clear
                picker.clipsToBounds = true
                addSubview(picker)
            }
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            periodPicker.frame = CGRect(x: 0, y: 0, width: 86, height: bounds.height)
            hourPicker.frame = CGRect(x: 116, y: 0, width: 65, height: bounds.height)
            minutePicker.frame = CGRect(x: 211, y: 0, width: 65, height: bounds.height)
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard isUserInteractionEnabled, !isHidden, alpha > 0.01 else { return nil }
            if periodPicker.frame.contains(point) {
                let localPoint = convert(point, to: periodPicker)
                return periodPicker.hitTest(localPoint, with: event) ?? periodPicker
            }
            if hourPicker.frame.contains(point) {
                let localPoint = convert(point, to: hourPicker)
                return hourPicker.hitTest(localPoint, with: event) ?? hourPicker
            }
            if minutePicker.frame.contains(point) {
                let localPoint = convert(point, to: minutePicker)
                return minutePicker.hitTest(localPoint, with: event) ?? minutePicker
            }
            return nil
        }
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ReminderTimeWheelsView
        private let periods = ["上午", "下午"]
        private let hours = Array(1...12)
        private let minutes = Array(0...59)
        private let repeatCount = 200

        init(_ parent: ReminderTimeWheelsView) {
            self.parent = parent
        }

        func sync(_ view: TimeWheelHostView) {
            select(view.periodPicker, row: periodRow(for: parent.period))
            if hourValue(for: view.hourPicker.selectedRow(inComponent: 0)) != clampedHour(parent.hour) {
                select(view.hourPicker, row: hourRow(for: parent.hour))
            }
            if minuteValue(for: view.minutePicker.selectedRow(inComponent: 0)) != clampedMinute(parent.minute) {
                select(view.minutePicker, row: minuteRow(for: parent.minute))
            }
        }

        func periodRow(for value: String) -> Int {
            periods.firstIndex(of: value) ?? 0
        }

        func hourRow(for value: Int) -> Int {
            row(for: clampedHour(value), values: hours)
        }

        func minuteRow(for value: Int) -> Int {
            row(for: clampedMinute(value), values: minutes)
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            if pickerView.tag == 0 && pickerView === (pickerView.superview as? TimeWheelHostView)?.periodPicker {
                return periods.count
            }
            return pickerView === (pickerView.superview as? TimeWheelHostView)?.hourPicker
                ? hours.count * repeatCount
                : minutes.count * repeatCount
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            72
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            pickerView === (pickerView.superview as? TimeWheelHostView)?.periodPicker ? 86 : 65
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            guard let host = pickerView.superview as? TimeWheelHostView else { return }
            if pickerView === host.periodPicker {
                parent.period = periods[row]
            } else if pickerView === host.hourPicker {
                parent.hour = hourValue(for: row)
            } else {
                parent.minute = minuteValue(for: row)
            }
            pickerView.reloadAllComponents()
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            let host = pickerView.superview as? TimeWheelHostView
            let text: String
            let selected: Bool
            if pickerView === host?.periodPicker {
                text = periods[row]
                selected = periods[row] == parent.period
            } else if pickerView === host?.hourPicker {
                let value = hourValue(for: row)
                text = "\(value)"
                selected = value == clampedHour(parent.hour)
            } else {
                let value = minuteValue(for: row)
                text = String(format: "%02d", value)
                selected = value == clampedMinute(parent.minute)
            }
            label.text = text
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.isOpaque = false
            label.font = selected
                ? UIFont.systemFont(ofSize: 28, weight: .semibold)
                : UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = selected
                ? UIColor(Color(hex: 0x464646))
                : UIColor(Color(hex: 0xCCCCCC))
            return label
        }

        private func select(_ picker: UIPickerView, row: Int) {
            if picker.selectedRow(inComponent: 0) != row {
                picker.selectRow(row, inComponent: 0, animated: true)
            }
        }

        private func row(for value: Int, values: [Int]) -> Int {
            let selectedIndex = values.firstIndex(of: value) ?? 0
            return values.count * (repeatCount / 2) + selectedIndex
        }

        private func hourValue(for row: Int) -> Int {
            valuesValue(for: row, values: hours)
        }

        private func minuteValue(for row: Int) -> Int {
            valuesValue(for: row, values: minutes)
        }

        private func valuesValue(for row: Int, values: [Int]) -> Int {
            values[((row % values.count) + values.count) % values.count]
        }

        private func clampedHour(_ value: Int) -> Int {
            min(max(value, 1), 12)
        }

        private func clampedMinute(_ value: Int) -> Int {
            min(max(value, 0), 59)
        }
    }
}

private struct ReminderTimeWheelColumn<Wheel: View>: View {
    let width: CGFloat
    var unit: String?
    let wheel: () -> Wheel

    init(width: CGFloat, unit: String? = nil, @ViewBuilder wheel: @escaping () -> Wheel) {
        self.width = width
        self.unit = unit
        self.wheel = wheel
    }

    var body: some View {
        ZStack {
            wheel()
                .frame(width: width, height: 168)

            VStack(spacing: 41) {
                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: width, height: 1)
                Rectangle()
                    .fill(Color(hex: 0xCCCCCC))
                    .frame(width: width, height: 1)
            }
            .allowsHitTesting(false)

            if let unit {
                Text(unit)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(.black)
                    .tracking(0.35)
                    .offset(x: 28, y: -7)
                    .allowsHitTesting(false)
            }
        }
        .frame(width: width, height: 168)
    }
}

private struct ReminderPeriodWheel: UIViewRepresentable {
    @Binding var period: String
    private let values = ["上午", "下午"]

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        picker.selectRow(row(for: period), inComponent: 0, animated: false)
        clearPickerChrome(for: picker)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        let targetRow = row(for: period)
        if picker.selectedRow(inComponent: 0) != targetRow {
            picker.selectRow(targetRow, inComponent: 0, animated: true)
        }
        picker.reloadAllComponents()
        clearPickerChrome(for: picker)
        DispatchQueue.main.async {
            clearPickerChrome(for: picker)
        }
    }

    private func row(for value: String) -> Int {
        values.firstIndex(of: value) ?? 0
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ReminderPeriodWheel

        init(_ parent: ReminderPeriodWheel) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            72
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            86
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.period = parent.values[row]
            pickerView.reloadAllComponents()
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            let value = parent.values[row]
            label.text = value
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.isOpaque = false
            label.font = value == parent.period
                ? UIFont.systemFont(ofSize: 28, weight: .semibold)
                : UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = value == parent.period
                ? UIColor(Color(hex: 0x464646))
                : UIColor(Color(hex: 0xCCCCCC))
            return label
        }
    }
}

private struct ReminderLoopingNumberWheel: UIViewRepresentable {
    @Binding var value: Int
    private let values: [Int]
    private let usesLeadingZero: Bool
    private let repeatCount = 200

    init(value: Binding<Int>, values: [Int], usesLeadingZero: Bool = false) {
        self._value = value
        self.values = values
        self.usesLeadingZero = usesLeadingZero
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .clear
        picker.selectRow(row(for: value), inComponent: 0, animated: false)
        clearPickerChrome(for: picker)
        return picker
    }

    func updateUIView(_ picker: UIPickerView, context: Context) {
        context.coordinator.parent = self
        if value(for: picker.selectedRow(inComponent: 0)) != clamped(value) {
            picker.selectRow(row(for: value), inComponent: 0, animated: true)
        }
        picker.reloadAllComponents()
        clearPickerChrome(for: picker)
        DispatchQueue.main.async {
            clearPickerChrome(for: picker)
        }
    }

    private func row(for value: Int) -> Int {
        let selectedIndex = values.firstIndex(of: clamped(value)) ?? 0
        return values.count * (repeatCount / 2) + selectedIndex
    }

    private func value(for row: Int) -> Int {
        values[((row % values.count) + values.count) % values.count]
    }

    private func clamped(_ value: Int) -> Int {
        min(max(value, values.first ?? value), values.last ?? value)
    }

    private func text(for value: Int) -> String {
        usesLeadingZero ? String(format: "%02d", value) : "\(value)"
    }

    final class Coordinator: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
        var parent: ReminderLoopingNumberWheel

        init(_ parent: ReminderLoopingNumberWheel) {
            self.parent = parent
        }

        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            1
        }

        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            parent.values.count * parent.repeatCount
        }

        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            72
        }

        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            65
        }

        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.value = parent.value(for: row)
            pickerView.reloadAllComponents()
        }

        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let label = (view as? UILabel) ?? UILabel()
            let rowValue = parent.value(for: row)
            let isSelected = rowValue == parent.clamped(parent.value)
            label.text = parent.text(for: rowValue)
            label.textAlignment = .center
            label.backgroundColor = .clear
            label.isOpaque = false
            label.font = isSelected
                ? UIFont.systemFont(ofSize: 28, weight: .semibold)
                : UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textColor = isSelected
                ? UIColor(Color(hex: 0x464646))
                : UIColor(Color(hex: 0xCCCCCC))
            return label
        }
    }
}

private func clearPickerChrome(for picker: UIPickerView) {
    picker.backgroundColor = .clear
    picker.isOpaque = false
    picker.subviews.forEach { subview in
        subview.backgroundColor = .clear
        subview.isOpaque = false
    }
}

struct SharedMembersView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        ProfileFormScaffold(title: "共享成员") {
            VStack(spacing: 14) {
                ForEach(store.sharedMembers) { member in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.name)
                                .font(.system(size: 16))
                            Text("\(member.role)  \(member.phone)")
                                .font(.system(size: 13))
                                .foregroundColor(GCColor.textSecondary)
                        }
                        Spacer()
                        Button("删除") {
                            store.removeSharedMember(id: member.id)
                        }
                        .font(.system(size: 14))
                        .foregroundColor(GCColor.headerTop)
                    }
                    .padding(.horizontal, 18)
                    .frame(height: 64)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                submitButton("添加共享成员") {
                    store.openAddSharedMember()
                }
            }
        }
    }
}

struct AddSharedMemberView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var name = ""
    @State private var role = "家人"
    @State private var phone = ""

    var body: some View {
        ModalScaffold {
            VStack(spacing: 20) {
                modalTitle("添加共享成员", badge: "共享孩子的疫苗信息")

                Text("新成员登录后可同步已有的孩子信息、疫苗预约、预约通知、疫苗记录与成长记录。")
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, alignment: .leading)

                ProfileTextField(title: "成员姓名", text: $name)
                ProfileTextField(title: "关系", text: $role)
                ProfileTextField(title: "电话号码", text: $phone)

                HStack(spacing: 12) {
                    modalButton(title: "取消", outlined: true) {
                        store.popNavigation()
                    }
                    modalButton(title: "添加", outlined: false) {
                        store.addSharedMember(name: name, role: role, phone: phone)
                    }
                }
            }
        }
    }
}

private struct ProfileFormScaffold<Content: View>: View {
    @EnvironmentObject private var store: GrowthCareStore
    let title: String
    let usesAbsoluteTopBand: Bool
    let isScrollEnabled: Bool
    let contentTopOffset: CGFloat
    let content: Content

    init(
        title: String,
        usesAbsoluteTopBand: Bool = false,
        isScrollEnabled: Bool = true,
        contentTopOffset: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.usesAbsoluteTopBand = usesAbsoluteTopBand
        self.isScrollEnabled = isScrollEnabled
        self.contentTopOffset = contentTopOffset
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let headerHeight = formHeaderHeight(topInset: proxy.safeAreaInsets.top)
            ZStack(alignment: .top) {
                formLayeredBackground(headerHeight: headerHeight)

                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: headerHeight)
                        .allowsHitTesting(false)

                    if isScrollEnabled {
                        ScrollView(showsIndicators: false) {
                            content
                                .padding(.horizontal, 20)
                                .padding(.top, 16 + contentTopOffset)
                                .padding(.bottom, 40)
                        }
                        .background(GCColor.page)
                        .clipped()
                    } else {
                        content
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 40)
                            .frame(maxWidth: GCLayout.maxDesignWidth)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .offset(y: contentTopOffset)
                    }
                }

                formHeader(topInset: proxy.safeAreaInsets.top)
                    .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func formHeaderHeight(topInset: CGFloat) -> CGFloat {
        usesAbsoluteTopBand ? GCLayout.formTopBandHeight : topInset + GCLayout.formTopBandHeight
    }

    private func formLayeredBackground(headerHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: headerHeight)

            GCColor.page
        }
        .ignoresSafeArea(edges: [.top, .bottom])
    }

    private func formHeader(topInset: CGFloat) -> some View {
        let headerHeight = formHeaderHeight(topInset: topInset)

        return ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)

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
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
            .frame(maxWidth: GCLayout.maxDesignWidth)
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .frame(height: headerHeight)
        .background(
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
        )
        .ignoresSafeArea(edges: .top)
    }
}

private struct ProfileTextField: View {
    let title: String
    @Binding var text: String
    var smallText = false

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(.black)
            TextField(title, text: $text)
                .font(.system(size: smallText ? 12 : 16))
                .foregroundColor(smallText ? GCColor.textSecondary : Color(hex: 0x5C5C5C))
                .padding(.horizontal, smallText ? 24 : 18)
                .frame(height: 45)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
    }
}

private struct PickerRow: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x5C5C5C))
                Spacer()
                Image("vector-down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 17, height: 17)
            }
            .padding(.horizontal, 18)
            .frame(height: 45)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct PickerRowLabel: View {
    let title: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 16))
                .foregroundColor(Color(hex: 0x5C5C5C))
            Spacer()
            Image("vector-down")
                .resizable()
                .scaledToFit()
                .frame(width: 17, height: 17)
        }
        .padding(.horizontal, 18)
        .frame(height: 45)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
    }
}

private struct ModalScaffold<Content: View>: View {
    @EnvironmentObject private var store: GrowthCareStore
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom, GCColor.page],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            Color.black.opacity(0.30)
                .ignoresSafeArea()
                .onTapGesture {
                    store.popNavigation()
                }

            content
                .padding(24)
                .frame(maxWidth: GCLayout.maxDesignWidth - 40)
                .background(Color.white.opacity(0.98))
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                .padding(.horizontal, 20)
                .onTapGesture { }
        }
        .navigationBarBackButtonHidden(true)
    }
}

private struct ProfileSection<Content: View>: View {
    let icon: String
    let title: String
    let content: Content

    init(icon: String, title: String, @ViewBuilder content: () -> Content) {
        self.icon = icon
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 3) {
                Image(icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 19, height: 19)
                Text(title)
                    .font(.system(size: 16))
                    .foregroundColor(GCColor.textSecondary)
            }
            .padding(.leading, 2)

            VStack(spacing: 3) {
                content
            }
        }
    }
}

private enum ProfileRowPosition {
    case first
    case middle
    case last
    case single
}

private struct ProfileRow<Content: View>: View {
    let position: ProfileRowPosition
    var highlighted = false
    let content: Content

    init(position: ProfileRowPosition, highlighted: Bool = false, @ViewBuilder content: () -> Content) {
        self.position = position
        self.highlighted = highlighted
        self.content = content()
    }

    var body: some View {
        content
            .font(.system(size: 16))
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, minHeight: 40, alignment: .leading)
            .background(highlighted ? Color(hex: 0xFFFBE8) : Color.white)
            .clipShape(rowShape)
    }

    private var rowShape: UnevenRoundedRectangle {
        switch position {
        case .single:
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 20, bottomTrailing: 20, topTrailing: 20))
        case .first:
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 20, bottomLeading: 5, bottomTrailing: 5, topTrailing: 20))
        case .middle:
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, bottomLeading: 5, bottomTrailing: 5, topTrailing: 5))
        case .last:
            return UnevenRoundedRectangle(cornerRadii: .init(topLeading: 5, bottomLeading: 20, bottomTrailing: 20, topTrailing: 5))
        }
    }
}

private struct AlarmToggleView: View {
    let isOn: Bool

    var body: some View {
        ZStack(alignment: isOn ? .leading : .trailing) {
            Capsule()
                .fill(isOn ? Color(hex: 0x4D8266) : Color(hex: 0x838383))
                .overlay {
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isOn ? 0.22 : 0.30),
                                    Color.white.opacity(0.04)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    Capsule()
                        .stroke(Color.white.opacity(isOn ? 0.14 : 0.28), lineWidth: 0.7)
                }
                .frame(width: 40, height: 18)
            Circle()
                .fill(isOn ? Color(hex: 0xD8E2CF).opacity(0.42) : Color.white.opacity(0.48))
                .background {
                    Circle()
                        .fill(Color.white.opacity(isOn ? 0.10 : 0.22))
                        .blur(radius: 2)
                }
                .overlay {
                    Circle()
                        .stroke(Color.white.opacity(isOn ? 0.22 : 0.38), lineWidth: 0.6)
                }
                .frame(width: 22, height: 22)
                .overlay {
                    Image(isOn ? "naozhong-toggle-bell" : "naozhong-toggle-bell-off")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 10, height: isOn ? 10.83 : 10.84)
                }
        }
        .frame(width: 40, height: 22)
    }
}

private func avatar(asset: String, data: Data? = nil) -> some View {
    ZStack(alignment: .bottomTrailing) {
        AvatarImage(asset: asset, data: data)
            .scaledToFill()
            .frame(width: 80, height: 80)
            .clipShape(Circle())
        Image("profile-avatar-edit")
            .resizable()
            .scaledToFit()
            .frame(width: 24, height: 24)
    }
    .frame(maxWidth: .infinity)
}

private func submitButton(_ title: String, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(hex: 0x464646))
            .clipShape(Capsule())
            .padding(.horizontal, 24)
    }
    .buttonStyle(.plain)
    .padding(.top, 8)
}

private func modalTitle(_ title: String, badge: String) -> some View {
    VStack(spacing: 16) {
        Text(title)
            .font(.system(size: 22))
            .foregroundColor(.black)
        Text(badge)
            .font(.system(size: 10))
            .foregroundColor(.black)
            .padding(.horizontal, 12)
            .frame(height: 20)
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .stroke(Color(hex: 0xCCCCCC), lineWidth: 0.5)
            }
    }
}

private func modalButton(title: String, outlined: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
        Text(title)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(outlined ? GCColor.headerTop : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(outlined ? Color.white : GCColor.headerTop)
            .overlay(
                Capsule()
                    .stroke(GCColor.headerTop, lineWidth: outlined ? 1 : 0)
            )
            .clipShape(Capsule())
    }
    .buttonStyle(.plain)
}
