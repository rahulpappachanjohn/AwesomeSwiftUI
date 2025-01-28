//
//  ColorSwatchView.swift
//  AwesomeSwiftUI
//
//  Created by Rahul P John on 24/01/25.
//

import SwiftUI

struct ColorSwatchView: View {
    @State private var offset = CGSize.zero
    @State private var rotationAngle: Double = 0 // Angle in degrees
    @State private var dragOffset: CGSize = .zero
    @State private var startDragPoint: CGPoint = .zero
//    private var rotateView: some Gesture {
//        DragGesture()
//            .onChanged { gesture in
//                if gesture.translation.width < 20 {
//                    withAnimation(.spring(duration: 0.5, bounce: 0.5, blendDuration: 0.4)) {
//                        offset = gesture.translation
//                    }
//                } else if gesture.translation.width < 0 {
//                    withAnimation(.spring(duration: 0.5, bounce: 0.5, blendDuration: 0.4)) {
//                        offset = .zero
//                    }
//                }
//            }
//    }
    
    private var rotateView: some Gesture {
        DragGesture()
            .onChanged { value in
                // Track the starting point of the drag
                if startDragPoint == .zero {
                    startDragPoint = value.location
                }
                
                // Calculate the angle relative to the starting point
                let dx = value.location.x - startDragPoint.x
                let dy = value.location.y - startDragPoint.y
                
                // Calculate the angle using atan2
                let angle = atan2(dy, dx) * 180 / .pi // Convert radians to degrees
                
                // Restrict the angle between 0 and 20 degrees
                var restrictedAngle = max(0, min(angle, 20))
                
                // If the drag is reversed, decrease the angle to 0
                if dx < 0 && dy < 0 { restrictedAngle = 0 }
                
                withAnimation(.bouncy) {
                    // Update the rotation angle
                    rotationAngle = restrictedAngle
                }
                
                // Update the drag offset (optional for showing the drag distance)
                dragOffset = value.translation
            }
            .onEnded { _ in
                // Reset the start point when the drag ends
                startDragPoint = .zero
                dragOffset = .zero
            }
    }
    
    var body: some View {
        VStack {
            ZStack {
                ForEach(0..<6) { index in
                    VStack(spacing: 0.0) {
                        ForEach(0..<3) { index in
                            RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                                .fill(index % 2 == 0 ? Color.orange : Color.gray)
                                .frame(width: 30.0, height: 40.0)
                                .padding(2)
                            
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 5.0, style: .continuous)
                            .fill(Color.white)
                    )
                    .rotationEffect(.init(degrees: Double(index) * rotationAngle), anchor: .bottom)
                    .gesture(
                        rotateView
                    )
                }
            }
            .padding(40.0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        .background(
            Color.black
        )
    }
}

#Preview {
    ContentView()
}
