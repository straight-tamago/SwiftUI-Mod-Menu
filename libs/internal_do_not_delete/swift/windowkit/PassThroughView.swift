import UIKit

/// UIView container that forwards touches through transparent areas.
/// 透過領域のタッチを下層へ通す UIView コンテナ。
///
/// Mount `UIHostingController.view` on this view.
/// UIHostingController.view をこの View 上に配置して利用します。
/// Only panel area is hit-testable; other areas return `nil`.
/// パネル領域のみヒットテスト対象で、それ以外は `nil` を返します。
public class PassThroughView: UIView {
    public weak var hostedView: UIView?
    public weak var panelView: UIView?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let panel = panelView {
            let pInPanel = convert(point, to: panel)
            if panel.bounds.contains(pInPanel) {
                return panel.hitTest(pInPanel, with: event)
            }
            return nil
        }
        guard let hosted = hostedView else { return nil }
        let pInHosted = convert(point, to: hosted)
        guard hosted.bounds.contains(pInHosted) else { return nil }
        let a = alphaAt(pInHosted, in: hosted)
        guard a > 0.01 else { return nil }
        return hosted.hitTest(pInHosted, with: event)
    }

    private func alphaAt(_ point: CGPoint, in view: UIView) -> CGFloat {
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, scale)
        defer { UIGraphicsEndImageContext() }
        guard let ctx = UIGraphicsGetCurrentContext() else { return 0 }
        ctx.translateBy(x: -point.x, y: -point.y)
        view.layer.render(in: ctx)
        guard let img = UIGraphicsGetImageFromCurrentImageContext()?.cgImage,
              let data = img.dataProvider?.data,
              let ptr = CFDataGetBytePtr(data) else { return 0 }
        return CGFloat(ptr[3]) / 255.0
    }
}
