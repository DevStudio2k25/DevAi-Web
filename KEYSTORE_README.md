# Keystore Configuration

## 🔐 Keystore Details

Keystore File: keystore (PKCS12 format)
Store Password: DevStudio2k25
Key Alias: devstudio
Organization: DevStudio
Valid Until: September 1, 2050

## 📁 File Structure

BloomeeTunes/
├── key.properties             # Keystore configuration
└── android/
    └── app/
        ├── keystore           # Your keystore file
        └── build.gradle       # Build configuration

## ⚙️ Setup Instructions

### key.properties File

Create `key.properties` in the main project directory:
```properties
storePassword=DevStudio2k25
keyPassword=DevStudio2k25
keyAlias=devstudio
storeFile=keystore
```

**⚠️ Important**: Since keystore is now in `android/app/keystore`, use `storeFile=keystore` (no path prefix needed)

### Gradle Configuration
Add this to `android/app/build.gradle`:

```gradle
// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('../key.properties')

// Signing configuration
signingConfigs {
    release {
        if (keystorePropertiesFile.exists()) {
            keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile rootProject.file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }
}

// Build types
buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled true
        shrinkResources true
    }
}
```

### Path Configuration

- **Keystore location**: `C:\Users\ANRIT\Desktop\BloomeeTunes\android\app\keystore`
- **Key properties**: `C:\Users\ANRIT\Desktop\BloomeeTunes\key.properties`
- **Build file**: `android/app/build.gradle`

## 🚀 Build Command

```bash
flutter build apk --release
```

## 🔒 Security

Add to `.gitignore`:

```
keystore
key.properties
*.jks
*.p12
