// android/app/build.gradle.kts

plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
    // Google Services plugin (works with classpath in project build.gradle.kts)
    id("com.google.gms.google-services")
}

android {
    namespace = "com.gmi.waveact"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    defaultConfig {
        applicationId = "com.gmi.waveact"
        minSdk = 23
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }

    compileOptions {
        // Use Java 17
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            // Use your real release signing config when you have one
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
        }
        debug {
            // Debug defaults are fine
        }
    }

    // (Optional) If you run into duplicate file issues later, uncomment:
    // packaging {
    //     resources {
    //         excludes += "/META-INF/{AL2.0,LGPL2.1}"
    //     }
    // }
}

flutter {
    source = "../.."
}

dependencies {
    // Firebase BoM is only needed if you add native Firebase libs here.
    // The FlutterFire plugins already include what they need.
    implementation(platform("com.google.firebase:firebase-bom:34.0.0"))

    // Optional: Google Sign-In native dependency (google_sign_in brings it transitively,
    // but declaring it can help resolve versions consistently)
    implementation("com.google.android.gms:play-services-auth:21.2.0")
}

/**
 * Register a signingReport task so you can generate SHA-1 / SHA-256
 * from Android Studio's Gradle panel (app > Tasks > other > signingReport)
 * or via:  ./gradlew :app:signingReport
 */
