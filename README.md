# Photo Print Calculator Pro

A complete, production-ready, **100% offline** Flutter app for photo studios,
print houses, flex printing shops, wedding photographers, frame shops and
digital printing businesses. Instantly calculates print area & price from a
photo size, with PDF invoices, history, and shop settings — built with
Material 3 and clean architecture.

---

## ✨ Features

- **Instant calculator** — enter Width & Height in Inch / CM / MM / Feet,
  results update live with **no Calculate button**.
- Auto-converts to **Square Inch, Square Feet, Square Meter**.
- **Price engine** — Rate (₹/Sq.Ft) × Quantity × Area, with optional **GST**
  and **Round Off**, shown on a live gradient summary card.
- **History** — every calculation saved locally in **SQLite**, with search,
  edit, delete, and clear-all.
- **PDF Invoices** — generates a professional invoice (business name,
  customer, size, area, rate, qty, GST, grand total, date) which can be
  **saved, shared, or printed** directly from the device.
- **Settings** — business name, currency symbol, default GST %, theme
  (Light / Dark / System), and About section.
- Premium **Material 3** UI: rounded cards, navy + orange brand palette,
  smooth bottom navigation, responsive for phones & tablets.

---

## 🗂 Project Structure

```
lib/
├── main.dart                     # App entry point
├── core/
│   ├── constants/                # App-wide constants & enums
│   ├── theme/                    # Material 3 light/dark theme
│   └── utils/                    # Calculator engine + formatters
├── data/
│   ├── models/                   # CalculationRecord, AppSettings
│   ├── database/                 # SQLite helper
│   └── repositories/             # CRUD + settings persistence
├── presentation/
│   ├── providers/                # Provider-based state management
│   ├── screens/
│   │   ├── calculator/           # Main calculator screen
│   │   ├── history/              # History list, edit, invoice preview
│   │   └── settings/             # Settings screen
│   ├── widgets/                  # Shared reusable widgets
│   └── home_shell.dart           # Bottom navigation shell
└── services/
    └── pdf_service.dart          # PDF generation, save, share, print
```

---

## 🛠 Tech Stack

| Layer            | Choice                                   |
|-------------------|-------------------------------------------|
| Framework         | Flutter (stable) + Dart, null-safe        |
| State management  | `provider`                                |
| Local database    | `sqflite`                                 |
| Settings storage  | `shared_preferences`                      |
| PDF generation    | `pdf` + `printing`                        |
| UI                | Material 3                                |

---

## ✅ Prerequisites

1. [Flutter SDK](https://docs.flutter.dev/get-started/install) (latest stable channel)
2. Android Studio (or VS Code with Flutter/Dart plugins)
3. An Android device or emulator running **Android 5.0 (API 21)** or higher

Check your setup any time with:
```bash
flutter doctor
```

---

## 🚀 Run It Locally

```bash
cd photo_print_calculator_pro
flutter pub get
flutter run
```

That's it — the app boots straight into the Calculator tab.

> **First-time only:** open `android/local.properties` and make sure
> `flutter.sdk=` points to your local Flutter SDK path (Android Studio sets
> this automatically the first time you open the project there).

---

## 🎨 Regenerating Icons & Splash Screen

A ready-made navy/orange camera icon is already included at
`assets/icon/app_icon.png` (with adaptive-icon foreground and splash logo
variants). Default launcher PNGs are already in `android/.../mipmap-*/` so
the project builds immediately — but to (re)generate polished adaptive
icons & a native splash screen after pub get:

```bash
flutter pub run flutter_launcher_icons
flutter pub run flutter_native_splash:create
```

Want a different icon? Just replace the three PNGs in `assets/icon/` and
re-run the two commands above.

---

## 📦 Building a Release APK

### Option A — Android Studio (recommended for first build)

1. Open the project folder in Android Studio → let it finish **Gradle Sync**.
2. **Build → Generate Signed Bundle / APK… → APK**.
3. Either pick an existing keystore or click **Create new...** to generate
   one (Android Studio walks you through it — save the `.jks` file
   somewhere safe, you'll need it for every future update).
4. Choose **release** build variant → Finish.
5. Your signed APK appears under `android/app/release/`.

### Option B — Command line with your own keystore

1. Generate a keystore once (skip if you already have one):
   ```bash
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA \
     -keysize 2048 -validity 10000 -alias upload
   ```
2. Create `android/key.properties`:
   ```properties
   storePassword=<your_keystore_password>
   keyPassword=<your_key_password>
   keyAlias=upload
   storeFile=../upload-keystore.jks
   ```
   (`build.gradle` is already wired to pick this up automatically — see
   the comment block at the top of `android/app/build.gradle`.)
3. Build:
   ```bash
   flutter build apk --release
   ```
4. Find the APK at `build/app/outputs/flutter-apk/app-release.apk`.

> Until `key.properties` exists, release builds silently fall back to the
> Flutter debug signing key so `flutter build apk` always succeeds out of
> the box — just remember to switch to your real keystore before
> publishing or sharing the APK with customers.

### Option C — Codemagic (cloud build, no local Android SDK needed)

1. Push this project to a Git repo (GitHub/GitLab/Bitbucket) — or use
   Codemagic's "upload manually" flow.
2. In Codemagic → **Add application** → select the repo → Flutter App.
3. Upload your keystore under **Code signing identities** and fill in the
   same four values as `key.properties` above.
4. Use the default Flutter workflow, build type **APK** (or App Bundle for
   Play Store), and start the build.
5. Download the signed APK from the build artifacts once it finishes.

---

## 🧾 How Pricing Works

Pricing is always calculated on **square feet** — the unit the printing
industry uses for rate cards — regardless of which unit (Inch/CM/MM/Feet)
the dimensions were entered in:

```
Subtotal     = Sq.Ft × Rate per Sq.Ft × Quantity
GST Amount   = Subtotal × GST% / 100   (only if GST toggle is ON)
Grand Total  = Subtotal + GST Amount   (rounded if Round Off is ON)
```

---

## 🔐 Privacy

100% offline. No analytics, no network calls, no ads. All calculations and
customer names are stored only in a local SQLite database on the device.

---

## 📄 License

Delivered as a complete source project for **Shri Print House** for
commercial use. No additional license restrictions imposed by this
delivery — customize freely.
