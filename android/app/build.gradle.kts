import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

val keyProperties = Properties()
val keyPropertiesFile = rootProject.file("key.properties")
if (keyPropertiesFile.exists()) {
    keyProperties.load(keyPropertiesFile.inputStream())
}

android {
    namespace = "com.lexi.learning"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        isCoreLibraryDesugaringEnabled = true
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.lexi.learning"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
    }

    signingConfigs {
        create("release") {
            storeFile = if (keyPropertiesFile.exists()) {
                rootProject.file(keyProperties.getProperty("storeFile"))
            } else {
                rootProject.file("app/debug.keystore")
            }
            storePassword = keyProperties.getProperty("storePassword") ?: ""
            keyAlias = keyProperties.getProperty("keyAlias") ?: ""
            keyPassword = keyProperties.getProperty("keyPassword") ?: ""
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
    dependencies {
        coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")
    }
}

flutter {
    source = "../.."
}

gradle.projectsEvaluated {
    tasks.findByName("bundleRelease")?.doLast {
        val aabFile = file("${layout.buildDirectory.get()}/outputs/bundle/release/app-release.aab")
        val destDir = file("../../build/app/outputs/bundle/release")
        if (aabFile.exists()) {
            destDir.mkdirs()
            project.copy {
                from(aabFile)
                into(destDir)
            }
            println("[LEXi] Copied .aab to ${destDir.absolutePath}")
        } else {
            println("[LEXi] .aab not found at ${aabFile.absolutePath}")
        }
    }
}
