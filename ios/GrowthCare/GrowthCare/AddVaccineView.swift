import SwiftUI

struct AddVaccineView: View {
    @EnvironmentObject private var store: GrowthCareStore

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .top) {
                GCColor.page.ignoresSafeArea()

                VStack(spacing: 0) {
                    header(topInset: proxy.safeAreaInsets.top)
                    vaccineList
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
                BackCircleButton {
                    store.popNavigation()
                }

                Spacer()

                Text("添加预约疫苗")
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

    private var vaccineList: some View {
        VStack(spacing: 10) {
            ForEach(store.addPageVaccines(), id: \.self) { vaccine in
                AddVaccineRow(
                    vaccineName: vaccine,
                    added: store.isVaccineVisible(vaccine),
                    onHelp: {
                        store.openVaccineDetail(vaccine)
                    },
                    onAdd: {
                        store.addOrRestoreVaccine(vaccine)
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .frame(maxWidth: GCLayout.maxDesignWidth)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .offset(y: -60)
    }
}

private struct AddVaccineRow: View {
    let vaccineName: String
    let added: Bool
    let onHelp: () -> Void
    let onAdd: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            HStack(spacing: 10) {
                Image("zhentou")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)

                Text(vaccineName)
                    .font(.system(size: 18))
                    .foregroundColor(.black)
                    .lineLimit(1)

                Button(action: onHelp) {
                    Image("kepuwenhao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("\(vaccineName)详情")
            }

            Spacer(minLength: 12)

            Button(action: onAdd) {
                ZStack {
                    Circle()
                        .fill(Color(hex: 0xE0EBD8))
                        .frame(width: 44, height: 44)

                    if added {
                        Text("✓")
                            .font(.system(size: 18))
                            .foregroundColor(GCColor.textSecondary)
                    } else {
                        AddVaccineRowPlusIcon()
                    }
                }
            }
            .buttonStyle(.plain)
            .disabled(added)
            .accessibilityLabel(added ? "已添加\(vaccineName)" : "添加\(vaccineName)")
        }
        .padding(.leading, 23)
        .padding(.trailing, 10)
        .frame(height: 60)
        .background(Color.white)
        .clipShape(Capsule())
        .opacity(added ? 0.55 : 1)
    }
}

private struct AddVaccineRowPlusIcon: View {
    var body: some View {
        ZStack {
            Capsule()
                .fill(Color.black)
                .frame(width: 20, height: 1.8)

            Capsule()
                .fill(Color.black)
                .frame(width: 1.8, height: 20)
        }
        .frame(width: 20, height: 20)
    }
}

struct AddVaccineView_Previews: PreviewProvider {
    static var previews: some View {
        AddVaccineView()
            .environmentObject(GrowthCareStore())
    }
}
