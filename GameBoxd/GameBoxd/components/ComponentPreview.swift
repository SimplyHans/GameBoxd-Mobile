import SwiftUI

struct ComponentPreview: View {
    @State private var text = ""

    var body: some View {
        AppBackground {
            VStack(spacing: 20) {
                Text("GameBoxd")
                    .foregroundStyle(.white)
                

                AppTextField(placeholder: "Email", text: $text)
                    
                PrimaryButton(title: "Continue") {}

                CardView {
                    Text("Reusable Card")
                        .foregroundColor(.white)
                }
            }
            
        }
    }
}

#Preview {
    ComponentPreview()
}
