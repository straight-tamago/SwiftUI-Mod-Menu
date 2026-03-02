import SwiftUI

public enum WKTextTone {
    case primary
    case secondary
    case title
}

/// Theme-aware text component for WindowKit.
/// WindowKit 用のテーマ連動テキストコンポーネントです。
public struct WKText: View {
    private let content: String
    private let tone: WKTextTone
    private let customColor: Color?
    private let customFontName: String?
    private let size: CGFloat
    private let weight: Font.Weight
    private let design: Font.Design
    @Environment(\.wkTheme) private var wkTheme
    @Environment(\.wkFontName) private var wkFontName

    public init(
        _ content: String,
        tone: WKTextTone = .primary,
        color: Color? = nil,
        fontName: String? = nil,
        size: CGFloat = 14,
        weight: Font.Weight = .regular,
        design: Font.Design = .default
    ) {
        self.content = content
        self.tone = tone
        self.customColor = color
        self.customFontName = fontName
        self.size = size
        self.weight = weight
        self.design = design
    }

    public var body: some View {
        Text(content)
            .font(resolvedFont)
            .foregroundColor(customColor ?? resolvedColor)
    }

    private var resolvedColor: Color {
        let p = wkTheme.palette
        switch tone {
        case .primary: return p.primaryText
        case .secondary: return p.secondaryText
        case .title: return p.titleText
        }
    }

    private var resolvedFont: Font {
        if let name = customFontName ?? wkFontName {
            return .custom(name, size: size)
        }
        return .system(size: size, weight: weight, design: design)
    }
}
