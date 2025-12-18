plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.gabjago.e_commerce"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        // Gunakan compilerOptions DSL
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.gabjago.e_commerce"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion

        versionCode = 12
        versionName = "1.1.1"
    }

    signingConfigs {
        create("release") {
            storeFile = file("C:/Users/Gabriel/my-release-key.jks")
            storePassword = "gabjago"
            keyAlias = "gabjago"
            keyPassword = "gabjago"
        }
    }

    buildTypes {
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
