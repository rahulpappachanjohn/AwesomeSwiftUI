//
//  ParticleCloud.swift
//  Custom Animations
//
//  Created by Rahul P John on 12/11/24.
//

import SwiftUI
import MetalKit

struct ParticleCloud: UIViewRepresentable {
    let center: CGPoint?
    let progress: Float
    
    private let metalView = MTKView()
    
    func makeUIView(context: Context) -> MTKView {
        context.coordinator.progress = progress
        return metalView
    }
    
    func updateUIView(_ view: MTKView, context: Context) {
        context.coordinator.progress = progress
        
        guard let center else { return }
        
        let bounds = view.bounds
        
        context.coordinator.center = CGPoint(
            x: center.x / bounds.width,
            y: center.y / bounds.height
        )
    }
    
    func makeCoordinator() -> Renderer {
        Renderer(metalView: metalView)
    }
}
