import SwiftUI

struct AppEnvironmentView: View {
    let isSandboxEnvironment = AppUtils.detectSandboxEnvironment()
    var body: some View {
        Group {
            if isSandboxEnvironment {
                Text("Important: You are using a Sandbox Environment. Transactions made here are for testing purposes only and will not result in actual charges.")
                    .font(.body)
                    .fontWeight(.light)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4) // Adjust spacing between lines
                    .frame(maxWidth: .infinity, alignment: .center) // Ensures the text is spread evenly
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .shadow(radius: 4)

            }
        }
    }
}
