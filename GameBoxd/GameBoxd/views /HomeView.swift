import Foundation
import SwiftUI

struct HomeView: View {
    @State private var userName: String = "Hanson"

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            // Header
                            HStack(alignment: .center) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Welcome back,")
                                        .foregroundStyle(.white.opacity(0.8))
                                        .font(.subheadline)
                                    Text(userName)
                                        .foregroundStyle(.white)
                                        .font(.largeTitle.weight(.bold))
                                }
                                Spacer()
                                HStack(spacing: 12) {
                                    NavigationLink {
                                        NotificationsView()
                                    } label: {
                                        Circle()
                                            .fill(Color.black.opacity(0.25))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "bell")
                                                    .foregroundStyle(.white)
                                            )
                                            .overlay(
                                                Circle().stroke(
                                                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                    lineWidth: 1
                                                )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                    NavigationLink {
                                        SettingsView()
                                    } label: {
                                        Circle()
                                            .fill(Color.black.opacity(0.25))
                                            .frame(width: 36, height: 36)
                                            .overlay(
                                                Image(systemName: "gearshape")
                                                    .foregroundStyle(.white)
                                            )
                                            .overlay(
                                                Circle().stroke(
                                                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                                                    lineWidth: 1
                                                )
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 8)

                            // Featured Hero
                            FeaturedHero(imageName: "Image")
                                .padding(.horizontal, 16)

                            // Sections
                            SectionHeader(title: "Trending")
                                .padding(.horizontal, 16)
                            HorizontalGamesRow(items: demoGames)

                            SectionHeader(title: "Recommended")
                                .padding(.horizontal, 16)
                            HorizontalGamesRow(items: demoGames.shuffled())

                            SectionHeader(title: "Recently Played")
                                .padding(.horizontal, 16)
                            HorizontalGamesRow(items: demoGames.shuffled())

                            Spacer(minLength: 24)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Components
struct SectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .foregroundStyle(.white)
                .font(.title2.weight(.bold))
            Spacer()
            Button {
                // TODO: See all action
            } label: {
                Text("See all")
                    .foregroundStyle(.white.opacity(0.8))
                    .font(.subheadline.weight(.medium))
            }
            .buttonStyle(.plain)
        }
    }
}

struct FeaturedHero: View {
    let imageName: String
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            Image(imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 200)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
        }
    }
}

struct HorizontalGamesRow: View {
    let items: [GameItem]
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(items) { item in
                    GameCard(title: item.title, imageName: item.imageName)
                        .frame(width: 130)
                }
            }
            .padding(.horizontal, 16)
        }
    }
}

struct GameCard: View {
    let title: String
    let imageName: String
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(imageName)
                .resizable()
                .aspectRatio(3/4, contentMode: .fill)
                .frame(height: 160)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
        }
    }
}

struct GameItem: Identifiable {
    let id = UUID()
    let title: String
    let imageName: String
}

private let demoGames: [GameItem] = [
    GameItem(title: "Minecraft", imageName: "minecraft"),
    GameItem(title: "Doom", imageName: "doom"),
    GameItem(title: "Fortnite", imageName: "Image"),
    GameItem(title: "Overwatch 2", imageName: "Image"),
    GameItem(title: "Rocket League", imageName: "Image")
]

#Preview {
    HomeView()
}

