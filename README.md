# Simple Flutter Weather App

A Flutter application that fetches and displays current weather data for a city entered by the user.

### 1. API Key Setup Instructions

This app uses the [OpenWeatherMap API](https://openweathermap.org/api) to fetch weather data. You need a free API key to run the application.

1.  **Sign Up:** Go to [OpenWeatherMap's sign-up page](https://home.openweathermap.org/users/sign_up) and create a free account.
2.  **Get API Key:** Once you are logged in, navigate to the "API keys" tab on your account dashboard. You will find your default API key there.
3.  **Add Key to Project:**
    *   Open the project file: `lib/services/weather_service.dart`.
    *   Find the line: `static const _apiKey = 'e007d95a91d9b929c5d647a5382d2fd1';`
    *   Replace `'e007d95a91d9b929c5d647a5382d2fd1'` with your actual API key.

> **Note:** A new API key can take a few minutes up to an hour to become active.


### 2. How to Run the App

**Prerequisites:**
- Flutter SDK installed
- An IDE like VS Code or Android Studio
- A connected device or running emulator

**Steps:**
1.  Clone this repository to your local machine.
2.  Open the project in your IDE.
3.  Install the necessary dependencies by running the following command in the project's root terminal:

    flutter pub get

4.  Run the application with the following command:

    flutter run



### 3. Flutter Version Used

This project was developed and tested using the following environment:

-   **Flutter Version:** 3.19.x (or higher stable version)
-   **Dart Version:** 3.3.x (or higher)