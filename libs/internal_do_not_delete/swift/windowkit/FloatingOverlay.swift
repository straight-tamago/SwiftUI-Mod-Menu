import SwiftUI

/// Lightweight draggable overlay view.
/// 軽量でドラッグ移動できるオーバーレイ。
/// The passed `content` is rendered as-is.
/// 渡した `content` をそのまま描画します。
///
/// ```swift
/// FloatingOverlay {
///     VStack(alignment: .leading) {
///         Text("FPS: 60")
///         Text("Ping: 18ms")
///     }
/// }
/// ```
public struct FloatingOverlay<Content: View>: View {
    private let persistKey: String?
    private let defaultPosition: CGPoint
    private let content: Content

    @State private var position: CGPoint = .zero
    @Environment(\.wkTheme) private var wkTheme
    @GestureState private var dragOffset: CGSize = .zero

    public init(
        persistKey: String? = nil,
        defaultPosition: CGPoint = CGPoint(x: 120, y: 120),
        @ViewBuilder content: () -> Content
    ) {
        self.persistKey = persistKey
        self.defaultPosition = defaultPosition
        self.content = content()
    }

    private var screen: CGSize { UIScreen.main.bounds.size }

    public var body: some View {
        content
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(wkTheme.palette.overlayBg)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .shadow(color: wkTheme.palette.shadow.opacity(0.7), radius: 8, x: 0, y: 4)
            .position(
                x: position.x + dragOffset.width,
                y: position.y + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .updating($dragOffset) { value, state, _ in
                        state = value.translation
                    }
                    .onEnded { value in
                        position.x += value.translation.width
                        position.y += value.translation.height
                        clampPosition()
                        savePosition()
                    }
            )
            .onAppear {
                loadPosition()
            }
    }

    private func loadPosition() {
        if let key = persistKey, let saved = WKPersistence.loadPoint(forKey: key) {
            position = saved
        } else {
            position = defaultPosition
        }
        clampPosition()
    }

    private func savePosition() {
        guard let key = persistKey else { return }
        WKPersistence.savePoint(position, forKey: key)
    }

    private func clampPosition() {
        let minX: CGFloat = 40
        let minY: CGFloat = 30
        let maxX = screen.width - 40
        let maxY = screen.height - 30
        position.x = min(max(position.x, minX), maxX)
        position.y = min(max(position.y, minY), maxY)
    }
}
