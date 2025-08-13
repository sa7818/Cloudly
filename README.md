 # ☁️ Cloudly 
 **Cloudly** is a weather app for iOS(compatible with any version) which integrates with the  [OpenWeatherMap API] (https://openweathermap.org/api)


the app enables users to search for specific location and, by default,displays the current location's weather.

## Features
## Main Screen
- Displays the **weather of the current location**, including:
 - Name of the city
 - Highlighting today temperature
 - Rain
 - Shows a **list of upcoming week's forecast"
 - Serves as an **Overbiew Page** with no specific details

### Details Page
- Clicking on a day(today, tomorrow, etc) opens a **detailed forecast** page with : 
 - Wind Speed
 - Humidity
 - Pressure 
 - Visibility
 - **Bonus** : Chart with a daily forecast by hours ( open-source chart library)

## Requirements & Guidelines
- **Language:** Swift
- **Architecture Pattern:** MVVM
- **Frameworks:** SwiftUI
     
## Bonus(Optional)
- The adaptive layout guidelines - runs smoothly on:
- iPhone & iPad
- landscape/portrait
- Includes **unit**, **integration**, **UI testing**.
- Use additional libraries such as : 
-  [SwiftCharts](https://github.com/i-schuetz/SwiftCharts)


### Installation
 Clone the repository:
  **git clone https://github.com/sa7818/Cloudly.git **


## 🧭 Project Structure & System Design
Cloudly
├─  Entry & Main UI
│ ├─ CloudlyApp.swift → App entry point; injects AppState into the environment
│ └─ ContentView.swift 
│
├─  ViewModels
│ ├─ WeatherViewModel.swift → Fetches & formats weather data; publishes UI state
│ └─ AppState.swift → Global selection: city name + coordinates
│
├─ Models
│ ├─ CurrentWeather.swift → Decodable models for “current” weather endpoint
│ ├─ Forecast.swift → Decodable models for 3-hour forecast; daily grouping
│ └─ Geocoding.swift → Decodable models for city/geocoding search
│
├─  Utilities
│ ├─ WeatherIcon.swift → Maps weather codes → SF Symbol names
│ └─ Formatters.swift → Date/number helpers (hour, day, temp formatting)
│
├─  Assets
│ ├─ App Icons 
│ └─ Weather background images 
│
└─  Tests
├─ CloudlyUITest.swift → UI test cases
└─ CloudlyUITestsLaunchTests.swift → Launch test suite
