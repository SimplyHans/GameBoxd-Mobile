//
//  SearchView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct SearchView: View {
    @State private var query: String = ""

    // Demo data – replace with real data source
    @State private var allGames: [GameLog] = [
        GameLog(title: "Fortnit", imageName: "Image", hours: 124, lastPlayed: "Yesterday"),
        GameLog(title: "Apex Legends", imageName: "Image", hours: 87, lastPlayed: "2 days ago"),
        GameLog(title: "Valorant", imageName: "Image", hours: 45, lastPlayed: "Last week"),
        GameLog(title: "Overwatch 2", imageName: "Image", hours: 33, lastPlayed: "3 weeks ago"),
        GameLog(title: "Rocket League", imageName: "Image", hours: 72, lastPlayed: "1 month ago")
    ]

    private var filteredGames: [GameLog] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allGames }
        return allGames.filter { $0.title.localizedCaseInsensitiveContains(trimmed) }
    }

    var body: some View {
        ZStack {
            AppBackground {
                VStack(spacing: 0) {
                    // Header
                    Text("Search")
                        .foregroundStyle(.white)
                        .font(.largeTitle.weight(.bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                    // Search field
                    SearchBar(text: $query)
                        .padding(.horizontal, 16)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    // Results
                    if filteredGames.isEmpty {
                        VStack(spacing: 12) {
                            Text("No results")
                                .foregroundStyle(.white.opacity(0.9))
                                .font(.headline)
                            Text("Try a different game name.")
                                .foregroundStyle(.white.opacity(0.7))
                                .font(.subheadline)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 40)
                    } else {
                        ScrollView {
                            VStack(spacing: 12) {
                                ForEach(filteredGames) { game in
                                    GameRow(game: game)
                                        .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 24)
                        }
                    }
                }
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    @FocusState private var isFocused: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.white.opacity(0.8))

            TextField("Search games", text: $text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .foregroundStyle(.white)
                .focused($isFocused)

            if !text.isEmpty {
                Button {
                    text = ""
                    isFocused = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.white.opacity(0.8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    SearchView()
}
