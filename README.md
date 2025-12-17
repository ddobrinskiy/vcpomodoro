# VCPomodoro 🍅

A lightweight macOS menu bar Pomodoro timer app built with Swift and SwiftUI.

![App Icon](icon.png)

## Features

- **Menu bar integration** - Lives in your menu bar, no dock icon
- **Customizable timers** - Adjust work (5-60 min) and break (5-30 min) durations
- **Global hotkeys** - Control the timer from anywhere
- **System notifications** - Get notified when sessions end
- **Sound feedback** - Audio cues for session start/end
- **Material Design UI** - Clean, modern interface

## Usage

### Menu Bar Icons

| Icon | Meaning |
|------|---------|
| 🍅 | Ready to start work session |
| ☕️⚠️ | Work complete, waiting to start break |
| 🍅 25m | Work session running (25 minutes left) |
| ☕️ 5m | Break session running (5 minutes left) |
| 🍅 23m ⏸ | Timer paused |

### Global Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `⌘⌥⇧P` | Start / Pause timer |
| `⌘⌥⇧B` | Skip to next session |

> **Note:** Global shortcuts require Accessibility permissions. Go to **System Settings → Privacy & Security → Accessibility** and enable VCPomodoro.

### Controls

- Click the menu bar icon to open the popover
- Use **Play/Pause** button to control the timer
- Use **Reset** button to restart the current session
- Use **Skip** button to move to the next session
- Adjust work/break durations with the **+/-** buttons (5-minute increments)

## Build Instructions

### Requirements

- macOS 14.0+ (Sonoma/Tahoe)
- Xcode 15.0+

### Building

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/vc-pomodoro.git
   cd vc-pomodoro
   ```

2. Open the project in Xcode:
   ```bash
   open VCPomodoro.xcodeproj
   ```

3. **Important:** Change the build configuration to Release:
   - Go to **Product → Scheme → Edit Scheme** (or press `⌘<`)
   - Select **Run** on the left sidebar
   - Change **Build Configuration** from "Debug" to **"Release"**
   - Click **Close**

4. Build the app:
   - Press `⌘B` to build

## Installation

### Option 1: Copy to Applications (Recommended)

After building, copy the app to your Applications folder:

```bash
cp -r ~/Library/Developer/Xcode/DerivedData/VCPomodoro-*/Build/Products/Release/VCPomodoro.app /Applications/
```

### Option 2: Run from Xcode

Simply press `⌘R` to build and run directly from Xcode.

### Post-Installation Setup

1. **Grant Accessibility Permissions** (required for global hotkeys):
   - Open **System Settings → Privacy & Security → Accessibility**
   - Click **+** and add VCPomodoro from Applications
   - Toggle it **ON**

2. **Launch at Login** (optional):
   - Open **System Settings → General → Login Items**
   - Click **+** under "Open at Login"
   - Select VCPomodoro from Applications

## Technical Notes

- Uses `osascript` for notifications (works without paid Apple Developer account)
- App sandbox is disabled to enable global keyboard monitoring
- Settings are persisted using `@AppStorage`

## License

MIT License - Feel free to use and modify as you like.

