import Foundation
import Combine
import SwiftUI

class TimerManager: ObservableObject {
    @Published var state: TimerState = .idle
    @Published var currentSession: SessionType = .work
    @Published var secondsRemaining: Int = 25 * 60
    
    @AppStorage("workDuration") var workDuration: Int = 25
    @AppStorage("restDuration") var restDuration: Int = 5
    
    var onUpdate: (() -> Void)?
    
    private var timer: Timer?
    private let notificationService: NotificationService
    private let soundService: SoundService
    
    var minutesRemaining: Int {
        return Int(ceil(Double(secondsRemaining) / 60.0))
    }
    
    var progress: Double {
        let totalSeconds = currentSession == .work ? workDuration * 60 : restDuration * 60
        guard totalSeconds > 0 else { return 0 }
        return 1.0 - (Double(secondsRemaining) / Double(totalSeconds))
    }
    
    init(notificationService: NotificationService, soundService: SoundService) {
        self.notificationService = notificationService
        self.soundService = soundService
        self.secondsRemaining = workDuration * 60
    }
    
    func start() {
        if state == .idle {
            // Starting fresh
            secondsRemaining = currentSession == .work ? workDuration * 60 : restDuration * 60
            soundService.playStart()
        }
        
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        onUpdate?()
    }
    
    func pause() {
        state = .paused
        timer?.invalidate()
        timer = nil
        onUpdate?()
    }
    
    func reset() {
        timer?.invalidate()
        timer = nil
        state = .idle
        currentSession = .work
        secondsRemaining = workDuration * 60
        onUpdate?()
    }
    
    func skipToNext() {
        timer?.invalidate()
        timer = nil
        switchSession()
    }
    
    // Debug: Start a 5-second session
    func startDebugSession() {
        timer?.invalidate()
        timer = nil
        state = .idle
        currentSession = .work
        secondsRemaining = 5
        soundService.playStart()
        state = .running
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        onUpdate?()
    }
    
    func updateWorkDuration(_ minutes: Int) {
        workDuration = minutes
        if state == .idle && currentSession == .work {
            secondsRemaining = minutes * 60
        }
        onUpdate?()
    }
    
    func updateRestDuration(_ minutes: Int) {
        restDuration = minutes
        if state == .idle && currentSession == .rest {
            secondsRemaining = minutes * 60
        }
        onUpdate?()
    }
    
    private func tick() {
        guard secondsRemaining > 0 else {
            sessionComplete()
            return
        }
        
        secondsRemaining -= 1
        onUpdate?()
        
        if secondsRemaining == 0 {
            sessionComplete()
        }
    }
    
    private func sessionComplete() {
        timer?.invalidate()
        timer = nil
        
        soundService.playEnd()
        
        if currentSession == .work {
            notificationService.sendNotification(
                title: "Work Session Complete!",
                body: "Great job! Time for a break."
            )
        } else {
            notificationService.sendNotification(
                title: "Break is Over!",
                body: "Ready to focus again?"
            )
        }
        
        switchSession()
    }
    
    private func switchSession() {
        currentSession = currentSession == .work ? .rest : .work
        secondsRemaining = currentSession == .work ? workDuration * 60 : restDuration * 60
        state = .idle
        onUpdate?()
    }
}


