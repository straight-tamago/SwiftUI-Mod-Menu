# SwiftUI Mod Menu

This project is a template for rendering a **SwiftUI-based floating UI** on top of an iOS app.  
It requires either a **jailbroken environment** or **LiveContainer**.  
It provides draggable floating buttons/windows/overlays and settings UI components.

---

## Screenshots

![Dark (default)](img/IMG_1336.PNG)
![pink](img/IMG_1335.PNG)
![aqua](img/IMG_1337.PNG)
---

## Features

- Floating UI primitives (`WKFloatingButton`, `WKFloatingWindow`, `WKFloatingOverlay`)
- 3 built-in themes (`Dark`, `Pink`, `Aqua`)
- Persistent control values (`WKSettingsStore` + each control's `persist`)
- Persistent position/size (`persistKey` + `WKPersistence`)
- SwiftUI + Theos (rootless) setup

---

## Quick Start

```swift
import SwiftUI

struct Main: View {
    @State private var showWindow = true
    @State private var speedMode = "Normal"

    var body: some View {
        WKRoot(fontName: "Menlo-Regular") {
            WKFloatingButton(persistKey: "btn_pos", onTap: { showWindow.toggle() }) {
                Circle().fill(.blue).overlay(Text("W").foregroundColor(.white))
            }

            if showWindow {
                WKFloatingWindow(
                    title: "WindowKit",
                    isPresented: $showWindow,
                    persistKey: "main_window"
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        WKSectionHeader(title: "Mode")
                        WKSegmentPicker(
                            items: ["Low", "Normal", "High"],
                            selection: $speedMode,
                            persist: true,
                            persistKey: "speed_mode"
                        )
                    }
                    .padding(12)
                }
            }
        }
    }
}
```

---

## Components (Full List)

### Root / Theme

- `WKRoot`
  - `init(theme: Binding<WKTheme>? = nil, initialTheme: WKTheme = .dark, fontName: String? = nil, content: () -> Content)`
  - `init(theme: Binding<WKTheme>? = nil, initialTheme: WKTheme = .dark, fontName: String? = nil, content: (WKTheme) -> Content)`
  - `theme`: externally controlled theme binding
  - `initialTheme`: fallback initial theme when no external binding is provided
  - `fontName`: font name injected into `WKText`

- `WKTheme`
  - `dark`, `pink`, `aqua`
  - exposes `label` and `palette`

- `WKThemePalette`
  - color set for window/title/text/toggle/input backgrounds and more

### Floating UI

- `WKFloatingButton`
  - `init(size: CGFloat = 50, persistKey: String? = nil, defaultPosition: CGPoint? = nil, onTap: @escaping () -> Void, label: () -> Label)`
  - `size`: tappable size
  - `persistKey`: persistence key for button position
  - `defaultPosition`: initial position when no saved data exists
  - `onTap`: tap callback

- `WKFloatingWindow`
  - `init(title: String, isPresented: Binding<Bool>, persistKey: String? = nil, minSize: CGSize = (200,200), defaultSize: CGSize = (400,400), style: FloatingWindowStyle? = nil, actions: () -> Actions, content: () -> Content)`
  - `init(title: String, isPresented: Binding<Bool>, persistKey: String? = nil, minSize: CGSize = (200,200), defaultSize: CGSize = (400,400), style: FloatingWindowStyle? = nil, content: () -> Content)` (without actions)
  - `title`: title bar text
  - `isPresented`: show/hide state
  - `persistKey`: persistence key for window position and size
  - `minSize`, `defaultSize`: min/default size
  - `style`: optional custom `FloatingWindowStyle`
  - `actions`: custom controls shown on the right side of title bar

- `WKFloatingOverlay`
  - `init(persistKey: String? = nil, defaultPosition: CGPoint = CGPoint(x: 120, y: 120), content: () -> Content)`
  - `persistKey`: persistence key for overlay position
  - `defaultPosition`: initial position

### Text / Settings Controls

- `WKText`
  - `init(_ content: String, tone: WKTextTone = .primary, color: Color? = nil, fontName: String? = nil, size: CGFloat = 14, weight: Font.Weight = .regular, design: Font.Design = .default)`
  - `tone`: `.primary / .secondary / .title`

- `WKSectionHeader`
  - `init(title: String, color: Color? = nil)`

- `WKToggleRow`
  - `init(label: String, isOn: Binding<Bool>, persist: Bool = false, persistKey: String? = nil, onChanged: ((Bool) -> Void)? = nil)`

- `WKSegmentPicker` (3 variants)
  - `init(items: [String], selection: Binding<String>, persist: Bool = false, persistKey: String? = nil)`
  - `init(items: [String], persist: Bool = false, persistKey: String? = nil)` (theme-picker usage)
  - `init(items: [String], selection: Binding<WKTheme>, persist: Bool = false, persistKey: String? = nil)`

- `WKSliderRow`
  - `init(label: String, value: Binding<Double>, in range: ClosedRange<Double>, step: Double = 1, formatter: ((Double) -> String)? = nil)`

- `WKTextFieldRow`
  - `init(label: String, placeholder: String, text: Binding<String>)`

- `WKStepperRow`
  - `init(label: String, value: Binding<Int>, in range: ClosedRange<Int>)`

- `WKMenuPickerRow`
  - `init(label: String, options: [String], selection: Binding<String>)`

- `WKActionButton`
  - `init(title: String, action: @escaping () -> Void)`

### Persistence

- `WKSettingsStore` (control values)
  - `saveBool(_:forKey:)`, `loadBool(forKey:default:)`
  - `saveString(_:forKey:)`, `loadString(forKey:default:)`
  - file: `Documents/wk_settings.plist`

- `WKPersistence` (position/size)
  - `savePoint(_:forKey:)`, `loadPoint(forKey:)`
  - `saveSize(_:forKey:)`, `loadSize(forKey:)`
  - files: `Documents/wk_<key>.plist`

---

## Full Example (Using Main Parts)

```swift
import SwiftUI

struct Main: View {
    @State private var showMain = true
    @State private var showDemo = false

    @State private var modEnabled = true
    @State private var sensitivity = 0.55
    @State private var profile = "Balanced"
    @State private var playerTag = "Player01"
    @State private var maxTargets = 3
    @State private var targetPart = "Body"

    var body: some View {
        WKRoot(fontName: "Menlo-Regular") { theme in
            WKFloatingButton(persistKey: "btn_pos", onTap: { showMain.toggle() }) {
                Circle().fill(theme.palette.settingsButtonFill)
                    .overlay(Text("W").foregroundColor(.white))
            }

            if showMain {
                WKFloatingWindow(
                    title: "WindowKit Panel",
                    isPresented: $showMain,
                    persistKey: "panel_window",
                    minSize: CGSize(width: 300, height: 320),
                    defaultSize: CGSize(width: 360, height: 520)
                ) {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 8) {
                            WKSectionHeader(title: "Theme")
                            WKSegmentPicker(items: WKTheme.allCases.map { $0.label }, persist: true, persistKey: "wk_theme")

                            WKSectionHeader(title: "Settings", color: .blue)
                            WKToggleRow(label: "Enable Mod", isOn: $modEnabled, persist: true, persistKey: "toggle_mod_enabled")
                            WKSegmentPicker(items: ["Safe", "Balanced", "Aggressive"], selection: $profile, persist: true, persistKey: "profile_mode")
                            WKSliderRow(label: "Aim Sensitivity", value: $sensitivity, in: 0.10...1.00, step: 0.05) { "\(Int(($0 * 100).rounded()))%" }

                            WKSectionHeader(title: "Identity", color: .purple)
                            WKTextFieldRow(label: "Player Tag", placeholder: "Player01", text: $playerTag)

                            WKSectionHeader(title: "Targeting", color: .orange)
                            WKStepperRow(label: "Max Targets", value: $maxTargets, in: 1...10)
                            WKMenuPickerRow(label: "Target Part", options: ["Body", "Head", "Nearest"], selection: $targetPart)

                            WKSectionHeader(title: "Action", color: .pink)
                            WKActionButton(title: "Open Demo Window") { showDemo = true }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                }
            }

            if showDemo {
                WKFloatingWindow(title: "Demo", isPresented: $showDemo, persistKey: "demo_window") {
                    WKText("This is a secondary window demo.", tone: .primary, size: 14)
                        .padding(12)
                }
            }

            WKFloatingOverlay(persistKey: "info_overlay", defaultPosition: CGPoint(x: 120, y: 70)) {
                VStack(alignment: .leading, spacing: 3) {
                    WKText("FloatingOverlay { ... }", color: .white, size: 12, weight: .semibold, design: .monospaced)
                    WKText("Theme: \(theme.label)", color: .white.opacity(0.85), size: 11, design: .monospaced)
                }
            }
        }
    }
}
```

---

## Swift <-> C Interop

- Swift -> C
  - Declare C functions in `SwiftUI_Mod_Menu-Bridging-Header.h`
  - Example: `void SwiftToC(int value);`
- C/ObjC -> Swift
  - Use `@_cdecl("SymbolName")` when needed
  - Or call through an ObjC-visible class such as `Loader.setup()`

---

## Build

```bash
make clean && make package
```

After `make package`, `after-package` in the Makefile automatically extracts `.dylib` from the generated `.deb`.

---

## Credits

- Dobby: jmpews (`Apache-2.0`)
  - https://github.com/jmpews/Dobby

- HuyJIT-ModMenu: Huy Nguyen (34306) (`MIT`)
  - https://github.com/34306/HuyJIT-ModMenu

---

## Contributing

Contributions are very welcome.  
Feel free to open an issue, submit a pull request, or share improvement ideas.

