//
//  SwiftUIView.swift
//  SynchronossIosIapSdk
//
//  Created by Monisankar Nath on 23/12/24.
//

import SwiftUI

struct ProductListSkeleton: View {
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                VStack(spacing: 15) {
                    Circle()
                        .fill(Color(white: 0.9))
                        .frame(height: 120)
                        .shimmer()
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.6))
                        .frame(width: 150, height: 14)
                        .cornerRadius(8)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: 100, height: 14)
                        .cornerRadius(8)
                }
                .padding(.top, 20)
                
                ForEach(0..<3) { _ in
                    SkeletonCard()
                }
            }
            .padding()
        }
    }
}

struct SkeletonCard: View {
    var body: some View {
        
        ZStack(alignment: .topLeading) {
            Rectangle()
                .fill(Color(white: 0.9))
                .frame(height: 150)
                .cornerRadius(8)
                .shimmer()
            
            VStack(alignment: .leading, spacing: 14) {
                Rectangle()
                    .fill(Color.gray.opacity(0.8))
                    .frame(width: 200, height: 16)
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.6))
                    .frame(width: 150, height: 14)
                    .cornerRadius(8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 100, height: 14)
                    .cornerRadius(8)
            }
            .padding(30)
        }
        
    }
}

extension View {
    /// Use this convenience method to apply the shimmer effect to any View
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

struct ShimmerEffect: ViewModifier {
    @State private var move: CGFloat = -1.0
    
    /// Duration of the shimmer animation in seconds
    var duration: Double = 1.2
    
    /// The angle (in degrees) at which the shimmer gradient is rotated
    var angle: Double = 20.0
    
    /// The maximum and minimum opacities for the shimmer gradient
    var opacityHigh: Double = 0.6
    var opacityLow: Double = 0.3
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    let width  = geometry.size.width
                    let height = geometry.size.height
                    
                    // Build a vertical gradient that we'll rotate
                    let gradient = LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(opacityLow),
                            Color.white.opacity(opacityHigh),
                            Color.white.opacity(opacityLow)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    
                    Rectangle()
                        .fill(gradient)
                    // Slight rotation for a diagonal shimmer line
                        .rotationEffect(.degrees(angle))
                    // Make the shimmer rectangle large enough
                        .frame(width: width / 2, height: height * 2)
                    // Translate it across the entire card
                        .offset(x: move * 2 * width)
                }
                    .mask(content)  // Mask the shimmer overlay to the shape of the original content
            )
            .onAppear {
                withAnimation(Animation.linear(duration: duration).repeatForever(autoreverses: false)) {
                    // Move from -1.0 (far left) to +1.0 (far right)
                    self.move = 1.0
                }
            }
    }
}

#Preview {
    ProductListSkeleton()
}
