import SwiftUI

struct AppTextField: View {
    let placeholder: String
    @Binding var text: String
    var isSecure = false

    var body: some View {
        Group {
            if isSecure {
                // Use SecureField with prompt-like styling
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.white.opacity(0.1))
                            .padding(.horizontal, 16)
                    }
                    SecureField("", text: $text)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            } else {
                
                ZStack(alignment: .leading) {
                    if text.isEmpty {
                        Text(placeholder)
                            .foregroundStyle(.white.opacity(0.5))
                            .padding(.horizontal, 16)
                            
                    }
                    TextField("", text: $text)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                }
            }
        }
        .background(Color(red: 30/255, green: 33/255, blue: 50/255))
        .cornerRadius(12)
        .padding(2)
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    LinearGradient(colors: [ .purple ,.blue], startPoint: .leading, endPoint: .trailing),
                    lineWidth: 2
                )
        )
    }
}
