// android/app/build.gradle.kts

// Project-level buildscript configuration (normally in project root)
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Updated Android Gradle & Kotlin plugins for compatibility
        classpath("com.android.tools.build:gradle:8.8.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.25")

        // Google Services - using latest stable version
        classpath("com.google.gms:google-services:4.4.2")
    }
}

// App-level plugins
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("dev.flutter.flutter-gradle-plugin")
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
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
        debug {
            isDebuggable = true
        }
    }

    // Fix potential duplicate file issues
    packaging {
        resources {
            excludes += setOf(
                "/META-INF/{AL2.0,LGPL2.1}",
                "/META-INF/DEPENDENCIES",
                "/META-INF/LICENSE",
                "/META-INF/LICENSE.txt",
                "/META-INF/NOTICE",
                "/META-INF/NOTICE.txt"
            )
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Use latest Firebase BoM for consistent versions
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))

    // Firebase services (versions managed by BoM)
    implementation("com.google.firebase:firebase-analytics")
    implementation("com.google.firebase:firebase-auth")
    implementation("com.google.firebase:firebase-firestore")

    // Google Play Services
    implementation("com.google.android.gms:play-services-auth:21.2.0")
}

// Project-level repository configuration
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Custom build directory configuration
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// Clean task
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}