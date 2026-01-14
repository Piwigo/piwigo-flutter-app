import org.jetbrains.kotlin.gradle.dsl.JvmTarget
import java.util.Properties
import java.io.FileInputStream

/*
    When AGP 9 is released, we need to migrate the build system using this guide :
        https://docs.flutter.dev/release/breaking-changes/migrate-to-agp-9
 */

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}
// https://docs.flutter.dev/deployment/android#configure-signing-in-gradle
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    namespace = "com.remi.piwigo_ng"
    //compileSdkVersion flutter.compileSdkVersion
    //ndkVersion = flutter.ndkVersion
    compileSdk = 36
    ndkVersion = "29.0.14206865 "

    val compileJavaVersion = JavaVersion.VERSION_17

    compileOptions {
        // Flag to enable support for the new language APIs
        isCoreLibraryDesugaringEnabled = true
        // Sets Java compatibility to Java 17
        sourceCompatibility = compileJavaVersion
        targetCompatibility = compileJavaVersion
    }

    kotlin {
        compilerOptions {
            jvmTarget = JvmTarget.JVM_17
        }
    }


    defaultConfig {
        applicationId = "com.piwigo.piwigo_ng"
        multiDexEnabled = true
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as? String
            keyPassword = keystoreProperties["keyPassword"] as? String
            storeFile = keystoreProperties["storeFile"]?.let { file(it) }
            storePassword = keystoreProperties["storePassword"] as? String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation("androidx.window:window:1.5.1")
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")
}
