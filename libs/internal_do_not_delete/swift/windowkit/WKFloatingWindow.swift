import SwiftUI

// Environment key for footer visibility.
// フッター表示制御の環境キー。
private struct FooterHiddenKey: EnvironmentKey {
    static let defaultValue: Bool = false
}
extension EnvironmentValues {
    var footerHidden: Bool {
        get { self[FooterHiddenKey.self] }
        set { self[FooterHiddenKey.self] = newValue }
    }
}

public struct FloatingWindowStyle {
    public let backgroundColor: Color
    public let transparentBackgroundColor: Color
    public let titleBarColor: Color
    public let transparentTitleBarColor: Color
    public let titleTextColor: Color
    public let dimTextColor: Color
    public let accentTextColor: Color
    public let dividerColor: Color
    public let shadowColor: Color

    public init(
        backgroundColor: Color,
        transparentBackgroundColor: Color,
        titleBarColor: Color,
        transparentTitleBarColor: Color,
        titleTextColor: Color,
        dimTextColor: Color,
        accentTextColor: Color,
        dividerColor: Color,
        shadowColor: Color
    ) {
        self.backgroundColor = backgroundColor
        self.transparentBackgroundColor = transparentBackgroundColor
        self.titleBarColor = titleBarColor
        self.transparentTitleBarColor = transparentTitleBarColor
        self.titleTextColor = titleTextColor
        self.dimTextColor = dimTextColor
        self.accentTextColor = accentTextColor
        self.dividerColor = dividerColor
        self.shadowColor = shadowColor
    }

    public static let `default` = FloatingWindowStyle(
        backgroundColor: Color.black.opacity(0.82),
        transparentBackgroundColor: Color.black.opacity(0.12),
        titleBarColor: Color.black.opacity(0.32),
        transparentTitleBarColor: Color.black.opacity(0.18),
        titleTextColor: .white,
        dimTextColor: Color.white.opacity(0.7),
        accentTextColor: .white,
        dividerColor: Color.white.opacity(0.14),
        shadowColor: Color.black.opacity(0.35)
    )
}

/// Draggable and resizable floating window.
/// ドラッグ移動・リサイズ対応のフローティングウィンドウ。
///
/// ```swift
/// WKFloatingWindow(title: "Panel", isPresented: $show, persistKey: "panel_window") {
///     ScrollView { Text("Hello") }
/// }
/// ```
///
/// - `persistKey`: save/restore key for position and size
/// - `actions`: custom controls shown on title bar right side
/// - `persistKey`: 位置とサイズの保存/復元キー
/// - `actions`: タイトルバー右側に追加するカスタム操作
public struct WKFloatingWindow<Actions: View, Content: View>: View {
    let title: String
    @Binding var isPresented: Bool
    let persistKey: String?
    let actions: Actions
    let content: Content
    let minSize: CGSize
    let defaultSize: CGSize
    let style: FloatingWindowStyle?

    @State private var windowWidth: CGFloat
    @State private var windowHeight: CGFloat
    @State private var position: CGSize = .zero
    @State private var transparent: Bool = false
    @State private var collapsed: Bool = false
    @State private var footerHidden: Bool = false
    @Environment(\.wkTheme) private var wkTheme
    @GestureState private var dragOffset: CGSize = .zero
    @GestureState private var resizeOffset: CGSize = .zero

    public init(
        title: String,
        isPresented: Binding<Bool>,
        persistKey: String? = nil,
        minSize: CGSize = CGSize(width: 200, height: 200),
        defaultSize: CGSize = CGSize(width: 400, height: 400),
        style: FloatingWindowStyle? = nil,
        @ViewBuilder actions: () -> Actions,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self._isPresented = isPresented
        self.persistKey = persistKey
        self.actions = actions()
        self.content = content()
        self.minSize = minSize
        self.defaultSize = defaultSize
        self.style = style
        self._windowWidth = State(initialValue: defaultSize.width)
        self._windowHeight = State(initialValue: defaultSize.height)
    }

    // MARK: Layout

    private var screen: CGSize { UIScreen.main.bounds.size }

    private var effectiveSize: CGSize {
        let maxW = screen.width - 16
        let maxH = screen.height - 16
        return CGSize(
            width:  min(maxW, max(minSize.width,  windowWidth  + resizeOffset.width)),
            height: min(maxH, max(minSize.height, windowHeight + resizeOffset.height))
        )
    }

    private func clamped(_ proposed: CGSize, for size: CGSize) -> CGSize {
        CGSize(
            width:  min(max(proposed.width,  0), max(0, screen.width  - size.width)),
            height: min(max(proposed.height, 0), max(0, screen.height - size.height))
        )
    }

    private var cornerRadius: CGFloat { 18 }

    private var resolvedStyle: FloatingWindowStyle {
        style ?? wkTheme.palette.floatingWindowStyle
    }

    private var titleBarBackground: Color {
        transparent ? resolvedStyle.transparentTitleBarColor : resolvedStyle.titleBarColor
    }

    private var backgroundColor: Color {
        transparent ? resolvedStyle.transparentBackgroundColor : resolvedStyle.backgroundColor
    }

    private var titleTextColor: Color {
        resolvedStyle.titleTextColor
    }

    private var dimTextColor: Color {
        resolvedStyle.dimTextColor
    }

    private var accentTextColor: Color {
        resolvedStyle.accentTextColor
    }

    private var dividerColor: Color {
        resolvedStyle.dividerColor
    }

