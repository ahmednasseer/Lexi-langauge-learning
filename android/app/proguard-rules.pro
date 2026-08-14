# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.firebase.auth.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.auth.api.signin.**

# Google Sign-In
-keep class com.google.android.gms.auth.api.signin.** { *; }
-keep class com.google.android.gms.common.api.GoogleApiClient$OnConnectionFailedListener { *; }

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.app.FlutterApplication { *; }
-dontwarn io.flutter.**
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Flutter Embedding
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.embedding.engine.FlutterEngine { *; }
-keep class io.flutter.embedding.engine.FlutterEngineGroup { *; }

# Generated plugins
-keep class io.flutter.generated.** { *; }
-keep class io.flutter.platform.** { *; }

# Keep Kotlin metadata
-keepattributes Signature, InnerClasses, EnclosingMethod, RuntimeVisibleAnnotations, RuntimeVisibleParameterAnnotations, AnnotationDefault
-keepattributes SourceFile, LineNumberTable

# Hive
-keep class org.apache.commons.** { *; }
-keep class com.esotericsoftware.** { *; }

# Speech to text
-keep class com.csontar.** { *; }

# Image cropper
-dontwarn com.yalantis.google.**

# Cached network image
-keep class com.nostra12.** { *; }
-keep class com.nostra12.imageloader.** { *; }

# Keep model classes used with reflection
-keep class com.lexi.** { *; }

# Keep Hive generated adapters
-keep class * extends io.flutter.plugins.GeneratedPluginRegistrant { *; }
-keep class $FLUTTER_PACKAGE$
