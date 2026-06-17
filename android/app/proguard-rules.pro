# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exceptions

# SQLite
-keep class net.sqlcipher.** { *; }
-keep class net.sqlcipher.database.** { *; }

# Provider / Architecture Components
-keep class androidx.lifecycle.** { *; }
-keep class androidx.arch.core.** { *; }

# dartz
-keep class dartz.** { *; }

# Gson (if used)
-keepclassmembers class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# ============================================
# FIX: Google Play Core / Deferred Components
# ============================================
# Ye classes Flutter engine reference karta hai lekin app use nahi karta
# Dynamic feature delivery ke liye hoti hain — ignore karo
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# ============================================
# Keep for debugging
# ============================================
-keepattributes SourceFile,LineNumberTable
-renamesourcefileattribute SourceFile