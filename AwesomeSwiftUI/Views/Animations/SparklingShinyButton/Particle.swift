//
//  Particle.swift
//  Custom Animations
//
//  Created by Rahul P John on 12/11/24.
//

import Foundation

struct Particle {
  let color: SIMD4<Float>
  let radius: Float
  let lifespan: Float
  let position: SIMD2<Float>
  let velocity: SIMD2<Float>
}

struct ParticleCloudInfo {
  let center: SIMD2<Float>
  let progress: Float
}
