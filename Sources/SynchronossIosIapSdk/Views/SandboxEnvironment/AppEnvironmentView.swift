import SwiftUI

struct AppEnvironmentView: View {
    let isSandboxEnvironment = AppUtils.detectSandboxEnvironment()
    var body: some View {
        Group {
            if isSandboxEnvironment {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "info.circle")
                        .font(Theme.font(size: 14))
                        .foregroundColor(Theme.warningPrimary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Important")
                            .font(Theme.font(size: 12))
                            .foregroundColor(Theme.warningPrimary)
                        
                        Text("You are using a Sandbox Environment. Transactions made here are for testing purposes only and will not result in actual changes.")
                            .font(Theme.font(size: 12))
                            .lineSpacing(4)
                            .foregroundColor(Theme.textSecondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.warningSecondary)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Theme.warningTertiary, lineWidth: 1)
                        )
                )
            }
        }
        .padding()
    }
}

