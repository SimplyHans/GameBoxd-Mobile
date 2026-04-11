import Foundation
import SwiftUI

struct FeedView: View {
    @State private var posts: [FeedPost] = FeedPost.sample
    @State private var showCreatePost = false

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {

                        // Header with + button
                        HStack {
                            Text("Feed")
                                .foregroundStyle(.white)
                                .font(.largeTitle.weight(.bold))

                            Spacer()

                            Button {
                                showCreatePost = true
                            } label: {
                                Image(systemName: "plus")
                                    .foregroundStyle(.white)
                                    .font(.title2.weight(.bold))
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 8)

                        // Posts
                        VStack(spacing: 16) {
                            ForEach($posts) { $post in
                                PostCard(post: $post)
                                    .padding(.horizontal, 16)
                            }
                        }
                        .padding(.bottom, 24)
                    }
                }
            }
        }
        .sheet(isPresented: $showCreatePost) {
            CreatePostView { newPost in
                posts.insert(newPost, at: 0)
            }
        }
    }
}

// MARK: - Model
struct FeedPost: Identifiable {
    let id = UUID()
    let username: String
    let avatarSystemName: String
    let gameTitle: String
    let imageName: String
    var caption: String
    var isLiked: Bool
    var likeCount: Int
    var commentCount: Int

    static let sample: [FeedPost] = [
        FeedPost(username: "Hanson", avatarSystemName: "person.fill", gameTitle: "Fortnite", imageName: "Image", caption: "New PR tonight!", isLiked: false, likeCount: 128, commentCount: 12),
        FeedPost(username: "Maya", avatarSystemName: "person.crop.circle.fill", gameTitle: "Apex Legends", imageName: "Image", caption: "Clutched a 1v3!", isLiked: true, likeCount: 342, commentCount: 29),
        FeedPost(username: "Alex", avatarSystemName: "person.circle.fill", gameTitle: "Valorant", imageName: "Image", caption: "Practicing smokes.", isLiked: false, likeCount: 57, commentCount: 6)
    ]
}

// MARK: - Post Card
struct PostCard: View {
    @Binding var post: FeedPost

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {

            // Header
            HStack(spacing: 12) {
                Circle()
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle().stroke(
                            LinearGradient(colors: [Color.purple, Color.blue],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1
                        )
                    )
                    .overlay(
                        Image(systemName: post.avatarSystemName)
                            .foregroundStyle(.white)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(post.username)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(post.gameTitle)
                        .font(.footnote)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()
            }

            // Image
            Image(post.imageName)
                .resizable()
                .scaledToFill()
                .frame(height: 220)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(colors: [Color.purple, Color.blue],
                                           startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 2
                        )
                )

            // Caption
            if !post.caption.isEmpty {
                Text(post.caption)
                    .foregroundStyle(.white)
                    .font(.subheadline)
            }

            // Actions
            HStack(spacing: 16) {
                Button {
                    post.isLiked.toggle()
                    post.likeCount += post.isLiked ? 1 : -1
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: post.isLiked ? "heart.fill" : "heart")
                            .foregroundStyle(post.isLiked ? .red : .white)

                        Text("\(post.likeCount)")
                            .foregroundStyle(.white)
                            .font(.subheadline)
                    }
                }
                .buttonStyle(.plain)

                HStack(spacing: 6) {
                    Image(systemName: "bubble.right")
                        .foregroundStyle(.white)

                    Text("\(post.commentCount)")
                        .foregroundStyle(.white)
                        .font(.subheadline)
                }

                Spacer()

                Text("Just now")
                    .foregroundStyle(.white.opacity(0.6))
                    .font(.footnote)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue],
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
    }
}

// MARK: - Create Post Modal
struct CreatePostView: View {
    @Environment(\.dismiss) var dismiss

    @State private var caption = ""
    @State private var selectedGame = "Fortnite"
    @State private var selectedImage = "Image"

    let games = ["Fortnite", "Apex Legends", "Valorant", "Call of Duty"]

    var onPost: (FeedPost) -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {

                // Image preview (placeholder)
                Image(selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(12)

                // Caption
                TextField("", text: $caption, prompt: Text("Write a caption...")
                    .foregroundStyle(.white.opacity(0.6)) 
                )
                .foregroundStyle(.white)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)

                // Game dropdown
                Picker("Select Game", selection: $selectedGame) {
                    ForEach(games, id: \.self) { game in
                        Text(game)
                    }
                }
                .pickerStyle(.menu)

                Spacer()
            }
            .padding()
            .background(Color(red: 24/255, green: 28/255, blue: 44/255))
            .navigationTitle("New Post")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") {
                        let newPost = FeedPost(
                            username: "You",
                            avatarSystemName: "person.fill",
                            gameTitle: selectedGame,
                            imageName: selectedImage,
                            caption: caption,
                            isLiked: false,
                            likeCount: 0,
                            commentCount: 0
                        )

                        onPost(newPost)
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
#Preview {
    FeedView()
}
