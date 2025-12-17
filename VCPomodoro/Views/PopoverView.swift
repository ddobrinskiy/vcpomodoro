import SwiftUI

struct PopoverView: View {
    @ObservedObject var timerManager: TimerManager
    @Environment(\.colorScheme) var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(hex: "1C1B1F") : Color(hex: "FFFBFE")
    }
    
    private var surfaceColor: Color {
        colorScheme == .dark ? Color(hex: "2B2930") : Color(hex: "F7F2FA")
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            Text(timerManager.currentSession.displayName)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            // Timer Display
            TimerDisplayView(timerManager: timerManager)
            
            // Control Buttons
            HStack(spacing: 16) {
                // Reset Button
                Button(action: { timerManager.reset() }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(MaterialColors.primary)
                        .frame(width: 48, height: 48)
                        .background(surfaceColor)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Play/Pause Button
                Button(action: {
                    if timerManager.state == .running {
                        timerManager.pause()
                    } else {
                        timerManager.start()
                    }
                }) {
                    Image(systemName: timerManager.state == .running ? "pause.fill" : "play.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.white)
                        .frame(width: 64, height: 64)
                        .background(
                            timerManager.currentSession == .work
                                ? MaterialColors.primary
                                : MaterialColors.secondary
                        )
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Skip Button
                Button(action: { timerManager.skipToNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(MaterialColors.primary)
                        .frame(width: 48, height: 48)
                        .background(surfaceColor)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 2, y: 1)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.vertical, 8)
            
            // Settings Card
            SettingsView(timerManager: timerManager)
                .padding(16)
                .background(surfaceColor)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
            
            // Debug Button
            Button(action: { timerManager.startDebugSession() }) {
                Text("🐛 5s Debug")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange)
                    .cornerRadius(6)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Quit Button
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                Text("Quit")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.bottom, 8)
        }
        .padding(16)
        .frame(width: 300)
        .background(backgroundColor)
    }
}

struct MaterialColors {
    static let primary = Color(hex: "6750A4")
    static let secondary = Color(hex: "03DAC6")
    static let onPrimary = Color.white
    static let onSecondary = Color.black
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    PopoverView(timerManager: TimerManager(
        notificationService: NotificationService(),
        soundService: SoundService()
    ))
}


