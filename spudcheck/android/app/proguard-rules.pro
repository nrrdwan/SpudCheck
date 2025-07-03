# Keep all TensorFlow Lite classes including GPU
-keep class org.tensorflow.** { *; }
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-dontwarn org.tensorflow.**

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}
