import SwiftUI

/// Section header with optional custom color.
/// カスタム色を指定できるセクションヘッダー。
public struct WKSectionHeader: View {
    let title: String
    let color: Color?
    @Environment(\.wkTheme) private var wkTheme

    public init(title: String, color: Color? = nil) {
        self.title = title
        self.color = color
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            WKText(title, color: color ?? wkTheme.palette.titleText, size: 13, weight: .bold)
                .padding(.top, 14)
                .padding(.bottom, 4)
            Rectangle()
                .fill((color ?? wkTheme.palette.divider).opacity(0.3))
                .frame(height: 1)
            Spacer().frame(height: 6)
        }
    }
}

/// Toggle row for settings panels.
/// 設定パネル向けトグル行。
public struct WKToggleRow: View {
    let label: String
    @Binding var isOn: Bool
    let persist: Bool
    let persistKey: String?
    let onChanged: ((Bool) -> Void)?
    @Environment(\.wkTheme) private var wkTheme

    public init(
        label: String,
        isOn: Binding<Bool>,
        persist: Bool = false,
        persistKey: String? = nil,
        onChanged: ((Bool) -> Void)? = nil
    ) {
        self.label = label
        self._isOn = isOn
        self.persist = persist
        self.persistKey = persistKey
        self.onChanged = onChanged
    }

    public var body: some View {
        let p = wkTheme.palette
        Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                isOn.toggle()
            }
            saveIfNeeded()
            onChanged?(isOn)
        } label: {
            HStack {
                WKText(label, tone: .primary, size: 14)
                Spacer()
                RoundedRectangle(cornerRadius: 10)
                    .fill(isOn ? p.toggleOn : p.toggleOff)
                    .frame(width: 44, height: 24)
                    .overlay(
                        Circle()
                            .fill(p.toggleKnob)
                            .frame(width: 20, height: 20)
                            .offset(x: isOn ? 10 : -10),
                        alignment: .center
                    )
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .onAppear {
            loadIfNeeded()
        }
    }

    private func loadIfNeeded() {
        guard persist, let key = resolvedPersistKey else { return }
        isOn = WKSettingsStore.loadBool(forKey: key, default: isOn)
    }

    private func saveIfNeeded() {
        guard persist, let key = resolvedPersistKey else { return }
        WKSettingsStore.saveBool(isOn, forKey: key)
    }

    private var resolvedPersistKey: String? {
        if let persistKey = persistKey, !persistKey.isEmpty { return persistKey }
        return "toggle_\(normalized(label))"
    }
}

/// Segmented selection control with full-cell hit area.
/// 全体タップに対応したセグメント選択UIです。
/// Simplified API: selection value is the selected label string.
/// 簡易API: 選択値は文字列ラベルです。
public struct WKSegmentPicker: View {
    let items: [String]
    let persist: Bool
    let persistKey: String?
    private let externalSelection: Binding<String>?
    @Environment(\.wkTheme) private var wkTheme
    @Environment(\.wkThemeBinding) private var wkThemeBinding

    public init(
        items: [String],
        selection: Binding<String>,
        persist: Bool = false,
        persistKey: String? = nil
    ) {
        self.items = items
        self.persist = persist
        self.persistKey = persistKey
        self.externalSelection = selection
    }

    public init(
        items: [String],
        persist: Bool = false,
        persistKey: String? = nil
    ) {
        self.items = items
        self.persist = persist
        self.persistKey = persistKey
        self.externalSelection = nil
    }

    public init(
        items: [String],
        selection: Binding<WKTheme>,
        persist: Bool = false,
        persistKey: String? = nil
    ) {
        self.items = items
        self.persist = persist
        self.persistKey = persistKey
        self.externalSelection = Binding<String>(
            get: { selection.wrappedValue.label },
            set: { selected in
                if let next = WKTheme.allCases.first(where: { $0.label == selected }) {
                    selection.wrappedValue = next
                }
            }
        )
    }

    public var body: some View {
        let p = wkTheme.palette
        let currentSelection = resolvedSelection
        HStack(spacing: 0) {
            ForEach(items, id: \.self) { item in
                let selected = item == currentSelection
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        setResolvedSelection(item)
                    }
                } label: {
                    WKText(
                        item,
                        color: selected ? p.primaryText : p.secondaryText,
                        size: 13,
                        weight: selected ? .bold : .regular
                    )
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .contentShape(Rectangle())
                        .background(
                            Group {
                                if selected {
                                    RoundedRectangle(cornerRadius: 7)
                                        .fill(p.divider.opacity(0.85))
                                }
                            }
                        )
                }
                .frame(maxWidth: .infinity, minHeight: 30)
                .contentShape(Rectangle())
                .buttonStyle(.plain)
            }
        }
        .padding(2)
        .background(p.inputBg)
        .cornerRadius(8)
        .padding(.bottom, 2)
        .onAppear {
            loadIfNeeded()
        }
    }

    private var resolvedSelection: String {
        if let externalSelection = externalSelection {
            return externalSelection.wrappedValue
        }
        return wkTheme.label
    }

    private func setResolvedSelection(_ value: String) {
        if let externalSelection = externalSelection {
            externalSelection.wrappedValue = value
        } else if let wkThemeBinding = wkThemeBinding,
                  let next = WKTheme.allCases.first(where: { $0.label == value }) {
            wkThemeBinding.wrappedValue = next
        } else {
            return
        }
        saveIfNeeded(value)
    }

    private func loadIfNeeded() {
        guard persist, let key = resolvedPersistKey else { return }
        let loaded = WKSettingsStore.loadString(forKey: key, default: resolvedSelection)
        guard items.contains(loaded) else { return }
        if loaded != resolvedSelection {
            setResolvedSelection(loaded)
        }
    }

    private func saveIfNeeded(_ value: String) {
        guard persist, let key = resolvedPersistKey else { return }
        WKSettingsStore.saveString(value, forKey: key)
    }

    private var resolvedPersistKey: String? {
        if let persistKey = persistKey, !persistKey.isEmpty { return persistKey }
        if let first = items.first {
            return "segment_\(normalized(first))"
        }
        return nil
    }
}

