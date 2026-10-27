import SwiftUI
import AppKit

struct StatusPanel: View {
    @Bindable var manager: BluetoothManager
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.45)
            ScrollView {
                VStack(spacing: 14) {
                    if manager.isConnected {
                        batteryCard
                        controlsCard
                    } else {
                        deviceCard
                        discoveryCard
                    }
                    footer
                }
                .padding(18)
            }
        }
        .frame(minWidth: 360, minHeight: 430)
        .background(.regularMaterial)
        .task {
            manager.onAutoConnected = { openWindow(id: "main") }
            manager.startAutoConnect()
        }
    }

    private var header: some View {
        HStack(spacing: 12) {
            Image(systemName: "earbuds")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(.primary)
                .frame(width: 42, height: 42)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 13))
            VStack(alignment: .leading, spacing: 3) {
                Text("BudsPeek").font(.headline)
                HStack(spacing: 5) {
                    Circle().fill(manager.isConnected ? .green : .secondary).frame(width: 6, height: 6)
                    Text(manager.isConnected ? "Galaxy Buds 연결됨" : "연결된 Galaxy Buds 없음")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button { openWindow(id: "main") } label: {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.plain)
            .help("설정 및 진단")
        }
        .padding(.horizontal, 18)
        .padding(.vertical, manager.isConnected ? 8 : 14)
    }

    private var deviceCard: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(.quaternary.opacity(0.7)).frame(width: 88, height: 88)
                Image(systemName: "earbuds")
                    .font(.system(size: 38, weight: .light))
                    .foregroundStyle(manager.isConnected ? Color.accentColor : .secondary)
            }
            VStack(spacing: 4) {
                Text(manager.connectedName ?? "Galaxy Buds3 Pro")
                    .font(.system(size: 17, weight: .semibold))
                Text(manager.isConnected ? "\(manager.connectedModel?.rawValue ?? "Galaxy Buds") · Bluetooth" : "SM-R630 · 연결 대기 중")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if manager.isConnected {
                Button("연결 해제", role: .destructive) { manager.disconnect() }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 20))
        .overlay(RoundedRectangle(cornerRadius: 20).strokeBorder(.white.opacity(0.12)))
    }

    private var discoveryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("내 기기", systemImage: "dot.radiowaves.left.and.right")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button {
                    manager.isScanning ? manager.stopScanning() : manager.startScanning()
                } label: {
                    if manager.isScanning {
                        ProgressView().controlSize(.small)
                    } else {
                        Label("검색", systemImage: "arrow.clockwise")
                    }
                }
                .buttonStyle(.borderless)
            }
            if let error = manager.connectionError {
                Label(error, systemImage: "exclamationmark.triangle.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
            }
            if manager.discoveredDevices.isEmpty {
                Text(manager.isScanning ? "주변 기기를 찾고 있습니다…" : "Bluetooth 검색으로 페어링된 Galaxy Buds를 찾으세요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            } else {
                ForEach(manager.discoveredDevices) { device in
                    Button {
                        let model = BudsModel.detect(from: device.name) ?? .buds3Pro
                        manager.connect(to: device, model: model)
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "earbuds").frame(width: 24)
                            Text(device.name).lineLimit(1)
                            Spacer()
                            Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .padding(.vertical, 6)
                }
            }
            if !manager.bluetoothReady {
                Text("Bluetooth 권한을 허용하면 페어링 기기를 확인할 수 있습니다.")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(.white.opacity(0.12)))
    }

    private var batteryCard: some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack {
                Label("배터리", systemImage: "battery.100")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Button { manager.requestStatusUpdate() } label: {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .help("상태 새로고침")
            }
            HStack(spacing: 9) {
                BatteryTile(title: "왼쪽", value: manager.status.hasBatteryData ? manager.status.batteryLeft : nil)
                BatteryTile(title: "오른쪽", value: manager.status.hasBatteryData ? manager.status.batteryRight : nil)
                BatteryTile(title: "케이스", value: manager.status.displayedCaseBattery)
            }
            Text("케이스 잔량은 버즈가 케이스 안에 있을 때 확인할 수 있습니다")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(.white.opacity(0.12)))
    }

    private var controlsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("빠른 제어", systemImage: "slider.horizontal.3")
                .font(.subheadline.weight(.semibold))
            HStack(spacing: 8) {
                ForEach([NoiseControlMode.anc, .ambient, .off], id: \.self) { mode in
                    Button {
                        manager.setNoiseControl(mode)
                    } label: {
                        VStack(spacing: 6) {
                            Image(systemName: mode.iconName).font(.title3)
                            Text(mode.shortName).font(.caption)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(manager.status.noiseControlMode == mode ? Color.accentColor.opacity(0.16) : Color.primary.opacity(0.04), in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(manager.status.noiseControlMode == mode ? Color.accentColor : .primary)
                }
            }
            Picker("이퀄라이저", selection: Binding(
                get: { manager.status.equalizerPreset },
                set: { manager.setEqualizer($0) }
            )) {
                ForEach(EqualizerPreset.allCases) { preset in
                    Text(preset.displayName).tag(preset)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(.quaternary.opacity(0.55), in: RoundedRectangle(cornerRadius: 10))
            Text("기기 펌웨어와 연결 상태에 따라 일부 설정은 응답하지 않을 수 있습니다.")
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding(15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.background.opacity(0.72), in: RoundedRectangle(cornerRadius: 17))
        .overlay(RoundedRectangle(cornerRadius: 17).strokeBorder(.white.opacity(0.12)))
    }

    private var footer: some View {
        HStack {
            Text("비공식 Galaxy Buds 동반 앱")
            Spacer()
            Button("종료") { NSApplication.shared.terminate(nil) }
                .buttonStyle(.plain)
        }
        .font(.caption2)
        .foregroundStyle(.secondary)
        .padding(.horizontal, 2)
    }
}

private struct BatteryTile: View {
    let title: String
    let value: Int?

    var body: some View {
        VStack(spacing: 7) {
            Image(systemName: batterySymbol)
                .font(.system(size: 17))
                .foregroundStyle(batteryTint)
            Text(value.map { "\($0)%" } ?? "—")
                .font(.system(size: 15, weight: .semibold, design: .rounded))
            Text(title).font(.caption2).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
    }

    private var batterySymbol: String {
        guard let value else { return "questionmark.circle" }
        return value > 20 ? "battery.75percent" : "battery.25percent"
    }

    private var batteryTint: Color {
        guard let value else { return .secondary }
        return value > 20 ? .secondary : .orange
    }
}
