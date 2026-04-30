import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.aladdin.homy_order_app"
    
    compileSdk = 36 // or flutter.compileSdkVersion

    defaultConfig {
        applicationId = "com.aladdin.homy_order_app"
        minSdk = flutter.minSdkVersion // or flutter.minSdkVersion
        targetSdk = 36// or flutter.targetSdkVersion
        versionCode = 10
        versionName = "1.9"
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Kotlin DSL uses compilerOptions block now
        freeCompilerArgs = listOf("-Xjvm-default=all")
        jvmTarget = "17"
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false // Kotlin DSL uses 'isMinifyEnabled'
             isShrinkResources = false // add this line
        }
    }
}

flutter {
    source = "../.."
}
