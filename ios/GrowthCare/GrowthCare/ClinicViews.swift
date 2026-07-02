import SwiftUI

struct ClinicListView: View {
    @EnvironmentObject private var store: GrowthCareStore
    @State private var searchText = ""

    private var filteredClinics: [Clinic] {
        let keyword = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !keyword.isEmpty else { return store.clinics }
        return store.clinics.filter {
            $0.name.localizedCaseInsensitiveContains(keyword) ||
                $0.address.localizedCaseInsensitiveContains(keyword)
        }
    }

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GCColor.page.ignoresSafeArea()

                VStack(spacing: 0) {
                    header(topInset: proxy.safeAreaInsets.top)
                    searchRow
                    filterRow
                    Divider()
                        .background(Color(hex: 0xD3D3D3))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 10)
                    clinicList
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func header(topInset: CGFloat) -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack {
                Button {
                    store.popNavigation()
                } label: {
                    Image("fanhui")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.10), radius: 10, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("返回")

                Spacer()

                Text("接种单位")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Spacer()

                Button {
                    store.openAddClinic()
                } label: {
                    Image("jiahao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 22, height: 22)
                        .frame(width: 40, height: 40)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("添加诊所")
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
        }
        .frame(height: GCLayout.formTopBandHeight)
        .ignoresSafeArea(edges: .top)
    }

    private var searchRow: some View {
        HStack(spacing: 20) {
            HStack(spacing: 10) {
                TextField("搜索接种单位", text: $searchText)
                    .font(.system(size: 16))
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
            }
            .padding(.horizontal, 12)
            .frame(height: 40)
            .background(Color(hex: 0xE9E3DF))
            .clipShape(Capsule())

            Button("搜索") {
                searchText = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            .font(.system(size: 16))
            .foregroundColor(.black)
        }
        .padding(.leading, 20)
        .padding(.trailing, 20)
        .padding(.top, 10)
        .padding(.bottom, 10)
    }

    private var filterRow: some View {
        HStack {
            ForEach(["地区", "疫苗", "厂商", "排序"], id: \.self) { title in
                Button {
                    store.toastMessage = "筛选：\(title)"
                } label: {
                    HStack(spacing: 8) {
                        Text(title)
                        Image("jiantouerhao")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 6, height: 11)
                            .rotationEffect(.degrees(90))
                    }
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                }
                .buttonStyle(.plain)
                if title != "排序" {
                    Spacer()
                }
            }
        }
        .frame(height: 30)
        .padding(.horizontal, 20)
        .alert("提示", isPresented: Binding(
            get: { store.toastMessage != nil },
            set: { if !$0 { store.toastMessage = nil } }
        )) {
            Button("好", role: .cancel) {
                store.toastMessage = nil
            }
        } message: {
            Text(store.toastMessage ?? "")
        }
    }

    private var clinicList: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if filteredClinics.isEmpty {
                    Text("未找到接种单位")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: 0x808080))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                } else {
                    ForEach(Array(filteredClinics.enumerated()), id: \.element.id) { index, clinic in
                        ClinicCard(clinic: clinic, distanceText: distanceText(index))
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private func distanceText(_ index: Int) -> String {
        let values = ["2.4km", "4.8km", "5.2km", "6.0km", "6.4km"]
        return values[min(index, values.count - 1)]
    }
}

struct AddClinicView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                Color(hex: 0xF7F2EF).ignoresSafeArea()

                comingSoonContent(screenHeight: proxy.size.height)

                header()
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    private func header() -> some View {
        ZStack(alignment: .bottom) {
            LinearGradient(
                colors: [GCColor.headerTop, GCColor.headerBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            HStack {
                Button {
                    store.popNavigation()
                } label: {
                    Image("fanhui")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .frame(width: 40, height: 40)
                        .background(Color.white.opacity(0.75))
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("返回")

                Spacer()

                Text("添加诊所")
                    .font(.system(size: 20))
                    .foregroundColor(.black)

                Spacer()
                Color.clear.frame(width: 40, height: 40)
            }
            .padding(.horizontal, 28)
            .padding(.bottom, 34)
        }
        .frame(height: GCLayout.formTopBandHeight)
        .ignoresSafeArea(edges: .top)
    }

    private func comingSoonContent(screenHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            Spacer(minLength: GCLayout.formTopBandHeight)

            VStack(spacing: 0) {
                Image("waiting")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300)

                Text("此功能正在开发中")
                    .font(.system(size: 22))
                    .foregroundColor(.black)
                    .padding(.top, 10)

                Text("很快就能帮您找到\n附近的接种点啦")
                    .font(.system(size: 16))
                    .foregroundColor(Color(hex: 0x8D8D8D))
                    .multilineTextAlignment(.center)
                    .lineSpacing(2)
                    .padding(.top, 28)

                Button {} label: {
                    Text("敬请期待")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 126, height: 44)
                        .background(GCColor.headerTop)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
                .padding(.top, 28)
            }
            .frame(maxWidth: .infinity)

            Spacer(minLength: 24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: 0xF7F2EF))
    }
}

private struct ClinicCard: View {
    let clinic: Clinic
    let distanceText: String

    var body: some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 15, style: .continuous)
                    .fill(Color(hex: 0xF3F3F3))
                Image("zhensuo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 23, height: 23)
            }
            .frame(width: 60, height: 60)

            VStack(alignment: .leading, spacing: 4) {
                Text(clinic.name)
                    .font(.system(size: 16))
                    .foregroundColor(.black)
                    .lineLimit(2)
                Text("门诊地址：\(clinic.address)")
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textSecondary)
                    .lineLimit(1)
                Text("营业时间：\(clinic.hours)")
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                Text("预约")
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textSecondary)
                    .padding(.horizontal, 16)
                    .frame(height: 20)
                    .background(Color(hex: 0xE0EBD8))
                    .clipShape(Capsule())

                Text(distanceText)
                    .font(.system(size: 12))
                    .foregroundColor(GCColor.textSecondary)
            }
            .frame(width: 56)
        }
        .padding(.horizontal, 13)
        .padding(.vertical, 10)
        .frame(minHeight: 90)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}
