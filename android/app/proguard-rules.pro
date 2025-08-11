#--------------------------------------
# Preserve Flutter Wrapper code
#--------------------------------------
#-keep class io.flutter.app.** { *; }
#-keep class io.flutter.plugin.**  { *; }
#-keep class io.flutter.util.**  { *; }
#-keep class io.flutter.view.**  { *; }
#-keep class io.flutter.**  { *; }
#-keep class io.flutter.plugins.**  { *; }
#-keep class io.flutter.plugin.editing.** { *; }

#--------------------------------------
# Tinylog
#--------------------------------------
#-keepnames interface org.tinylog.**
#-keepnames class * implements org.tinylog.**
#-keepclassmembers class * implements org.tinylog.** { <init>(...); }

#--------------------------------------
# JNA
#--------------------------------------
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }

#--------------------------------------
# To ignore minifyEnabled: true error
# https://github.com/flutter/flutter/issues/19250
# https://github.com/flutter/flutter/issues/37441
#--------------------------------------
-dontwarn io.flutter.embedding.**
-ignorewarnings
-keep class * {
    public private *;
}

#--------------------------------------
# Android App Links & MicroG SafeParcelable
#--------------------------------------
#-keep public class * extends org.microg.safeparcel.AutoSafeParcelable {
#    @org.microg.safeparcel.SafeParcelable.Field *;
#    @org.microg.safeparcel.SafeParceled *;
#}
#
# Keep asInterface method cause it's accessed from SafeParcel
#-keepattributes InnerClasses
#-keepclassmembers interface * extends android.os.IInterface {
#    public static class *;
#}
#-keep public class * extends android.os.Binder { public static *; }
