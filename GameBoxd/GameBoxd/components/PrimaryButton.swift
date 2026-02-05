import SwiftUI

struct PrimaryButton: View {
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
                            Color.purple,
                            Color.blue
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

#Preview("PrimaryButton Variants") {
    VStack(spacing: 16) {
       
        PrimaryButton(title: "Get Started") { }
        PrimaryButton(title: "Longer Title to Test Layout") { }
    }
    .padding()
    .background(Color(.systemBackground)) // or your AppBackground if desired
}
