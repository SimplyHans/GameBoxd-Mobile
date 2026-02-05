import SwiftUI

struct AppBackground<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        LinearGradient(
            colors: [
                Color(red: 14/255, green: 18/255, blue: 30/255),
                Color(red: 20/255, green: 12/255, blue: 40/255)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        .overlay(content)
    }
}


