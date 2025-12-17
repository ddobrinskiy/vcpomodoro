import SwiftUI
import AppKit

@main
struct VCPomodoroApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var timerManager: TimerManager!
    private var notificationService: NotificationService!
    private var soundService: SoundService!
    private var eventMonitor: Any?
    private var hotkeyMonitor: Any?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize services
        soundService = SoundService()
        notificationService = NotificationService()
        timerManager = TimerManager(
            notificationService: notificationService,
            soundService: soundService
        )
        
        // Request notification permission
        notificationService.requestPermission()
        
        // Create the status item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem.button {
            updateStatusButton(button)
        }
        
        // Create popover
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        popover.animates = true
        popover.contentViewController = NSHostingController(
            rootView: PopoverView(timerManager: timerManager)
        )
        
        // Set up click handler
        if let button = statusItem.button {
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Observe timer changes to update menu bar (debounced to avoid layout recursion)
        timerManager.onUpdate = { [weak self] in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                if let button = self?.statusItem.button {
                    self?.updateStatusButton(button)
                }
            }
        }
        
        // Set up event monitor to close popover when clicking outside
        eventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            if let popover = self?.popover, popover.isShown {
                popover.performClose(nil)
            }
        }
        
        // Set up global hotkey: Cmd+Shift+P to toggle start/pause
        hotkeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            // Check for Cmd+Shift+P
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .shift] && event.keyCode == 35 { // 35 = 'P' key
                DispatchQueue.main.async {
                    self?.toggleStartPause()
                }
            }
        }
        
        // Also monitor local events (when app has focus)
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
            if flags == [.command, .shift] && event.keyCode == 35 {
                DispatchQueue.main.async {
                    self?.toggleStartPause()
                }
                return nil // Consume the event
            }
            return event
        }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = hotkeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func toggleStartPause() {
        if timerManager.state == .running {
            timerManager.pause()
        } else {
            timerManager.start()
        }
    }
    
    private func updateStatusButton(_ button: NSStatusBarButton) {
        let minutes = timerManager.minutesRemaining
        let icon = timerManager.currentSession == .work ? "🍅" : "☕️"
        
        if timerManager.state == .idle {
            button.title = "🍅"
        } else {
            button.title = "\(icon) \(minutes)m"
        }
    }
    
    @objc private func togglePopover() {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }
}


