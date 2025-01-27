# summerschool_tutorial
### 🛠 Installation Steps

#### 🔹 **Windows**
1. **Download Flutter SDK**:
   - Visit [Flutter's official website](https://docs.flutter.dev/get-started/install/windows).
   - Download the latest **Windows** stable release as a `.zip` file.
   - Extract the `.zip` file to a desired location, such as `C:\flutter`.

2. **Set Up Environment Variables**:
   - Open **System Properties** → **Advanced** → **Environment Variables**.
   - Edit the `Path` variable and add:
     ```sh
     C:\flutter\bin
     ```

3. **Verify Installation**:
   ```sh
   flutter doctor
   ```
   This checks for missing dependencies and suggests fixes.

4. **Install Android SDK (If Needed)**:
   - Install [Android Studio](https://developer.android.com/studio).
   - Open **SDK Manager** and install the latest **Android SDK** and **Platform Tools**.

---

#### 🔹 **macOS**
1. **Install Flutter**:
   ```sh
   brew install --cask flutter
   ```
   Alternatively, download Flutter manually from [Flutter’s website](https://docs.flutter.dev/get-started/install/macos).

2. **Set Up Environment Variables** (if installed manually):
   ```sh
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Verify Installation**:
   ```sh
   flutter doctor
   ```

4. **Install Xcode (For iOS Development)**:
   ```sh
   xcode-select --install
   ```
   - Open Xcode and accept the license agreement.
   - Install **CocoaPods**:
     ```sh
     sudo gem install cocoapods
     ```

---

#### 🔹 **Linux**
1. **Download Flutter SDK**:
   ```sh
   git clone https://github.com/flutter/flutter.git -b stable
   ```
   OR download from [Flutter’s website](https://docs.flutter.dev/get-started/install/linux).

2. **Set Up Environment Variables**:
   ```sh
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

3. **Verify Installation**:
   ```sh
   flutter doctor
   ```

4. **Install Dependencies**:
   ```sh
   sudo apt update
   sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev
   ```

---

### 🎯 Next Steps
- **Run a Sample App**:
  ```sh
  flutter create my_app
  cd my_app
  flutter run
  ```
- **Configure IDE**:
  - Install Flutter & Dart plugins for **VS Code** or **Android Studio**.

For more details, check the [official documentation](https://docs.flutter.dev/get-started/install).


## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
