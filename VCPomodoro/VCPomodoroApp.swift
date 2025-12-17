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
        
        // Observe timer changes to update menu bar
        timerManager.onUpdate = { [weak self] in
            DispatchQueue.main.async {
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
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        if let monitor = eventMonitor {
            NSEvent.removeMonitor(monitor)
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


