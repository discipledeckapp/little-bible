import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

val keyPropertiesFile = rootProject.file("key.properties")
val keyProperties = Properties()
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}
fun signingValue(property: String, environment: String): String? =
    (keyProperties[property] as String?) ?: System.getenv(environment)

android {
    namespace = "org.littlebible.little_bible"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "org.littlebible.little_bible"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        if (signingValue("keyAlias", "ANDROID_KEY_ALIAS") != null) {
          create("release") {
            keyAlias = signingValue("keyAlias", "ANDROID_KEY_ALIAS")
            keyPassword = signingValue("keyPassword", "ANDROID_KEY_PASSWORD")
            storeFile = file(signingValue("storeFile", "ANDROID_KEYSTORE_PATH")!!)
            storePassword = signingValue("storePassword", "ANDROID_KEYSTORE_PASSWORD")
          }
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.findByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
}
