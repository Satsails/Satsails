#--------------------------------------
# Flutter core classes
#--------------------------------------
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class io.flutter.plugin.editing.** { *; }

#--------------------------------------
# Firebase Messaging (updated for latest SDK)
#--------------------------------------
-keep class com.google.firebase.messaging.FirebaseMessagingService { *; }
-keep class com.google.firebase.messaging.FirebaseMessaging { *; }
-keep class com.google.firebase.iid.FirebaseInstanceId { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdService { *; }
-keep class com.google.firebase.messaging.RemoteMessage { *; }
-keep class com.google.firebase.messaging.RemoteMessage$Notification { *; }
-keep class com.google.firebase.iid.FirebaseInstanceIdReceiver { *; }
-keep class com.google.firebase.iid.internal.FirebaseInstanceIdInternalReceiver { *; }
-keep class com.google.firebase.iid.internal.FirebaseInstanceIdInternalReceiver$* { *; }
-keep class com.google.firebase.installations.FirebaseInstallations { *; }
-keep class com.google.firebase.installations.FirebaseInstallationsApi { *; }


# Keep FirebaseMessagingService callback methods
-keepclassmembers class * extends android.app.Service {
    public void onMessageReceived(com.google.firebase.messaging.RemoteMessage);
    public void onNewToken(java.lang.String);
}

#--------------------------------------
# Optional: tinylog (if used)
#--------------------------------------
-keepnames interface org.tinylog.**
-keepnames class * implements org.tinylog.**
-keepclassmembers class * implements org.tinylog.** { <init>(...); }

#--------------------------------------
# Optional: JNA (if used)
#--------------------------------------
-keep class com.sun.jna.** { *; }
-keep class * implements com.sun.jna.** { *; }

#--------------------------------------
# MicroG SafeParcelable (only if used)
#--------------------------------------
-keep public class * extends org.microg.safeparcel.AutoSafeParcelable {
    @org.microg.safeparcel.SafeParcelable.Field *;
    @org.microg.safeparcel.SafeParceled *;
}
-keepattributes InnerClasses
-keepclassmembers interface * extends android.os.IInterface {
    public static class *;
}
-keep public class * extends android.os.Binder { public static *; }

#--------------------------------------
# Ignore warnings related to Flutter embedding and java.awt (JNA headless)
#--------------------------------------
-dontwarn io.flutter.embedding.**
-dontwarn java.awt.**

#--------------------------------------
# Miscellaneous
#--------------------------------------
# Keep all native libraries, symbols etc.
-keep class * {
    native <methods>;
}

