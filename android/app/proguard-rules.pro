# Keep Gemini API classes
-keep class com.google.android.generative.** { *; }
-keep class com.google.generativeai.** { *; }
-keep class com.google.ai.client.generativeai.** { *; }

# Keep Flutter Secure Storage
-keep class com.it_nomads.fluttersecurestorage.** { *; }

# Keep JSON serialization classes
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses

# Keep generic signatures and annotations
-keepattributes Signature
-keepattributes *Annotation*

# Keep Dart-related classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class io.flutter.plugin.** { *; }

# Keep Kotlin serialization
-keepattributes RuntimeVisibleAnnotations,AnnotationDefault

# Keep your model classes
-keep class com.devstudio.devai.models.** { *; }
-keep class com.devstudio.devai.** { *; }

# Keep Google libraries
-keep class com.google.** { *; }

# Keep Kotlin libraries
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Don't warn about missing classes from Android APIs for different platform versions
-dontwarn android.**
-dontwarn com.android.**
-dontwarn androidx.**

# Don't warn about missing Kotlin classes
-dontwarn kotlin.**
-dontwarn kotlinx.**

# Don't warn about missing Google classes
-dontwarn com.google.**

# Don't warn about missing Flutter classes
-dontwarn io.flutter.** 