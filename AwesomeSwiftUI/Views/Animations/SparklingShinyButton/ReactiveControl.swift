//
//  ReactiveControl.swift
//  Custom Animations
//
//  Created by Rahul P John on 12/11/24.
//

import SwiftUI

struct ReactiveControl: View {
    
    private enum DragState {
        case inactive, dragging
    }
    
    @GestureState private var dragState: DragState = .inactive
    @State var dragLocation: CGPoint?
    @State private var glowAnimationID: UUID?
    
    @State private var rippleAnimationID: UUID?
    @State private var rippleLocation: CGPoint?
    
    @State private var isEnable: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Capsule()
                    .fill(Color.black)
                    .keyframeAnimator(
                        initialValue: 0,
                        trigger: rippleAnimationID,
                        content: { view, elapsedTime in
                            view.modifier(
                                RippleModifier(
                                    origin: rippleLocation ?? .zero,
                                    elapsedTime: elapsedTime,
                                    duration: 1.0,
                                    amplitude: 2.0,
                                    frequency: 4.0,
                                    decay: 10.0,
                                    speed: 800.0
                                )
                            )
                        },
                        keyframes: { _ in
                            MoveKeyframe(.zero)
                            LinearKeyframe(
                                1.0,
                                duration: 2.0
                            )
                        }
                    )
                    .sensoryFeedback(
                        .impact,
                        trigger: rippleAnimationID
                    )
                KeyframeAnimator(
                    initialValue: 0.0,
                    trigger: glowAnimationID
                ) { value in
                    ParticleCloud(
                        center: dragLocation,
                        progress: Float(value)
                    )
                    .clipShape(Capsule())
                } keyframes: { _ in
                    if glowAnimationID != nil {
                        MoveKeyframe(.zero)
                        LinearKeyframe(
                            1.0,
                            duration: 0.4
                        )
                    } else {
                        MoveKeyframe(1.0)
                        LinearKeyframe(
                            .zero,
                            duration: 0.4
                        )
                    }
                }
                Capsule()
                    .strokeBorder(Color.white, style: .init(lineWidth: 1))
                Capsule()
                    .glow(fill: .palette, lineWidth: 4.0)
                    .keyframeAnimator(
                        initialValue: .zero,
                        trigger: glowAnimationID,
                        content: { view, elapsedTime in
                            view.modifier(
                                ProgressiveGlow(
                                    origin: dragLocation ?? .zero,
                                    progress: elapsedTime
                                )
                            )
                        },
                        keyframes: { _ in
                            if glowAnimationID != nil {
                                MoveKeyframe(.zero)
                                LinearKeyframe(
                                    1.0,
                                    duration: 0.4
                                )
                            } else {
                                MoveKeyframe(1.0)
                                LinearKeyframe(
                                    .zero,
                                    duration: 0.4
                                )
                            }
                        }
                    )
                Text("Click Me")
                    .foregroundStyle(Color.white.opacity(isEnable ? 0.15 : 1.0))
                    .font(.callout.bold())
            }
            .gesture(
                DragGesture(minimumDistance: .zero)
                    .updating(
                        $dragState,
                        body: { gesture, state, _ in
                            switch state {
                            case .inactive:
                                withAnimation(Animation.linear(duration: 0.25)) {
                                    isEnable = true
                                }
                                rippleAnimationID = UUID()
                                rippleLocation = gesture.location
                                dragLocation = gesture.location
                                glowAnimationID = UUID()
                                state = .dragging
                            case .dragging:
                                let location = gesture.location
                                let size = proxy.size
                                dragLocation = CGPoint(
                                    x: location.x.clamp(
                                        min: .zero,
                                        max: size.width
                                    ),
                                    y: location.y.clamp(
                                        min: .zero,
                                        max: size.height
                                    )
                                )
                            }
                        }
                    )
                    .onEnded { _ in
                        withAnimation(Animation.linear(duration: 0.25)) {
                            isEnable = false
                        }
                        glowAnimationID = nil
                    }
            )
        }
    }
}

struct ProgressiveGlow: ViewModifier {
    let origin: CGPoint
    let progress: Double
    func body(content: Content) -> some View {
        content.visualEffect { view, proxy in
            view.colorEffect(
                ShaderLibrary.default.glow(
                    .float2(origin),
                    .float2(proxy.size),
                    .float(3.0),
                    .float(progress)
                )
            )
        }
    }
}

struct RippleModifier: ViewModifier {
    let origin: CGPoint
    let elapsedTime: TimeInterval
    let duration: TimeInterval
    let amplitude: Double
    let frequency: Double
    let decay: Double
    let speed: Double
    
    func body(content: Content) -> some View {
        let shader = ShaderLibrary.default.ripple(
            .float2(origin),
            .float(elapsedTime),
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )
        let maxSampleOffset = CGSize(
            width: amplitude,
            height: amplitude
        )
        let elapsedTime = elapsedTime
        let duration = duration
        
        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0...duration ~= elapsedTime
            )
        }
    }
}


extension Comparable where Self: AdditiveArithmetic {
    func clamp(min: Self, max: Self) -> Self {
        if self < min { return min }
        if self > max { return max }
        return self
    }
}

extension View where Self: Shape {
    func glow(
        fill: some ShapeStyle,
        lineWidth: Double,
        blurRadius: Double = 8.0,
        lineCap: CGLineCap = .round
    ) -> some View {
        self
            .stroke(style: StrokeStyle(lineWidth: lineWidth / 2, lineCap: lineCap))
            .fill(fill)
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius)
            }
            .overlay {
                self
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: lineCap))
                    .fill(fill)
                    .blur(radius: blurRadius / 2)
            }
    }
}

extension ShapeStyle where Self == AngularGradient {
    static var palette: some ShapeStyle {
        .angularGradient(
            stops: [
                .init(color: .blue, location: 0.0),
                .init(color: .purple, location: 0.2),
                .init(color: .red, location: 0.4),
                .init(color: .mint, location: 0.5),
                .init(color: .indigo, location: 0.7),
                .init(color: .pink, location: 0.9),
                .init(color: .blue, location: 1.0),
            ],
            center: .center,
            startAngle: Angle(radians: .zero),
            endAngle: Angle(radians: .pi * 2)
        )
    }
}
