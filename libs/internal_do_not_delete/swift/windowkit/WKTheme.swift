import SwiftUI

public enum WKTheme: String, CaseIterable, Hashable {
    case dark
    case pastel
    case aqua

    public var label: String {
        switch self {
        case .dark: return "Dark"
        case .pastel: return "Pastel"
        case .aqua: return "Aqua"
        }
    }

    public var palette: WKThemePalette {
        switch self {
        case .dark: return .dark
        case .pastel: return .pastel
        case .aqua: return .aqua
        }
    }
}

public struct WKThemePalette {
    public let windowBg: Color
    public let windowBgTransparent: Color
    public let titleBarBg: Color
    public let titleBarBgTransparent: Color
    public let titleText: Color
    public let titleBtnNormal: Color
    public let titleBtnActive: Color
    public let primaryText: Color
    public let secondaryText: Color
    public let divider: Color
    public let shadow: Color
    public let inputBg: Color
    public let overlayBg: Color
    public let toggleOn: Color
    public let toggleOff: Color
    public let toggleKnob: Color
    public let settingsButtonFill: Color

    public static let dark = WKThemePalette(
        windowBg: Color(UIColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 0.98)),
        windowBgTransparent: Color(UIColor(red: 0.12, green: 0.12, blue: 0.16, alpha: 0.10)),
        titleBarBg: Color.black.opacity(0.12),
        titleBarBgTransparent: Color.black.opacity(0.08),
        titleText: .white,
        titleBtnNormal: Color.white.opacity(0.45),
        titleBtnActive: Color.white.opacity(0.85),
        primaryText: .white,
        secondaryText: Color.white.opacity(0.55),
        divider: Color.white.opacity(0.12),
        shadow: Color.black.opacity(0.35),
        inputBg: Color.white.opacity(0.08),
        overlayBg: Color.black.opacity(0.65),
        toggleOn: .green,
        toggleOff: Color.white.opacity(0.16),
        toggleKnob: .white,
        settingsButtonFill: Color(red: 0.2, green: 0.4, blue: 0.8, opacity: 0.9)
    )

    public static let pastel = WKThemePalette(
        windowBg: Color(UIColor(red: 1.00, green: 0.94, blue: 0.96, alpha: 0.98)),
        windowBgTransparent: Color(UIColor(red: 1.00, green: 0.94, blue: 0.96, alpha: 0.35)),
        titleBarBg: Color(red: 0.96, green: 0.82, blue: 0.87),
        titleBarBgTransparent: Color(red: 0.96, green: 0.82, blue: 0.87).opacity(0.6),
        titleText: Color(red: 0.55, green: 0.20, blue: 0.35),
        titleBtnNormal: Color(red: 0.75, green: 0.45, blue: 0.55),
        titleBtnActive: Color(red: 0.85, green: 0.25, blue: 0.45),
        primaryText: Color(red: 0.40, green: 0.18, blue: 0.28),
        secondaryText: Color(red: 0.60, green: 0.40, blue: 0.50),
        divider: Color(red: 0.90, green: 0.80, blue: 0.86),
        shadow: Color(red: 0.85, green: 0.55, blue: 0.70).opacity(0.20),
        inputBg: Color(red: 1.0, green: 0.96, blue: 0.97),
        overlayBg: Color(red: 0.90, green: 0.70, blue: 0.78).opacity(0.55),
        toggleOn: Color(red: 0.95, green: 0.55, blue: 0.65),
        toggleOff: Color(red: 0.94, green: 0.88, blue: 0.90),
        toggleKnob: .white,
        settingsButtonFill: Color(red: 0.92, green: 0.55, blue: 0.68, opacity: 0.9)
    )

    public static let aqua = WKThemePalette(
        windowBg: Color(UIColor(red: 0.94, green: 0.97, blue: 1.00, alpha: 0.98)),
        windowBgTransparent: Color(UIColor(red: 0.94, green: 0.97, blue: 1.00, alpha: 0.35)),
        titleBarBg: Color(red: 0.82, green: 0.90, blue: 0.96),
        titleBarBgTransparent: Color(red: 0.82, green: 0.90, blue: 0.96).opacity(0.6),
        titleText: Color(red: 0.15, green: 0.35, blue: 0.55),
        titleBtnNormal: Color(red: 0.40, green: 0.58, blue: 0.75),
        titleBtnActive: Color(red: 0.20, green: 0.50, blue: 0.85),
        primaryText: Color(red: 0.18, green: 0.28, blue: 0.40),
        secondaryText: Color(red: 0.38, green: 0.50, blue: 0.62),
        divider: Color(red: 0.82, green: 0.90, blue: 0.95),
        shadow: Color(red: 0.50, green: 0.65, blue: 0.80).opacity(0.20),
        inputBg: Color(red: 0.96, green: 0.98, blue: 1.0),
        overlayBg: Color(red: 0.65, green: 0.78, blue: 0.90).opacity(0.55),
        toggleOn: Color(red: 0.40, green: 0.75, blue: 0.88),
        toggleOff: Color(red: 0.88, green: 0.92, blue: 0.95),
        toggleKnob: .white,
        settingsButtonFill: Color(red: 0.45, green: 0.70, blue: 0.90, opacity: 0.9)
    )
}

private struct WKThemeKey: EnvironmentKey {
    static let defaultValue: WKTheme = .dark
}

private struct WKThemeBindingKey: EnvironmentKey {
    static let defaultValue: Binding<WKTheme>? = nil
}

private struct WKFontNameKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

public extension EnvironmentValues {
    var wkTheme: WKTheme {
        get { self[WKThemeKey.self] }
        set { self[WKThemeKey.self] = newValue }
    }

    var wkThemeBinding: Binding<WKTheme>? {
        get { self[WKThemeBindingKey.self] }
        set { self[WKThemeBindingKey.self] = newValue }
    }

    var wkFontName: String? {
        get { self[WKFontNameKey.self] }
        set { self[WKFontNameKey.self] = newValue }
    }
}
