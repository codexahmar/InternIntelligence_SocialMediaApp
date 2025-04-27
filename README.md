# Social Media App

A feature-rich social media application built with Flutter and Firebase, offering a modern and intuitive user experience.

## Features

- 🔐 User Authentication
  - Email & Password Sign up/Login
  - Persistent login state
- 👤 Profile Management
  - Customizable user profiles
  - Profile picture upload
  - Bio update
- 🔍 Social Features
  - User search functionality
  - Follow/Unfollow users
  - Real-time feed updates
- 📱 Responsive Design
  - Seamless experience across different screen sizes
  - Material Design 3 implementation

## Screenshots

<div style="display: flex; justify-content: space-between;">
    <img src="Screenshots/signup.png" alt="Signup Screen" width="32%"/>
    <img src="Screenshots/home.png" alt="Home Screen" width="32%"/>
    <img src="Screenshots/search.png" alt="Search Screen" width="32%"/>
</div>

## Tech Stack

- **Frontend**: Flutter
- **Backend**: Firebase
  - Authentication
  - Cloud Firestore
  - Storage
- **State Management**: Provider
- **Other Libraries**:
  - cached_network_image
  - image_picker
  - shared_preferences
  - uuid

## Setup Instructions

1. **Prerequisites**

   - Flutter SDK
   - Firebase account
   - Android Studio / VS Code

2. **Installation**

   ```bash
   # Clone the repository
   git clone <repository-url>

   # Navigate to project directory
   cd social_media

   # Install dependencies
   flutter pub get
   ```

3. **Firebase Setup**

   - Create a new Firebase project
   - Enable Authentication, Firestore, and Storage
   - Configure Firebase for both Android and iOS platforms
   - Add your Firebase configuration files:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
     - Flutter: `lib/firebase_options.dart`

4. **Run the app**
   ```bash
   flutter run
   ```

## Environment Support

- ✅ Android
- ✅ iOS
- 🚧 Web (Coming Soon)
- 🚧 Desktop (Coming Soon)

## Contributing

1. Fork the repository
2. Create a new branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter Team for the amazing framework
- Firebase for the backend infrastructure
- All contributors and supporters of this project
