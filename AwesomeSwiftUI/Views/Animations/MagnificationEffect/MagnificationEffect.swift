//
//  MagnificationEffect.swift
//  AwesomeSwiftUI
//
//  Created by Rahul P John on 10/01/25.
//

import SwiftUI

struct MagnificationEffect: View {
    @State private var scale: CGFloat = 1.0
    @GestureState private var isLongPressed = false
    var body: some View {
        VStack {
            Text("Magnification Effect")
                .font(.title2.bold())
                .foregroundStyle(Color.white)
            HStack {
                ForEach(0..<10) { index in
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                        .fill(Color.blue)
                        .frame(width: 25.0, height: 25.0)
                        .scaleEffect(scale)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50.0)
            .background(
                RoundedRectangle(cornerRadius: 10.0, style: .continuous)
                    .fill(Color.red)
            )
            .padding(.horizontal)
            .padding(.bottom, 1)
            .gesture(   
                LongPressGesture(minimumDuration: 1.0) // Long press for 1 second
                    .updating($isLongPressed) { value, state, _ in
                        // As the gesture updates, update the isLongPressed state
                        state = value
                    }
                    .onChanged { _ in
                        // When long press is detected, start scaling
                        self.scale = 1.5
                    }
                    .onEnded { _ in
                        // Reset the scale when the press ends
                        self.scale = 1.0
                    }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .background(
                Color.black
        )
    }
}

#Preview {
    ContentView()
}
