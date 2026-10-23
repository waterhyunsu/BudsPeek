import SwiftUI

@main
struct BudsPeekApp: App {
    @State private var bluetooth = BluetoothManager()

    var body: some Scene {
        MenuBarExtra {
            StatusPanel(manager: bluetooth)
        } label: {
            Image(systemName: "earbuds")
                .symbolRenderingMode(.hierarchical)
                .help(bluetooth.isConnected ? "BudsPeek — 연결됨" : "BudsPeek — 연결 대기 중")
        }
        .menuBarExtraStyle(.window)

        Window("BudsPeek", id: "main") {
            StatusPanel(manager: bluetooth)
                .frame(width: 390, height: 560)
        }
        .defaultSize(width: 390, height: 560)
    }
}
