import SwiftUI

/// Bottom-right resize grip for floating windows.
/// フローティングウィンドウ右下のリサイズグリップ。
struct ResizeHandle: View {
    var body: some View {
        ZStack {
            Color.clear
            GripShape()
                .stroke(Color.white.opacity(0.45), lineWidth: 1.5)
                .frame(width: 28, height: 28)
        }
        .contentShape(Rectangle())
    }
}

private struct GripShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let s: CGFloat = 28
        for i in 0..<3 {
            let off: CGFloat = 7 + CGFloat(i) * 6
            p.move(to: CGPoint(x: s - off, y: s - 3))
            p.addLine(to: CGPoint(x: s - 3, y: s - off))
        }
        return p
    }
}
