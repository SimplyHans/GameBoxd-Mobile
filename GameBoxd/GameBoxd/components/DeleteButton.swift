import SwiftUI

struct DeleteButton: View {
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
                            Color.red
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

struct DeleteButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DeleteButton(title: "Delete") { }
            DeleteButton(title: "Remove") { }
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
