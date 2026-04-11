import SwiftUI

struct AppBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppTheme.backgroundTop,
                    AppTheme.backgroundBottom,
                    AppTheme.backgroundBase
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(AppTheme.accent.opacity(0.18))
                .frame(width: 260, height: 260)
                .blur(radius: 80)
                .offset(x: 120, y: -250)

            Circle()
                .fill(AppTheme.accentSecondary.opacity(0.15))
                .frame(width: 300, height: 300)
                .blur(radius: 100)
                .offset(x: -140, y: 320)

            LinearGradient(
                colors: [Color.clear, AppTheme.backgroundBase.opacity(0.55)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
        .overlay(content)
    }
}

