import SwiftUI
import UIKit

/// Entry point called from `main.mm` (ObjC-visible).
/// `main.mm` から呼ばれるエントリポイント（ObjC公開）。
@objc(Loader)
public final class Loader: NSObject {

    /// Installs WindowKit root view after app launch.
    /// アプリ起動後に WindowKit ルートViewを設置します。
    @objc public static func setup() {
        installSwiftUIPanel()
    }

    // MARK: View Installation / 画面設置

    private static func installSwiftUIPanel() {
        let vc = makeViewController()

        guard let keyWindow = findKeyWindow() else {
            NSLog("[WindowKit] No window found for SwiftUI FloatingPanel")
            return
        }

        let containerView = vc.view!
        containerView.frame = keyWindow.bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        keyWindow.addSubview(containerView)

        if let root = keyWindow.rootViewController {
            root.addChild(vc)
            vc.didMove(toParent: root)
        }

        NSLog("[WindowKit] SwiftUI FloatingPanel added successfully")
    }

    // MARK: Host Controller Creation / ホストVC作成

    private static func makeViewController() -> UIViewController {
        let hosting = UIHostingController(rootView: Main())
        hosting.view.backgroundColor = .clear
        hosting.view.insetsLayoutMarginsFromSafeArea = false

        let container = UIViewController()
        let pass = PassThroughView(frame: UIScreen.main.bounds)
        pass.backgroundColor = .clear
        container.view = pass

        container.addChild(hosting)
        pass.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: pass.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: pass.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: pass.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: pass.bottomAnchor),
        ])

        pass.hostedView = hosting.view
        hosting.view.layoutIfNeeded()
        if let real = hosting.view.subviews.first {
            pass.panelView = real
        }

        hosting.didMove(toParent: container)
        return container
    }

    // MARK: Key Window Lookup / キーウィンドウ探索

    private static func findKeyWindow() -> UIWindow? {
        for scene in UIApplication.shared.connectedScenes {
            guard let ws = scene as? UIWindowScene else { continue }
            if let kw = ws.windows.first(where: { $0.isKeyWindow }) {
                return kw
            }
            return ws.windows.first
        }
        return nil
    }
}
