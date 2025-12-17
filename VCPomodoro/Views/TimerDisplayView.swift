import SwiftUI

struct TimerDisplayView: View {
    @ObservedObject var timerManager: TimerManager
    
    private var accentColor: Color {
        timerManager.currentSession == .work
            ? MaterialColors.primary
            : MaterialColors.secondary
    }
    
    private var trackColor: Color {
        accentColor.opacity(0.2)
    }
    
    var body: some View {
        ZStack {
            // Background track
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 160, height: 160)
            
            // Progress arc
            Circle()
                .trim(from: 0, to: timerManager.progress)
                .stroke(accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 160, height: 160)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: timerManager.progress)
            
            // Time display
            VStack(spacing: 4) {
                Text("\(timerManager.minutesRemaining)")
                    .font(.system(size: 48, weight: .light, design: .rounded))
                    .foregroundColor(.primary)
                
                Text(timerManager.minutesRemaining == 1 ? "minute" : "minutes")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
                
                // State indicator
                if timerManager.state == .paused {
                    Text("PAUSED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(accentColor)
                        .padding(.top, 4)
                }
            }
        }
        .padding(.vertical, 16)
    }
}

#Preview {
    TimerDisplayView(timerManager: TimerManager(
        notificationService: NotificationService(),
        soundService: SoundService()
    ))
    .padding()
    .background(Color(hex: "FFFBFE"))
}


