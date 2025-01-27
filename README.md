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

- Run flutter pub get
- Run the project main.dart
- Voila
