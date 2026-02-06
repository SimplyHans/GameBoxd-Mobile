//
//  FeedView.swift
//  GameBoxd
//
//  Created by Hussein on 2026-02-05.
//

import Foundation
import SwiftUI

struct FeedView: View {
    @State private var posts: [FeedPost] = FeedPost.sample

    var body: some View {
        ZStack {
            AppBackground {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Header
                        Text("Feed")
                            .foregroundStyle(.white)
                            .font(.largeTitle.weight(.bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
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
    }
}

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
        FeedPost(username: "Hanson", avatarSystemName: "person.fill", gameTitle: "Fortnit", imageName: "Image", caption: "New PR tonight!", isLiked: false, likeCount: 128, commentCount: 12),
        FeedPost(username: "Maya", avatarSystemName: "person.crop.circle.fill", gameTitle: "Apex Legends", imageName: "Image", caption: "Clutched a 1v3!", isLiked: true, likeCount: 342, commentCount: 29),
        FeedPost(username: "Alex", avatarSystemName: "person.circle.fill", gameTitle: "Valorant", imageName: "Image", caption: "Practicing smokes.", isLiked: false, likeCount: 57, commentCount: 6)
    ]
}

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
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
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
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
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
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.25))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(
                    LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: 1.5
                )
        )
    }
}

#Preview {
    FeedView()
}
