import SwiftUI

struct GameArtworkView: View {
    let game: HomeGame

    var body: some View {
        Group {
            if let imageURL = game.imageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        fallbackArtwork
                    }
                }
            } else {
                fallbackArtwork
            }
        }
    }

    private var fallbackArtwork: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.surfaceRaised,
                    AppTheme.backgroundTop
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Image(game.imageName)
                .resizable()
                .scaledToFill()
                .opacity(0.92)

            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.34)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }
}
