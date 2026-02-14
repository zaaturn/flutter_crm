plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.my_app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11


        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "11"
    }

    defaultConfig {
        applicationId = "com.example.my_app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BOM (version manager)
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))

    // Firebase services imagine as wires, not batteries
    implementation("com.google.firebase:firebase-messaging")
    implementation("com.google.firebase:firebase-analytics")


    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

configurations.all {
    resolutionStrategy {
        // Browser
        force("androidx.browser:browser:1.8.0")

        // Activity
        force("androidx.activity:activity:1.9.3")
        force("androidx.activity:activity-ktx:1.9.3")

        // Core
        force("androidx.core:core:1.13.1")
        force("androidx.core:core-ktx:1.13.1")
    }
}
