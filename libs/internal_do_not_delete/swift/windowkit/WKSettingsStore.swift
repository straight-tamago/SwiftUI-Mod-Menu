import Foundation

/// Shared settings storage for WindowKit controls.
/// WindowKit コントロール共通の設定ストレージです。
/// Values are saved to one plist for Swift and C/ObjC access.
/// 値は単一plistに保存され、Swift/C/ObjC から参照できます。
public enum WKSettingsStore {
    private static let fileName = "wk_settings.plist"

    private static var path: String {
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        return (dir as NSString).appendingPathComponent(fileName)
    }

    private static func loadAll() -> [String: Any] {
        guard FileManager.default.fileExists(atPath: path),
              let dict = NSDictionary(contentsOfFile: path) as? [String: Any] else {
            return [:]
        }
        return dict
    }

    private static func saveAll(_ dict: [String: Any]) {
        (dict as NSDictionary).write(toFile: path, atomically: true)
    }

    public static func saveBool(_ value: Bool, forKey key: String) {
        var dict = loadAll()
        dict[key] = value
        saveAll(dict)
    }

    public static func loadBool(forKey key: String, default defaultValue: Bool) -> Bool {
        let dict = loadAll()
        return (dict[key] as? Bool) ?? defaultValue
    }

    public static func saveString(_ value: String, forKey key: String) {
        var dict = loadAll()
        dict[key] = value
        saveAll(dict)
    }

    public static func loadString(forKey key: String, default defaultValue: String) -> String {
        let dict = loadAll()
        return (dict[key] as? String) ?? defaultValue
    }
}
