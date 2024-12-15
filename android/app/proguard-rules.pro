## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }
-dontwarn io.flutter.embedding.**
-keepattributes Signature
-keepattributes *Annotation*

## Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

## audio_service plugin
-keep class com.ryanheise.audioservice.** { *; }

## Fix Play Store Split
-keep class com.google.android.play.core.splitcompat.** { *; }
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication

## Fix for all Android classes that might be accessed via reflection
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class androidx.lifecycle.LifecycleOwner
-keepnames class androidx.lifecycle.LifecycleOwner

## Just Audio
-keep class com.google.android.exoplayer2.** { *; }
-dontwarn com.google.android.exoplayer2.**

## Cached network image
-keep class com.bumptech.glide.** { *; }