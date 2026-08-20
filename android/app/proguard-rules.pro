# Flutter
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core (deferred components — not used, suppress missing class errors)
-dontwarn com.google.android.play.core.**

# Keep app model classes
-keep class com.cloud_company_cc.kaj_ache.** { *; }

# General
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**
