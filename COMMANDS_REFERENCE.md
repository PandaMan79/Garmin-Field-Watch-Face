# Garmin Watch Face Development - Command Reference

## 🏗️ Build Commands

### Basic Build (for testing/simulator)
```bash
"/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -d fenix6pro -f monkey.jungle -o WatchFace.iq -y developer_key.der
```

### Full Build for Store Upload (IMPORTANT)
```bash
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH" && "/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -e -d fenix6pro -f monkey.jungle -o FenixWatchFace_v1.0.iq -y developer_key.der
```

**Key Flags:**
- `-e` = Package app (REQUIRED for store upload)
- `-d fenix6pro` = Target device
- `-f monkey.jungle` = Build configuration file
- `-o filename.iq` = Output file
- `-y developer_key.der` = Developer signing key

## 🔑 Developer Key Management

### Generate New Developer Keys
```bash
# Generate private key
openssl genrsa -out developer_key.pem 2048

# Convert to DER format for Garmin SDK
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

### Backup Keys
```bash
cp developer_key.der developer_key_backup.der
cp developer_key.pem developer_key_backup.pem
```

## 🧹 Cleanup Commands

### Clean Build Files
```bash
rm -f *.iq *.prg *.prg.debug.xml
rm -rf bin/ gen/ internal-mir/ external-mir/
```

### Complete Workspace Reset
```bash
# Remove all build artifacts
rm -f *.iq *.prg *.prg.debug.xml
rm -rf bin/ gen/ internal-mir/ external-mir/

# Generate fresh keys
rm -f developer_key.*
openssl genrsa -out developer_key.pem 2048
openssl pkcs8 -topk8 -inform PEM -outform DER -in developer_key.pem -out developer_key.der -nocrypt
```

## 🏃‍♂️ Simulator Commands

### Start Connect IQ Simulator
```bash
"/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/connectiq" &
```

### Install to Simulator
1. Build with basic build command
2. Open simulator
3. Drag .iq file to simulator window

## 📝 Version Management

### Update Version in manifest.xml
```xml
<iq:application ... version="1.0.0">
```

### Naming Convention
- v1.0: `FenixWatchFace_v1.0.iq`
- v1.1: `FenixWatchFace_v1.1.iq`
- Store uploads: Always use `-e` flag for full packaging

## 🔍 Debugging & Validation

### Validate XML Manifest
```bash
xmllint --noout manifest.xml
```

### Check Build Output
```bash
ls -la *.iq
```

### View SDK Version
```bash
"/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -v
```

## 📦 File Structure

### Essential Files
```
├── manifest.xml          # App configuration
├── monkey.jungle         # Build settings
├── developer_key.der     # Signing key (DER format)
├── developer_key.pem     # Signing key (PEM format)
├── source/               # Source code
│   ├── FenixWatchFaceApp.mc
│   ├── FenixWatchFaceDelegate.mc
│   └── FenixWatchFaceView.mc
└── resources/            # Assets
    ├── resources.xml
    └── drawables/
        └── launcher_icon.png
```

### Generated Files (can be deleted)
```
├── *.iq              # Build outputs
├── *.prg*            # Debug files
├── bin/              # Compiled binaries
├── gen/              # Generated code
├── internal-mir/     # Internal compiler files
└── external-mir/     # External compiler files
```

## 🚀 Deployment Checklist

1. **Update Version**: Edit `manifest.xml` version number
2. **Clean Build**: Remove old .iq files
3. **Full Build**: Use command with `-e` flag
4. **Verify Size**: Store-ready files are typically 100KB+
5. **Upload**: Use the .iq file created with `-e` flag

## ⚡ Quick Commands

### One-Line Store Build
```bash
export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH" && "/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -e -d fenix6pro -f monkey.jungle -o FenixWatchFace_v$(grep version manifest.xml | sed 's/.*version="\([^"]*\)".*/\1/').iq -y developer_key.der
```

### Quick Test Build
```bash
"/Users/carlintegrand.co.za/Library/Application Support/Garmin/ConnectIQ/Sdks/connectiq-sdk-mac-8.2.2-2025-07-17-cf29b22d5/bin/monkeyc" -d fenix6pro -f monkey.jungle -o test.iq -y developer_key.der
```

---

## 🆘 Common Issues

**"Failed to extract developer signature"**: Missing `-e` flag or bad keys
**"0 OUT OF 12 DEVICES BUILT"**: Usually a signing key issue
**"BUILD SUCCESSFUL" but small file**: Missing `-e` flag
**Store upload fails**: Ensure you used `-e` flag for the build

---

*Last updated: July 30, 2025*
