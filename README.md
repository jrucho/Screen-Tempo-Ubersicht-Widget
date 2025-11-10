![ScreenTempo](https://github.com/user-attachments/assets/df8be8c0-d343-4119-b2a1-d4a8bc457d4f)
# Screen-Tempo-Ubersicht-Widget
Screen Tempo : A tiny always-on-top metronome that flashes the whole screen and clicks. Designed for [Übersicht](https://github.com/felixhageloh/uebersicht) on macOS.

# Übersicht Metronome Widget

A tiny always-on-top metronome that flashes the whole screen and (optionally) clicks.  
Designed for [Übersicht](https://github.com/felixhageloh/uebersicht) on macOS.

![demo](https://user-images.githubusercontent.com/YOUR_USER_NAME/REPO_NAME/docs/preview.gif)

## One-line install

```bash
git clone https://github.com/jrucho/ubersicht-metronome \
  ~/Library/Application\ Support/Übersicht/widgets/Metronome.widget
Reload Übersicht (menu-bar icon → “Refresh all Widgets”) and you’re done.
How to use
Table
Copy
Control	What it does
ON/OFF	Start / stop the pulse
TAP	Tap 4+ times to set tempo (auto-starts)
+ / −	Change BPM (hold for fast scroll)
speaker	Toggle click sound (default = silent)
Range: 20 – 300 BPM.
Customise
Open Metronome.widget/index.coffee and edit:
coffeescript
Copy
bpm: 120          # default speed
--mint: #CFE9DD   # accent colour
Credits
Original idea: Carlos Abeijón Martínez
Bug-fix & package: jrucho
License
MIT – do whatever you want.
Copy

`install.sh`  (optional convenience script)
```bash
#!/usr/bin/env bash
set -e
WIDGET_DIR="$HOME/Library/Application Support/Übersicht/widgets/Metronome.widget"
rm -rf "$WIDGET_DIR"
git clone https://github.com/jrucho/ubersicht-metronome.git "$WIDGET_DIR"
echo "✅  Metronome widget installed.  Reload Übersicht to see it."
Push to GitHub
bash
Copy
cd ubersicht-metronome
git add .
git commit -m "initial release – fixed RAF loop, tap-tempo, silent by default"
git tag v1.0.0
git push origin main --tags
Tell people
Tweet / toot / slack the clone-one-liner:
bash
Copy
git clone https://github.com/jrucho/ubersicht-metronome \
  ~/Library/Application\ Support/Übersicht/widgets/Metronome.widget
