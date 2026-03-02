import Foundation
import UIKit

/// Internal plist persistence utility for WindowKit.
/// WindowKit 用の内部 plist 永続化ユーティリティです。
/// Used by `FloatingButton` and `FloatingWindow` with `persistKey`.
/// `persistKey` を指定した `FloatingButton` / `FloatingWindow` で使用します。
enum WKPersistence {

    // MARK: Internal Helpers / 内部ヘルパー

    private static let dir: String = {
        NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
    }()

    private static func path(_ key: String) -> String {
        (dir as NSString).appendingPathComponent("wk_\(key).plist")
    }

    private static func write(_ key: String, dict: [String: Any]) {
        (dict as NSDictionary).write(toFile: path(key), atomically: true)
    }

    private static func read(_ key: String) -> [String: Any]? {
        let p = path(key)
        guard FileManager.default.fileExists(atPath: p) else { return nil }
        return NSDictionary(contentsOfFile: p) as? [String: Any]
    }

    // MARK: CGPoint

    static func savePoint(_ point: CGPoint, forKey key: String) {
        write(key, dict: ["x": point.x, "y": point.y])
    }

    static func loadPoint(forKey key: String) -> CGPoint? {
        guard let d = read(key),
              let x = d["x"] as? CGFloat,
              let y = d["y"] as? CGFloat else { return nil }
        return CGPoint(x: x, y: y)
    }

    // MARK: CGSize

    static func saveSize(_ size: CGSize, forKey key: String) {
        write(key, dict: ["w": size.width, "h": size.height])
    }

    static func loadSize(forKey key: String) -> CGSize? {
        guard let d = read(key),
              let w = d["w"] as? CGFloat,
              let h = d["h"] as? CGFloat else { return nil }
        return CGSize(width: w, height: h)
    }
}
