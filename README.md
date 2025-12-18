# e_commerce

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Impeller Rendering

Impeller is Flutter’s modern GPU renderer. This app’s UI is compatible with Impeller. Use the following commands to run/build with Impeller enabled and avoid software rendering:

### Run

```bash
flutter run -d <device> --enable-impeller
```

### Build

```bash
# Android
flutter build apk --enable-impeller

# iOS
flutter build ios --enable-impeller
```

### Tips for Best Performance

- Prefer GPU rendering; avoid `--enable-software-rendering`.
- Keep `CustomPainter` simple (arcs, paths, text are fine).
- Avoid large `BackdropFilter` or heavy blurs in scrolling lists.
- Use `ClipRRect` for rounded corners on large dynamic content.

## Using Skia (disable Impeller)

If you prefer Skia GPU rendering, run/build with Impeller disabled. Avoid `--enable-software-rendering` unless debugging CPU-only fallback, as it bypasses the GPU entirely.

### Run with Skia

```bash
# Disable Impeller explicitly (Skia GPU)
flutter run -d <device> --enable-impeller=false

# Or simply omit the Impeller flag (uses default renderer for device)
flutter run -d <device>
```

### Build with Skia

```bash
# Android (APK)
flutter build apk --enable-impeller=false

# iOS
flutter build ios --enable-impeller=false
```

### Notes

- `--enable-software-rendering` forces CPU rendering and is not Skia GPU.
- On some platforms, renderer defaults can change with Flutter versions; explicitly passing `--enable-impeller=false` ensures Skia.


