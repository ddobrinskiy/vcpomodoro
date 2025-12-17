import SwiftUI

struct SettingsView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Settings")
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Work Duration
            HStack {
                Image(systemName: "brain.head.profile")
                    .foregroundColor(MaterialColors.primary)
                    .frame(width: 24)
                
                Text("Focus")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                DurationPicker(
                    value: timerManager.workDuration,
                    range: 5...60,
                    accentColor: MaterialColors.primary,
                    step: 5,
                    onChange: { timerManager.updateWorkDuration($0) }
                )
            }
            
            Divider()
            
            // Rest Duration
            HStack {
                Image(systemName: "cup.and.saucer.fill")
                    .foregroundColor(MaterialColors.secondary)
                    .frame(width: 24)
                
                Text("Break")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                DurationPicker(
                    value: timerManager.restDuration,
                    range: 5...30,
                    accentColor: MaterialColors.secondary,
                    step: 5,
                    onChange: { timerManager.updateRestDuration($0) }
                )
            }
        }
    }
}

struct DurationPicker: View {
    let value: Int
    let range: ClosedRange<Int>
    let accentColor: Color
    let step: Int
    let onChange: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: {
                let newValue = max(range.lowerBound, value - step)
                onChange(newValue)
            }) {
                Image(systemName: "minus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(value > range.lowerBound ? accentColor : .gray)
                    .frame(width: 28, height: 28)
                    .background(accentColor.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value <= range.lowerBound)
            
            Text("\(value)m")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.primary)
                .frame(width: 40)
            
            Button(action: {
                let newValue = min(range.upperBound, value + step)
                onChange(newValue)
            }) {
                Image(systemName: "plus")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(value < range.upperBound ? accentColor : .gray)
                    .frame(width: 28, height: 28)
                    .background(accentColor.opacity(0.1))
                    .clipShape(Circle())
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(value >= range.upperBound)
        }
    }
}

#Preview {
    SettingsView(timerManager: TimerManager(
        notificationService: NotificationService(),
        soundService: SoundService()
    ))
    .padding()
    .frame(width: 280)
    .background(Color(hex: "F7F2FA"))
}


