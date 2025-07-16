import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

// Load keystore properties from key.properties file
val keystoreProperties = Properties()

val keystoreFile = rootProject.file("key.properties")
if (keystoreFile.exists()) {
    println("✅ [DEBUG] key.properties file found at: ${keystoreFile.absolutePath}")
    keystoreProperties.load(FileInputStream(keystoreFile))
    println("✅ [DEBUG] Keystore values loaded:")
    println("   storeFile = ${keystoreProperties["storeFile"]}")
    println("   keyAlias = ${keystoreProperties["keyAlias"]}")
} else {
    println("❌ [ERROR] key.properties file not found at: ${keystoreFile.absolutePath}")
}

android {
    namespace = "com.devstudio.devai"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.devstudio.devai"
        minSdk = 21
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            try {
                storeFile = rootProject.file(keystoreProperties["storeFile"] as String)
                storePassword = keystoreProperties["storePassword"] as String
                keyAlias = keystoreProperties["keyAlias"] as String
                keyPassword = keystoreProperties["keyPassword"] as String
                println("✅ [DEBUG] Signing config created successfully with keystore at: ${storeFile?.absolutePath}")
            } catch (e: Exception) {
                println("❌ [ERROR] Failed to set signing config: ${e.message}")
            }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.4"))
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")
    implementation("androidx.multidex:multidex:2.0.1")
}

flutter {
    source = "../.."
}
