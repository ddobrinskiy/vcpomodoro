import Foundation
import AppKit

class SoundService {
    func playStart() {
        // Use system sound for start
        if let sound = NSSound(named: .init("Blow")) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
    
    func playEnd() {
        // Use system sound for end - more prominent
        if let sound = NSSound(named: .init("Glass")) {
            sound.play()
        } else {
            NSSound.beep()
        }
    }
}


