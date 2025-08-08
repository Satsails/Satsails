# Flutter-specific rules for the V2 embedding.
-keep class io.flutter.embedding.android.FlutterActivity { *; }
-keep class io.flutter.embedding.android.FlutterFragmentActivity { *; }
-keep class io.flutter.embedding.android.FlutterView { *; }
-keep class io.flutter.plugin.common.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# Add a more robust rule for your specific MainActivity class.
# This ensures all its members are kept.
-keep class com.satsails.Satsails.MainActivity { *; }

# Firebase SDK ProGuard rules
-keep class com.google.firebase.** { *; }
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**