    private var shadowColor: Color {
        resolvedStyle.shadowColor.opacity(transparent ? 0.6 : 1.0)
    }

    private var bgColor: Color {
        backgroundColor
    }

    // MARK: Persistence

    private func saveState() {
        guard let key = persistKey else { return }
        WKPersistence.savePoint(CGPoint(x: position.width, y: position.height), forKey: "\(key)_pos")
        WKPersistence.saveSize(CGSize(width: windowWidth, height: windowHeight), forKey: "\(key)_size")
    }

    private func loadState() {
        guard let key = persistKey else { return }
        if let p = WKPersistence.loadPoint(forKey: "\(key)_pos") {
            position = CGSize(width: p.x, height: p.y)
        }
        if let s = WKPersistence.loadSize(forKey: "\(key)_size") {
            let maxW = screen.width - 16
            let maxH = screen.height - 16
            windowWidth  = min(maxW, max(minSize.width,  s.width))
            windowHeight = min(maxH, max(minSize.height, s.height))
        }
        position = clamped(position, for: CGSize(width: windowWidth, height: windowHeight))
    }

    // MARK: Body

    public var body: some View {
        let size = effectiveSize
        let offset = clamped(
            CGSize(width:  position.width  + dragOffset.width,
                   height: position.height + dragOffset.height),
            for: size
        )

        ZStack(alignment: .topLeading) {
            VStack(spacing: 0) {
                titleBar
                    .simultaneousGesture(
                        DragGesture(coordinateSpace: .global)
                            .updating($dragOffset) { v, s, _ in s = v.translation }
                            .onEnded { v in
                                position = clamped(
                                    CGSize(width:  position.width  + v.translation.width,
                                           height: position.height + v.translation.height),
                                    for: size
                                )
                                saveState()
                            }
                    )
                if !collapsed {
                    Divider().background(dividerColor)
                    content
                        .environment(\.footerHidden, footerHidden)
                }
            }
            .frame(width: size.width, height: collapsed ? nil : size.height, alignment: .topLeading)
            .background(bgColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: 20, x: 0, y: 8)
            .offset(x: offset.width, y: offset.height)

            if !collapsed {
                ResizeHandle()
                    .frame(width: 28, height: 28)
                    .offset(x: offset.width + size.width - 28,
                            y: offset.height + size.height - 28)
                    .highPriorityGesture(
                        DragGesture(minimumDistance: 0)
                            .updating($resizeOffset) { v, s, _ in s = v.translation }
                            .onEnded { v in
                                let maxW = screen.width - 16
                                let maxH = screen.height - 16
                                windowWidth  = min(maxW, max(minSize.width,  windowWidth  + v.translation.width))
                                windowHeight = min(maxH, max(minSize.height, windowHeight + v.translation.height))
                                position = clamped(position, for: CGSize(width: windowWidth, height: windowHeight))
                                saveState()
                            }
                    )
            }
        }
        .onAppear { loadState() }
        .transition(.opacity)
    }

    // MARK: Title Bar

    private var titleBar: some View {
        return ZStack {
            Text(title)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(titleTextColor)

            HStack(spacing: 8) {
                actions

                Button(action: { withAnimation(.easeOut(duration: 0.15)) { collapsed.toggle() } }) {
                    Text(collapsed ? "▸" : "▾")
                        .font(.system(size: 14))
                        .foregroundColor(collapsed ? accentTextColor : dimTextColor)
                }.frame(width: 32, height: 32)

                // Button(action: { withAnimation(.easeInOut(duration: 0.25)) { footerHidden.toggle() } }) {
                //     Text("⊥")
                //         .font(.system(size: 14, weight: .bold))
                //         .foregroundColor(footerHidden ? accentTextColor : dimTextColor)
                // }.frame(width: 32, height: 32)

                Button(action: { withAnimation(.easeInOut(duration: 0.25)) { transparent.toggle() } }) {
                    Text("T")
                        .font(.system(size: 14))
                        .foregroundColor(transparent ? accentTextColor : dimTextColor)
                }.frame(width: 32, height: 32)

                Button(action: { withAnimation(.easeOut(duration: 0.2)) { isPresented = false } }) {
                    Text("✕")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(dimTextColor)
                }.frame(width: 32, height: 32)
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.trailing, 10)
        }
        .padding(.vertical, 6)
        .background(titleBarBackground)
    }
}

// MARK: Convenience Init (without actions)

public extension WKFloatingWindow where Actions == EmptyView {
    init(
        title: String,
        isPresented: Binding<Bool>,
        persistKey: String? = nil,
        minSize: CGSize = CGSize(width: 200, height: 200),
        defaultSize: CGSize = CGSize(width: 400, height: 400),
        style: FloatingWindowStyle? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            title: title, isPresented: isPresented,
            persistKey: persistKey,
            minSize: minSize, defaultSize: defaultSize,
            style: style,
            actions: { EmptyView() }, content: content
        )
    }
}

public extension WKThemePalette {
    var floatingWindowStyle: FloatingWindowStyle {
        FloatingWindowStyle(
            backgroundColor: windowBg,
            transparentBackgroundColor: windowBgTransparent,
            titleBarColor: titleBarBg,
            transparentTitleBarColor: titleBarBgTransparent,
            titleTextColor: titleText,
            dimTextColor: titleBtnNormal,
            accentTextColor: titleBtnActive,
            dividerColor: divider,
            shadowColor: shadow
        )
    }
}
