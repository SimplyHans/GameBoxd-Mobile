import SwiftUI

struct ButtonWithNoBackGround: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .foregroundStyle(Color.bwnbg)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
               .cornerRadius(14)
               
        }
        
        
    }
    
}

#Preview("PrimaryButton Variants") {
    VStack(spacing: 16) {
       
        ButtonWithNoBackGround(title: "Create An Account") { }
      
    }
    .padding()
    .background(Color(.systemBackground))
}
