//
//  MainView.swift
//  Cloudly
//
//  Created by Sara on 2025-08-11.
//
//MainView = User’s entry point (shows current weather + weekly list)

import SwiftUI
import CoreLocation
// Main screen of the app.
// Shows: background image, city/current weather header, 7-day list, search, and "use my location".
struct MainView: View {
    // Global app state (current city + coordinate), injected at app launch
    @EnvironmentObject private var app: AppState
    // ViewModel that fetches/holds weather data
    @StateObject private var vm  = WeatherViewModel()
    // Wrapper around CLLocationManager (permission + one-shot location)
    @StateObject private var loc = LocationManager()

    // Search UI state
    @State private var searchText = ""
    @State private var searchResults: [GeoResult] = []
    @State private var isSearching = false

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                       ZStack(alignment: .topLeading) {
                           // Full-screen weather-themed image with slight white overlay for readability
                           Image("weather_bg")
                               .resizable()
                               .scaledToFill()
                               .frame(width: geo.size.width, height: geo.size.height)
                               .clipped()
                               .overlay(Color.white.opacity(0.18))
                          
                               .ignoresSafeArea(edges: .bottom)

                           // FOREGROUND content pinned at the top, with padding
                           contentView
                               .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                               .padding(.horizontal, 24)
                               .padding(.top, 8)
                       }
                       .frame(width: geo.size.width, height: geo.size.height)
                   }
            // The nav bar title mirrors the current city from AppState
                   .foregroundColor(.black)  
                   .navigationTitle(app.selectedCity)
                   .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Right bar button: "use my location"
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            // Ask for permission / one-shot location
                            loc.request()
                            if let c = loc.coordinate {
                                Task {
                                    // Convert coordinate to a friendly "City, CC"
                                    let name = await ReverseGeocoder.cityName(for: c)
                                    // Update global app state
                                    app.set(city: name, coord: c)
                                    // Load weather for this coordinate
                                    await vm.load(for: c)
                                }
                            }
                        } label: { Image(systemName: "location.circle") }
                    }

                }
                .navigationTitle(app.selectedCity)
                .navigationBarTitleDisplayMode(.inline)
            // Keep nav bar visible and blend into background image
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarBackground(Color.clear, for: .navigationBar)
            // Built-in search field in the nav bar
                .searchable(text: $searchText, prompt: "Search city")
                .onSubmit(of: .search) {
                    isSearching = true
                    Task { await doSearch() } // trigger geocoding search
                }
            // Results overlay: floats under the search bar (doesn't push main content)
                .overlay(alignment: .top) {
                    if !searchResults.isEmpty {
                        List(searchResults) { item in
                            // Tapping a search result selects that city and loads weather
                            Button {
                                let cityName = item.state == nil
                                    ? "\(item.name), \(item.country)"
                                    : "\(item.name), \(item.state!), \(item.country)"
                                let coord = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lon)

                                app.set(city: cityName, coord: coord) // update global selection
                                searchResults = []
                                searchText = ""
                                isSearching = false
                                Task { await vm.load(for: coord) } // fetch weather for new city
                            } label: {
                                // Show city + optional state/country
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.name).font(.headline)
                                    Text([item.state, item.country].compactMap { $0 }.joined(separator: ", "))
                                        .font(.subheadline).foregroundStyle(.secondary)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .scrollContentBackground(.hidden)
                        .frame(maxHeight: 240) // keep list compact
                        .background(.ultraThinMaterial) // frosted glass look
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                    }
                }
            // Only reload when the coordinate changes meaningfully (~300m via .3f precision)
                .task(id: app.selectedCoordinate.map { String(format: "%.3f,%.3f", $0.latitude, $0.longitude) }) {
                    if let c = app.selectedCoordinate { await vm.load(for: c) }
                }
            // When GPS updates (and we're on "Current Location"), set AppState city/coord
                .onReceive(loc.$coordinate) { new in
                    guard let c = new else { return }
                    if app.selectedCoordinate == nil || app.selectedCity == "Current Location" {
                        Task {
                            let name = await ReverseGeocoder.cityName(for: c)
                            app.set(city: name, coord: c)
                        }
                    }
                }
            // Kick off a location request on first appearance
                .onAppear { loc.request() }
        }
        // BACKGROUND IMAGE — behind everything
        .background(
            Image("weather_bg")
                .resizable()
                .scaledToFill()
                .overlay(Color.white.opacity(0.18))
                .ignoresSafeArea()
        )
    }

    // MARK: - Content states
    // Decides what to show based on ViewModel state (loading, error, data, or waiting for location).
    @ViewBuilder
    private var contentView: some View {
        if vm.isLoading {
            // Loading spinner while fetching
            ProgressView("Loading weather...")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        } else if let err = vm.error {
            // Friendly error message with a retry
            VStack(alignment: .leading, spacing: 8) {
                Text(err).foregroundStyle(.red)
                Button("Retry") { requestWeather() }.buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            // We have data: show the main content
        } else if let current = vm.current {
           
            content(current: current)
        } else {
            // We don't have permission yet or no location → prompt + try again

            Text("Requesting location…")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .task { loc.request() }
        }
    }

    // Shows the city badge, current header, and the 7-day list.
    @ViewBuilder
    private func content(current: CurrentWeather) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // CITY BADGE (small pill with the selected city)
                Text(app.selectedCity)
                    .font(.headline.weight(.semibold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .shadow(radius: 2)

                // Big temperature + description + H/L row
                header(current)
                // Daily forecast rows with navigation to details
                weeklyList
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 12)
        }
        .scrollIndicators(.hidden)
        .refreshable { requestWeather() } // pull-to-refresh calls VM again
    }

    // MARK: - Sections

    // Large current-conditions header (icon, temp, description, H/L)

    private func header(_ cw: CurrentWeather) -> some View {
        let icon = WeatherIcon.symbol(for: cw.weather.first?.id ?? 800)
        return HStack(alignment: .center, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 52))
                .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
            VStack(alignment: .leading, spacing: 6) {
                // Big current temperature

                Text(Fmt.temp(cw.main.temp))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .shadow(color: .black.opacity(0.35), radius: 4, x: 0, y: 2)

                // Friendly description (e.g., "Scattered Clouds")

                Text(cw.weather.first?.description.capitalized ?? "")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                    .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)

                // High / Low display

                HStack(spacing: 12) {
                    Text("H \(Fmt.temp(cw.main.temp_max))")
                    Text("L \(Fmt.temp(cw.main.temp_min))").foregroundStyle(.secondary)
                }
                .font(.headline)
            }
            Spacer()
        }
    }

    // The 7-day list (each row navigates to DetailView)

    private var weeklyList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("7-Day Forecast").font(.title3).bold()
            ForEach(vm.days) { day in
                NavigationLink {
                    DetailView(day: day, current: vm.current) // We tap a day in the 7-day list and pass its DailySummary to DetailView:
                } label: { DayRowView(day: day) } // compact day row
                .buttonStyle(.plain)
                .padding(.vertical, 4)
            }
        }
    }

    // MARK: - Actions

    // Ask ViewModel to reload using the currently selected coordinate
    private func requestWeather() {
        guard let c = app.selectedCoordinate else { return }
        Task { await vm.load(for: c) }
    }

    // Search cities via OpenWeather's geocoding API
    private func doSearch() async {
        guard !searchText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isSearching = true
        defer { isSearching = false } // always clear the searching flag at the
        do {
            searchResults = try await WeatherAPI.shared.searchCities(searchText, limit: 8)
        } catch {
            print("❌ Search API error:", error)
            searchResults = []
        }
    }
}


#Preview {
    MainView().environmentObject(AppState())
}
