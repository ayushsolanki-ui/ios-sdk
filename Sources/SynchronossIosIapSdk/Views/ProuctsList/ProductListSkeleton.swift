import SwiftUI

/// A view that displays a skeleton loader for the product list.
struct ProductListSkeleton: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                topSkeleton
                skeletonCards
            }
            .padding()
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Loading products")
    }
    
    private var topSkeleton: some View {
        VStack(spacing: 15) {
            Circle()
                .fill(Color(white: 0.9))
                .frame(height: 120)
                .shimmer()
                .accessibilityHidden(true)
            
            Rectangle()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 150, height: 14)
                .cornerRadius(8)
                .accessibilityHidden(true)
            
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 100, height: 14)
                .cornerRadius(8)
                .accessibilityHidden(true)
        }
        .padding(.top, 20)
    }

    private var skeletonCards: some View {
        ForEach(0..<3) { _ in
            SkeletonCard()
        }
    }
}

/// A view that represents a single skeleton card in the product list.
private struct SkeletonCard: View {
    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color(white: 0.9))
                .frame(height: 150)
                .cornerRadius(8)
                .shimmer()
                .accessibilityHidden(true)
            
            skeletonContent
        }
        .accessibilityHidden(true)
    }
    
    private var skeletonContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Rectangle()
                .fill(Color.gray.opacity(0.8))
                .frame(width: 200, height: 16)
                .cornerRadius(8)
                .accessibilityHidden(true)
            
            Rectangle()
                .fill(Color.gray.opacity(0.6))
                .frame(width: 150, height: 14)
                .cornerRadius(8)
                .accessibilityHidden(true)
            
            Rectangle()
                .fill(Color.gray.opacity(0.4))
                .frame(width: 100, height: 14)
                .cornerRadius(8)
                .accessibilityHidden(true)
        }
        .padding(30)
    }
}

extension View {
    /// Applies a shimmer effect to the view.
    /// - Parameters:
    ///   - duration: Duration of the shimmer animation in seconds.
    ///   - angle: The angle (in degrees) at which the shimmer gradient is rotated.
    ///   - opacityHigh: The maximum opacity for the shimmer gradient.
    ///   - opacityLow: The minimum opacity for the shimmer gradient.
    /// - Returns: A view with a shimmer effect applied.
    func shimmer(
        duration: Double = 1.5,
        angle: Double = 20.0,
        opacityHigh: Double = 0.6,
        opacityLow: Double = 0.3
    ) -> some View {
        self.modifier(
            ShimmerEffect(
                duration: duration,
                angle: angle,
                opacityHigh: opacityHigh,
                opacityLow: opacityLow
            )
        )
    }
}

/// A view modifier that adds a shimmer effect to any view.
private struct ShimmerEffect: ViewModifier {
    @State private var move: CGFloat = -1.0
    
    /// Duration of the shimmer animation in seconds.
    var duration: Double = 1.2
    
    /// The angle (in degrees) at which the shimmer gradient is rotated.
    var angle: Double = 20.0
    
    /// The maximum opacity for the shimmer gradient.
    var opacityHigh: Double = 0.6
    
    /// The minimum opacity for the shimmer gradient.
    var opacityLow: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .overlay(shimmerOverlay(content: content))
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    self.move = 1.0
                }
            }
    }
    
    private func shimmerOverlay(content: Content) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            let gradient = LinearGradient(
                gradient: Gradient(colors: [
                    Color.white.opacity(opacityLow),
                    Color.white.opacity(opacityHigh),
                    Color.white.opacity(opacityLow)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            return Rectangle()
                .fill(gradient)
                .rotationEffect(.degrees(angle))
                .frame(width: width / 2, height: height * 2)
                .offset(x: move * 2 * width)
        }
    }
}