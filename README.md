# Dragon City Open Source Edition (Independent Project)

A clean-room, independent reimplementation of Dragon City featuring:
- **Native iOS Client (`DragonCityClient`)**: Built in Swift & SwiftUI, completely independent of the original proprietary game binaries and servers.
- **Custom Game Server (`server.py`)**: Built with FastAPI, featuring 3x faster timers, player persistence (`save.json`), dragon breeding, hatching, habitats, gold collection, and farming.
- **Original Asset Reuse**: Configured to utilize extracted art assets and sprites.

## Getting Started

### 1. Run the Game Server
```bash
python3 server.py
```
The server runs on port `8011` (with public tunneling available via Cloudflare).

### 2. Build the iOS App
Open the Swift/SwiftUI client project (`DragonCityClient`) in Xcode on macOS, or generate the Xcode project using XcodeGen (`xcodegen`) and build/run it on your iPhone or simulator.
```bash
cd DragonCityClient
xcodegen generate
```
