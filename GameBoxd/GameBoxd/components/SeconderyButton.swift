import SwiftUI

struct SeconderyButton: View {
    let title: String
    let action: () -> Void
    let gradientColors: [Color]

    init(title: String, colors: [Color] = [Color.blue, Color.purple], action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.gradientColors = colors
    }

    init(title: String, startColor: Color, endColor: Color, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        self.gradientColors = [startColor, endColor]
    }

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(14)
        }
        
        
    }
    
}

#Preview("SecondaryButton Variants with Pickers") {
    struct PreviewHost: View {
        @State private var start = Color.blue
        @State private var end = Color.purple

        var body: some View {
            VStack(spacing: 16) {
                // Live color pickers
                HStack {
                    VStack(alignment: .leading) {
                        Text("Start Color").font(.caption)
                        ColorPicker("", selection: $start)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading) {
                        Text("End Color").font(.caption)
                        ColorPicker("", selection: $end)
                            .labelsHidden()
                    }
                }

                SeconderyButton(title: "Cancel", startColor: start, endColor: end) { }
                SeconderyButton(title: "Back", colors: [start, end]) { }
                // Default colors
                SeconderyButton(title: "Default Colors") { }
            }
            .padding()
            .background(Color(.systemBackground))
        }
    }
    return PreviewHost()
}
