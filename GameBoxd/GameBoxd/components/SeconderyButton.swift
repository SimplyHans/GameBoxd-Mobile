import SwiftUI

struct SeconderyButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [
                            Color("sbc")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
        }
        
        
    }
    
}

struct SeconderyButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            SeconderyButton(title: "Cancel") { }
            SeconderyButton(title: "Back") { }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
