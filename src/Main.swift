import SwiftUI

struct Main: View {
    @State private var showWindow = true
    @State private var showDemoWindow = false

    @State private var modEnabled = true
    @State private var sensitivity: Double = 0.55
    @State private var playerTag = "Player01"
    @State private var maxTargets = 3
    @State private var targetPart = "Body"
    
    private var sensitivityPercent: Int {
        Int((sensitivity * 100).rounded())
    }

    var body: some View {
        WKRoot(fontName: "Menlo-Regular") {
            theme in
            let p = theme.palette

            WKFloatingButton(persistKey: "toggle_position", onTap: {
                withAnimation(.easeOut(duration: 0.2)) { showWindow.toggle() }
            }) {
                ZStack {
                    Circle()
                        .fill(p.settingsButtonFill)
                    Text("W")
                        .font(.system(size: 22, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
            }

            if showWindow {
                WKFloatingWindow(
                    title: "WindowKit Panel / パネル",
                    isPresented: $showWindow,
                    persistKey: "panel_window",
                    minSize: CGSize(width: 300, height: 320),
                    defaultSize: CGSize(width: 360, height: 520)
                ) {
                    ScrollView(showsIndicators: false) {
                        SettingsPanel(
                            modEnabled: $modEnabled,
                            sensitivity: $sensitivity,
                            playerTag: $playerTag,
                            maxTargets: $maxTargets,
                            targetPart: $targetPart,
                            showDemoWindow: $showDemoWindow
                        )
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                    }
                }
            }
            
            if showDemoWindow {
                WKFloatingWindow(
                    title: "Demo Window / デモ",
                    isPresented: $showDemoWindow,
                    persistKey: "demo_window",
                    minSize: CGSize(width: 220, height: 120),
                    defaultSize: CGSize(width: 280, height: 160)
                ) {
                    VStack(alignment: .leading, spacing: 6) {
                        WKText("This is a secondary window demo.", tone: .primary, size: 14)
                    }
                    .padding(12)
                }
            }

            WKFloatingOverlay(persistKey: "info_overlay", defaultPosition: CGPoint(x: 120, y: 70)) {
                VStack(alignment: .leading, spacing: 3) {
                    WKText("FloatingOverlay { ... }", color: .white, size: 12, weight: .semibold, design: .monospaced)
                    WKText("Mod: \(modEnabled ? "ON" : "OFF") / Sens: \(sensitivityPercent)%", color: .white.opacity(0.85), size: 11, design: .monospaced)
                    WKText("Tag: \(playerTag) / Part: \(targetPart)", color: .white.opacity(0.85), size: 11, design: .monospaced)
                    WKText("Theme / テーマ: \(theme.label)", color: .white.opacity(0.85), size: 11, design: .monospaced)
                }
            }
        }
    }
}

private struct SettingsPanel: View {
    @Binding var modEnabled: Bool
    @Binding var sensitivity: Double
    @Binding var playerTag: String
    @Binding var maxTargets: Int
    @Binding var targetPart: String
    @Binding var showDemoWindow: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Group {
                WKSectionHeader(title: "Theme / テーマ")
                WKSegmentPicker(
                    items: WKTheme.allCases.map { $0.label },
                    persist: true,
                    persistKey: "wk_theme"
                )

                WKSectionHeader(title: "Settings / 設定", color: .blue)
                WKToggleRow(
                    label: "Enable Mod / Mod有効",
                    isOn: $modEnabled,
                    persist: true,
                    persistKey: "toggle_mod_enabled"
                )

                WKSliderRow(
                    label: "Aim Sensitivity / エイム感度",
                    value: $sensitivity,
                    in: 0.10...1.00,
                    step: 0.05,
                    formatter: { "\(Int(($0 * 100).rounded()))%" }
                )
            }

            Group {
                WKSectionHeader(title: "Identity / 識別", color: .purple)
                WKTextFieldRow(
                    label: "Player Tag / プレイヤー名",
                    placeholder: "Player01",
                    text: $playerTag
                )

                WKSectionHeader(title: "Targeting / ターゲット", color: .orange)
                WKStepperRow(
                    label: "Max Targets / 最大対象数",
                    value: $maxTargets,
                    in: 1...10
                )

                WKMenuPickerRow(
                    label: "Target Part / 対象部位",
                    options: ["Body", "Head", "Nearest"],
                    selection: $targetPart
                )

                WKSectionHeader(title: "Action / 実行", color: .pink)
                WKActionButton(title: "Open Demo Window / 別ウィンドウを開く") {
                    withAnimation(.easeOut(duration: 0.2)) {
                        showDemoWindow = true
                    }
                }
                WKActionButton(title: "Apply / 適用") {
                    SwiftToC(Int32(maxTargets * 25))
                }
            }
        }
    }
}
