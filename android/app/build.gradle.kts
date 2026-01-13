plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    // Firebase if needed
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.flutter_application"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.flutter_application"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // WARNING: Change this for production!
            signingConfig = signingConfigs.getByName("debug") 
            // OR simply: signingConfig = signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // You only need these if you are using native Android code alongside Flutter
    implementation("androidx.appcompat:appcompat:1.6.1")   
    implementation("com.google.android.material:material:1.12.0")
       
    // Firebase dependency (note: no version needed if using Firebase BOM)
    implementation("com.google.firebase:firebase-auth") 
}