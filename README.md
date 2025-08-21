# Fenix Field Watch Face

A Garmin Connect IQ watch face inspired by classic field watches, designed for 115 Garmin devices.

## Features
- **Full-screen display**: No black border, uses complete screen real estate
- **Dual time format**: Main 12-hour numerals with 24-hour markers
- **Solid filled hands**: Clean, solid white hands with square tips for excellent visibility
- **Enhanced second hand**: 4px white second hand for maximum visibility
- **Anti-aliased rendering**: Smooth, non-pixelated lines for premium appearance
- **Enhanced center design**: Larger white center circle with thick green ring accent
- **Dynamic day/date**: Robust date display at 3 o'clock position
- **Battery indicator**: Visual battery status with color coding
- **Military-inspired design**: Clean, functional aesthetic with solid hand styling

## Supported Devices (115 total)
- **Fenix Series**: 5, 5 Plus, 5S, 5S Plus, 5X, 5X Plus, 6, 6 Pro, 6S, 6S Pro, 6X Pro, 7, 7 Pro, 7 Pro NoWiFi, 7S, 7S Pro, 7X, 7X Pro, 7X Pro NoWiFi, 8 (43mm), 8 (47mm), 8 Solar (47mm), 8 Solar (51mm), Chronos, E
- **Epix Series**: Gen 2, Pro (42mm), Pro (47mm), Pro (51mm)
- **Forerunner Series**: 55, 165, 165 Music, 245, 245 Music, 255, 255 Music, 255S, 255S Music, 265, 265S, 570 (42mm), 570 (47mm), 645, 645 Music, 745, 935, 945, 945 LTE, 955, 965, 970
- **Enduro Series**: Enduro, Enduro 3
- **MARQ Series**: Gen 2, Gen 2 Aviator, Adventurer, Athlete, Aviator, Captain, Commander, Driver, Expedition, Golfer

## Current Version: 1.11.7
**App ID**: 1F90C25D6F4444BFBA9E0BB210D8F418

### Latest Features (v1.11.7)
- **Fixed Deep Sleep Wake**: Resolved second hand not appearing after extended inactivity
- **Instant Visibility**: Second hand now shows immediately when watch face becomes active
- **Simplified Logic**: Always display second hand during active viewing for better user experience
- **Smooth operation**: Maintains smooth second hand movement in low-power mode via onPartialUpdate()
- **Power budget compliant**: Uses mandatory clipping regions as required by Garmin specifications
- **Enhanced stability**: Battery and date indicators remain visible during all updates
- **Official Garmin implementation**: Follows Connect IQ documentation for Always On Watch Faces
- **Optimized performance**: Efficient clipping regions minimize power consumption
- **Solid filled hands**: Completely solid white hour and minute hands with square tips
- **Enhanced visibility**: 4px white second hand for maximum contrast and readability
- **Day display reliability**: Triple-redundancy system ensures day always displays correctly
- **Timezone support**: Robust date/time handling across all timezones and regions
- **Verified across all 115 supported devices**

## Hand Design Details (v1.7)
- **Hour Hand**: 14px total width (7px half-width), pointed tip extending to 58% radius, 1px white dot
- **Minute Hand**: 10px total width (5px half-width), pointed tip extending to 76% radius, 1px white dot
- **Both Hands**: 2px white outline thickness, transparent centers, anti-aliased rendering
- **Second Hand**: 2px green line extending to 80% radius
- **Center**: 8px white circle with 9px green ring (2px thickness)

## Development

### Prerequisites
- Connect IQ SDK
- Visual Studio Code with Connect IQ extension (optional but recommended)

### Building
```bash
# For all devices (store ready)
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
"/Users/[USERNAME]/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -e -f monkey.jungle -o releases/FenixFieldWatchFace_v1.11.7.iq -y developer_key.der

# For single device testing (e.g., Fenix 6 Pro)
"/Users/[USERNAME]/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -d fenix6pro -f monkey.jungle -o FenixFieldWatchFace_v1.11.7.prg -y developer_key.der
```

### Testing in Simulator
```bash
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
"/Users/[USERNAME]/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeydo" FenixFieldWatchFace_v1.7.prg fenix6xpro
```

### Testing in Simulator
```bash
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
"/Users/[USERNAME]/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeydo" FenixFieldWatchFace_v1.11.7.prg fenix6xpro
```

## Installation
1. Download `FenixFieldWatchFace_v1.11.7.iq` from the releases folder
2. Copy to your Garmin device's GARMIN/APPS folder via USB
3. Or use Garmin Connect IQ app on mobile to install
4. Or use Garmin Express desktop application

## Version History
- **v1.11.7**: Fixed second hand not appearing after deep sleep - now shows immediately on wake
- **v1.11.6**: Fixed second hand duplication with proper Garmin Connect IQ onPartialUpdate() implementation
- **v1.11.0**: Smooth second hand implementation with Always On Watch Face support
- **v1.10.2**: Fixed day display format issue - changed from FORMAT_MEDIUM to FORMAT_SHORT for reliable numeric day values
- **v1.10.1**: Resolved critical day display stuck bug with triple-redundancy approach
- **v1.10.0**: Enhanced day/date display reliability and error handling
- **v1.8.0**: Wider hands with solid filling and square tips for maximum visibility
- **v1.7.0**: Wider hands with anti-aliasing, extended pointed tips, enhanced visibility
- **v1.6.0**: Complete hand redesign with pointed tips and outlined transparent design
- **v1.5.0**: Enhanced hand design with improved visibility and green second hand
- **v1.0.0**: Initial release with classic field watch design
