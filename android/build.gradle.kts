// android/build.gradle.kts

// ✅ Apply Google Services plugin (for Firebase)
plugins {
    id("com.google.gms.google-services") version "4.4.3" apply false
}

// ✅ Required repositories and dependencies
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath("com.android.tools.build:gradle:8.4.0")
        classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.23")
        classpath ("com.google.gms:google-services:4.4.0") // Or latest version

    }
}

// ✅ Repositories for all modules
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// ✅ Custom build directory logic (keep as-is)
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// ✅ Clean task remains
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
