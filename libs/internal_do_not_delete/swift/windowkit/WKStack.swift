import SwiftUI

/// Root container for WindowKit content.
/// WindowKit コンテンツのルートコンテナです。
/// Handles transparent background, theme injection, and full-screen layout.
/// 透過背景、テーマ注入、全画面レイアウトを内部で処理します。
public struct WKRoot<Content: View>: View {
    private let externalTheme: Binding<WKTheme>?
    private let fontName: String?
    private let contentBuilder: (WKTheme) -> Content
    @State private var internalTheme: WKTheme

    public init(
        theme: Binding<WKTheme>? = nil,
        initialTheme: WKTheme = .dark,
        fontName: String? = nil,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.externalTheme = theme
        self.fontName = fontName
        self.contentBuilder = { _ in content() }
        self._internalTheme = State(initialValue: theme?.wrappedValue ?? initialTheme)
    }

    public init(
        theme: Binding<WKTheme>? = nil,
        initialTheme: WKTheme = .dark,
        fontName: String? = nil,
        @ViewBuilder content: @escaping (WKTheme) -> Content
    ) {
        self.externalTheme = theme
        self.fontName = fontName
        self.contentBuilder = content
        self._internalTheme = State(initialValue: theme?.wrappedValue ?? initialTheme)
    }

    public var body: some View {
        let themeBinding = externalTheme ?? $internalTheme
        let currentTheme = themeBinding.wrappedValue
        ZStack(alignment: .topLeading) {
            Color.clear.allowsHitTesting(false)
            contentBuilder(currentTheme)
        }
        .environment(\.wkTheme, currentTheme)
        .environment(\.wkThemeBinding, themeBinding)
        .environment(\.wkFontName, fontName)
        .ignoresSafeArea()
    }
}

public typealias WKStack<Content: View> = WKRoot<Content>
