import SwiftUI
import UIKit

enum GCColor {
    static let page = Color(hex: 0xF9F4F2)
    static let headerTop = Color(hex: 0xFD898A)
    static let headerBottom = Color(hex: 0xFD9999)
    static let pinkPrimary = Color(hex: 0xD89698)
    static let pinkAccent = Color(hex: 0xEC7B75)
    static let pinkMuted = Color(hex: 0xE8C0B7)
    static let navBackground = Color(hex: 0xFEE0D8)
    static let textPrimary = Color.black
    static let textSecondary = Color(hex: 0x464646)
    static let textMuted = Color(hex: 0x707A87)
    static let cardMuted = Color(hex: 0xFAFAFA)
    static let progressLine = Color(hex: 0xD9D9D9)
    static let cancelButton = Color(hex: 0xC5C5C5)
}

enum GCLayout {
    static let maxDesignWidth: CGFloat = 440
    static let minComfortableWidth: CGFloat = 320
    static let homeNoAppointmentTopBandHeight: CGFloat = 140
    static let topBandHeight: CGFloat = homeNoAppointmentTopBandHeight
    static let homeAppointmentTopBandHeight: CGFloat = 205
    static let homeAppointmentCardTopY: CGFloat = 149
    static let homeNoAppointmentVaccineGap: CGFloat = 34
    static let homeAppointmentVaccineGap: CGFloat = 45
    static let vaccineTimelineRowVerticalPadding: CGFloat = 7
    static let profileTopBandHeight: CGFloat = 205
    static let growthTopBandHeight: CGFloat = 205
    static let growthRecordsTopBandHeight: CGFloat = 205
    static let formTopBandHeight: CGFloat = 140
    static let topSwitcherY: CGFloat = 76
    static let profileCardTopY: CGFloat = 100
    static let profileFirstSectionTopY: CGFloat = 269
    static let bottomTabBarHeight: CGFloat = 68
    static let tabBarMinimumBottomInset: CGFloat = 0
    static let bottomTabBarTopPadding: CGFloat = 16
    static let bottomTabLabelTop: CGFloat = 38.67
    static let bottomTabItemWidth: CGFloat = 50
    static let bottomTabIconSize: CGFloat = 42
    static let childSwitcherHeight: CGFloat = 44
    static let profileAddIconSize: CGFloat = 20
    static let growthSegmentHeight: CGFloat = 40
    static let growthSegmentButtonHeight: CGFloat = 31
    static let growthSegmentBottomPadding: CGFloat = 20

    static func contentWidth(for availableWidth: CGFloat) -> CGFloat {
        min(max(0, availableWidth), maxDesignWidth)
    }

    static func horizontalInset(for availableWidth: CGFloat, ideal: CGFloat = 20) -> CGFloat {
        min(ideal, max(12, availableWidth * 0.045))
    }

    static func cardWidth(for availableWidth: CGFloat, horizontalInset: CGFloat = 20) -> CGFloat {
        max(0, contentWidth(for: availableWidth) - horizontalInset * 2)
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: alpha
        )
    }
}

extension Date {
    static func gcDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
    }
}

extension View {
    func cardShadow() -> some View {
        shadow(color: Color(hex: 0xE2CAC2).opacity(0.3), radius: 13, x: 0, y: 9)
    }

    func glassCardDepth(cornerRadius: CGFloat = 34) -> some View {
        background(alignment: .bottom) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(Color(hex: 0xE2CAC2).opacity(0.34))
                .frame(height: 86)
                .blur(radius: 26)
                .offset(y: 30)
                .padding(.horizontal, 10)
        }
        .shadow(color: Color(hex: 0xE2CAC2).opacity(0.3), radius: 13, x: 0, y: 9)
    }
}

struct AvatarImage: View {
    let asset: String
    let data: Data?

    var body: some View {
        Group {
            if let data, let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
            } else {
                Image(asset)
                    .resizable()
            }
        }
    }
}

struct ChildAvatarImage: View {
    let child: ChildProfile

    var body: some View {
        AvatarImage(asset: child.avatarAsset, data: child.avatarData)
    }
}

struct BackCircleButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
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
    }
}
