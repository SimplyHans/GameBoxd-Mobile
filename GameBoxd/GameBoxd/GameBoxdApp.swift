//
//  GameBoxdApp.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import SwiftUI

@main
struct GameBoxdApp: App {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
        }
    }
}

private struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                TabsView()
            } else {
                LoginView()
            }
        }
    }
}

