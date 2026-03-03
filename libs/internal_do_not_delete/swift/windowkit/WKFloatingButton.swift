import SwiftUI

/// Draggable floating button.
/// ドラッグ移動できるフローティングボタン。
///
/// ```swift
/// WKFloatingButton(persistKey: "my_btn", onTap: { show = true }) {
///     Text("⚙️")
///         .font(.system(size: 24))
///         .background(Color.blue.opacity(0.9))
///         .clipShape(Circle())
/// }
/// ```
///
/// - `persistKey`: position save/load key in `WKPersistence`
/// - `size`: tappable size (default: 50)
/// - `defaultPosition`: initial position when no saved value exists
/// - `persistKey`: `WKPersistence` に保存するキー
/// - `size`: タップ領域サイズ（既定値: 50）
/// - `defaultPosition`: 保存値がない場合の初期位置
public struct WKFloatingButton<Label: View>: View {
    let onTap: () -> Void
    let size: CGFloat
    let persistKey: String?
    let defaultPosition: CGPoint?
    let label: Label

    @State private var posX: CGFloat = 0
    @State private var posY: CGFloat = 0
    @GestureState private var dragOffset: CGSize = .zero

    public init(
        size: CGFloat = 50,
        persistKey: String? = nil,
        defaultPosition: CGPoint? = nil,
        onTap: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.size = size
        self.persistKey = persistKey
        self.defaultPosition = defaultPosition
        self.onTap = onTap
        self.label = label()
    }

    private var screen: CGSize { UIScreen.main.bounds.size }
    private func clampX(_ x: CGFloat) -> CGFloat { min(screen.width - size, max(0, x)) }
    private func clampY(_ y: CGFloat) -> CGFloat { min(screen.height - size, max(0, y)) }

    public var body: some View {
        let safeX = clampX(posX + dragOffset.width)
        let safeY = clampY(posY + dragOffset.height)

        label
            .frame(width: size, height: size)
            .contentShape(Rectangle())
            .position(x: safeX + size / 2, y: safeY + size / 2)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($dragOffset) { v, s, _ in s = v.translation }
                    .onEnded { v in
                        if abs(v.translation.width) < 5, abs(v.translation.height) < 5 {
                            onTap()
                        } else {
                            posX = clampX(posX + v.translation.width)
                            posY = clampY(posY + v.translation.height)
                            if let key = persistKey {
                                WKPersistence.savePoint(CGPoint(x: posX, y: posY), forKey: key)
                            }
                        }
                    }
            )
            .onAppear {
                if let key = persistKey, let p = WKPersistence.loadPoint(forKey: key) {
                    posX = clampX(p.x)
                    posY = clampY(p.y)
                } else {
                    let def = defaultPosition ?? CGPoint(x: screen.width - size - 8, y: 100)
                    posX = clampX(def.x)
                    posY = clampY(def.y)
                }
            }
    }
}
