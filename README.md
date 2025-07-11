
# TeleprompterVIBE (v0.5)

A personal, lightweight teleprompter for macOS that auto-advances as you speak.

## How to Build and Run

1.  **Open the project:** The project is set up as a Swift Package. Open the `TeleprompterVIBE` directory in Xcode.
    *   `File > Open...` and select the `TeleprompterVIBE` folder.
2.  **Select the Target:** Choose the `TeleprompterVIBE` executable for `My Mac`.
3.  **Run the App:** Click the "Run" button (or press `Cmd+R`).

## How to Use

1.  **Grant Permission:** The first time you run the app, you will be asked for microphone permission. This is required for the speech recognition to work.
2.  **Load a Script:**
    *   **Drag and Drop:** Drop a `.txt` file onto the app window.
    *   **File Open:** Use the menu `Script > Open Script...` (or `Cmd+O`).
    *   **Paste:** Copy text to your clipboard and use the `Edit > Paste` menu.
3.  **Control the Teleprompter:**
    *   **Spacebar:** Start or pause the teleprompter.
    *   **Up Arrow:** Manually scroll back one word.
    *   **Down Arrow:** Manually scroll forward one word.
    *   **Esc:** Quit the application.

## Features

*   **On-Device Speech Recognition:** All audio is processed on your Mac.
*   **Real-time Highlighting:** The current word is highlighted in yellow, and spoken words fade out.
*   **Smooth Scrolling:** The script slides up smoothly as you read.
*   **Multiple Input Methods:** Load scripts from files or the pasteboard.
*   **Error Handling:** A red border will flash if there's a problem with speech recognition.
