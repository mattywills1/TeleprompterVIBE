
import SwiftUI

@main
struct TeleprompterVIBEApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    NSApp.setActivationPolicy(.regular)          // show Dock icon & Cmd-Tab
                    NSApp.activate(ignoringOtherApps: true)      // bring window to front
                }
        }
        .windowStyle(.titleBar)
        .defaultSize(width: 800, height: 200)
        .commands {
            CommandGroup(replacing: .newItem) {
                // Disables "New" menu item
            }
            CommandGroup(replacing: .undoRedo) {
                // Disables "Undo/Redo" menu items
            }
            CommandGroup(replacing: .pasteboard) {
                 Button("Paste") {
                    // Action for pasting text
                    NotificationCenter.default.post(name: .paste, object: nil)
                }
            }
            CommandMenu("Script") {
                Button("Open Script...") {
                    // Action for opening a file
                    NotificationCenter.default.post(name: .open, object: nil)
                }
                .keyboardShortcut("o", modifiers: .command)
            }
            CommandGroup(replacing: .help) {
                // Disables "Help" menu item
            }
        }
    }
}

// Notification names for menu actions
extension Notification.Name {
    static let open = Notification.Name("co.vibecoding.open")
    static let paste = Notification.Name("co.vibecoding.paste")
}
