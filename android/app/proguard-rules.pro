# Keep Google Auth Credentials
-keep class com.google.android.gms.auth.api.credentials.** { *; }
-keep class com.google.android.gms.auth.api.credentials.**$* { *; }

# Keep Firebase & Play Services
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Keep Razorpay classes
-keep class com.razorpay.** { *; }

# Keep Google Pay API classes

# Keep SmartAuth plugin (if used)
-keep class fman.ge.smart_auth.** { *; }

# Keep Parcelable and Serializable classes
#-keepclassmembers class * implements android.os.Parcelable {
#    public static final android.os.Parcelable$Creator *;
#}
#-keepclassmembers class * implements java.io.Serializable { *; }


# Keep Google Pay and Razorpay required classes
-keep class com.google.android.gms.wallet.** { *; }
-keep class com.google.android.apps.nbu.paisa.** { *; }

# Keep ProGuard annotation classes
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keep class com.google.android.gms.wallet.** { *; }

#-keep class proguard.annotation.Keep { *; }
#-keep class proguard.annotation.KeepClassMembers { *; }
-keep class com.google.android.gms.** { *; }
-keep class com.google.firebase.** { *; }
-keep class com.razorpay.** { *; }
-keep class com.google.android.apps.nbu.paisa.inapp.client.api.** { *; }
-keep class com.google.android.gms.wallet.** { *; }
