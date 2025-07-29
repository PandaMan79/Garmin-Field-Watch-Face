# Fenix Watch Face

A Garmin Connect IQ watch face inspired by classic Seiko military watches, designed for the Fenix 6 Pro Solar.

## Features
- Dark background with cream-colored Arabic numerals
- 24-hour time markers
- Day/date display
- Classic analog hands with red second hand
- "FENIX" branding

## Development

### Prerequisites
- Connect IQ SDK
- Visual Studio Code with Connect IQ extension (optional but recommended)

### Building
```bash
monkeyc -d fenix6pro -f monkey.jungle -o FenixWatchFace.prg -y developer_key.der
```

### Testing
```bash
connectiq
# Then select your device and load the .prg file
```

## Installation
1. Build the project to generate a .prg file
2. Copy to your Garmin device's GARMIN/APPS folder
3. Or use Garmin Express to install
