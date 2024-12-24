import SwiftUI

struct AppEnvironmentView: View {
    let isSandboxEnvironment = AppUtils.detectSandboxEnvironment()
    var body: some View {
        Group {
            if isSandboxEnvironment {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Important")
                            .font(.system(size: 12))
                            .foregroundColor(Theme.orange)
                        
                        Text("You are using a Sandbox Environment. Transactions made here are for testing purposes only and will not result in actual changes.")
                            .font(.system(size: 12))
                            .lineSpacing(4)
                            .foregroundColor(Theme.secondary)
                    }
                }
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Theme.orangeBorder, lineWidth: 1)
                )
                .background(Theme.orangeLight)
            }
        }
    }
}