/// Slider row with WindowKit styling and value label.
/// 値表示付きの WindowKit スタイルスライダー行。
public struct WKSliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let formatter: ((Double) -> String)?
    @Environment(\.wkTheme) private var wkTheme

    public init(
        label: String,
        value: Binding<Double>,
        in range: ClosedRange<Double>,
        step: Double = 1,
        formatter: ((Double) -> String)? = nil
    ) {
        self.label = label
        self._value = value
        self.range = range
        self.step = step
        self.formatter = formatter
    }

    public var body: some View {
        let p = wkTheme.palette
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                WKText(label, tone: .primary, size: 13)
                Spacer()
                WKText(formattedValue, tone: .primary, size: 13, weight: .bold, design: .monospaced)
            }
            Slider(value: $value, in: range, step: step)
                .accentColor(p.toggleOn)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(p.inputBg)
        .cornerRadius(8)
        .padding(.bottom, 6)
    }

    private var formattedValue: String {
        if let formatter = formatter {
            return formatter(value)
        }
        return String(format: "%.2f", value)
    }
}

/// TextField row with WindowKit styling.
/// WindowKit スタイルのテキスト入力行。
public struct WKTextFieldRow: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Environment(\.wkTheme) private var wkTheme

    public init(
        label: String,
        placeholder: String,
        text: Binding<String>
    ) {
        self.label = label
        self.placeholder = placeholder
        self._text = text
    }

    public var body: some View {
        let p = wkTheme.palette
        VStack(alignment: .leading, spacing: 6) {
            WKText(label, tone: .primary, size: 13)
            TextField(placeholder, text: $text)
                .font(.system(size: 13, design: .monospaced))
                .foregroundColor(p.primaryText)
                .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                .background(p.inputBg)
                .cornerRadius(8)
        }
        .padding(.bottom, 6)
    }
}

/// Stepper row with value readout.
/// 値表示付きの Stepper 行。
public struct WKStepperRow: View {
    let label: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    @Environment(\.wkTheme) private var wkTheme

    public init(
        label: String,
        value: Binding<Int>,
        in range: ClosedRange<Int>
    ) {
        self.label = label
        self._value = value
        self.range = range
    }

    public var body: some View {
        let p = wkTheme.palette
        Stepper(value: $value, in: range) {
            HStack(spacing: 8) {
                WKText(label, tone: .primary, size: 13)
                Spacer()
                WKText("\(value)", tone: .primary, size: 13, weight: .bold, design: .monospaced)
            }
        }
        .accentColor(p.toggleOn)
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(p.inputBg)
        .cornerRadius(8)
        .padding(.bottom, 6)
    }
}

/// Menu picker row with WindowKit styling.
/// WindowKit スタイルのメニューピッカー行。
public struct WKMenuPickerRow: View {
    let label: String
    let options: [String]
    @Binding var selection: String
    @Environment(\.wkTheme) private var wkTheme

    public init(
        label: String,
        options: [String],
        selection: Binding<String>
    ) {
        self.label = label
        self.options = options
        self._selection = selection
    }

    public var body: some View {
        let p = wkTheme.palette
        VStack(alignment: .leading, spacing: 6) {
            WKText(label, tone: .primary, size: 13)
            Menu {
                ForEach(options, id: \.self) { item in
                    Button(item) {
                        selection = item
                    }
                }
            } label: {
                HStack(spacing: 8) {
                    WKText(selection, tone: .primary, size: 13, weight: .bold, design: .monospaced)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(p.secondaryText)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(p.inputBg)
                .cornerRadius(8)
            }
            .buttonStyle(.plain)
        }
        .padding(.bottom, 8)
    }
}

/// Primary action button with WindowKit styling.
/// WindowKit スタイルのメインアクションボタン。
public struct WKActionButton: View {
    let title: String
    let action: () -> Void
    @Environment(\.wkTheme) private var wkTheme

    public init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
    }

    public var body: some View {
        let p = wkTheme.palette
        Button(action: action) {
            WKText(title, color: .white, size: 13, weight: .bold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(p.settingsButtonFill)
                )
        }
        .buttonStyle(.plain)
    }
}

private func normalized(_ value: String) -> String {
    let lowered = value.lowercased()
    let replaced = lowered.replacingOccurrences(of: " ", with: "_")
    let mapped = replaced.map { ch -> Character in
        if ch.isLetter || ch.isNumber || ch == "_" {
            return ch
        }
        return "_"
    }
    return String(mapped)
}
