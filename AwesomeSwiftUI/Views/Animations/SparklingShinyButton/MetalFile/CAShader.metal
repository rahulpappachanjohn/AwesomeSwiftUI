//
//  CAShader.metal
//  Custom Animations
//
//  Created by Rahul P John on 12/11/24.
//

#include <SwiftUI/SwiftUI.h>
#include <metal_stdlib>

using namespace metal;

[[stitchable]] half4 glow(float2 position, half4 color, float2 origin, float2 size, float amplitude, float progress) {
    float2 uv_position = position / size;
    float2 uv_origin = origin / size;
    float distance = length(uv_position - uv_origin);
    float glowIntensity = smoothstep(0.0, 1.0, progress) * exp(-distance * distance) * amplitude;
    glowIntensity *= smoothstep(0.0, 1.0, (1.0 - distance / progress));
    return color * glowIntensity;
}

[[ stitchable ]]
half4 ripple(float2 position, SwiftUI::Layer layer, float2 origin, float time, float amplitude, float frequency, float decay, float speed) {
  // The distance of the current pixel position from `origin`.
  float distance = length(position - origin);

  // The amount of time it takes for the ripple to arrive at the current pixel position.
  float delay = distance / speed;

  // Adjust for delay, clamp to 0.
  time = max(0.0, time - delay);

  // The ripple is a sine wave that Metal scales by an exponential decay function.
  float rippleAmount = amplitude * sin(frequency * time) * exp(-decay * time);

  // A vector of length `amplitude` that points away from position.
  float2 direction = normalize(position - origin);

  // Scale `n` by the ripple amount at the current pixel position and add it
  // to the current pixel position.
  //
  // This new position moves toward or away from `origin` based on the
  // sign and magnitude of `rippleAmount`.
  float2 newPosition = position + rippleAmount * direction;

  // Sample the layer at the new position.
  half4 color = layer.sample(newPosition);

  // Lighten or darken the color based on the ripple amount and its alpha component.
  color.rgb += (rippleAmount / amplitude) * color.a;

  return color;
}

struct Particle {
  float4 color;
  float radius;
  float lifespan;
  float2 position;
  float2 velocity;
};

struct ParticleCloudInfo {
  float2 center;
  float progress;
};

float rand(int passSeed)
{
  int seed = 57 + passSeed * 241;
  seed = (seed << 13) ^ seed;
  seed = (seed * (seed * seed * 15731 + 789221) + 1376312589) & 2147483647;
  seed = (seed * (seed * seed * 48271 + 39916801) + 2147483647) & 2147483647;
  return ((1.f - (seed / 1073741824.0f)) + 1.0f) / 2.0f;
}

kernel void cleanScreen (
  texture2d<half, access::write> output [[ texture(0) ]],
  uint2 id [[ thread_position_in_grid ]]
) {
  output.write(half4(0), id);
}

kernel void drawParticles (
  texture2d<half, access::write> output [[ texture(0) ]],
  device Particle *particles [[ buffer(0) ]],
  constant ParticleCloudInfo &info [[ buffer(1) ]],
  uint id [[ thread_position_in_grid ]]
) {
  float2 uv_center = info.center;

  float width = output.get_width();
  float height = output.get_height();

    float2 center = float2(width * uv_center.x, height * uv_center.y);
    Particle particle = particles[id];
    
    float lifespan = particle.lifespan;
    float2 position = particle.position;
    float2 velocity = particle.velocity;
    
    if (
        length(center - position) < 20.0 ||
        position.x == 0.0 && position.y == 0.0 ||
        lifespan > 100
        ) {
            position = float2(rand(id) * width, rand(id + 1) * height);
            lifespan = 0;
        } else {
            float2 direction = normalize(center - position);
            position += direction * length(velocity);
            lifespan += 1;
        }
    
    particle.lifespan = lifespan;
    particle.position = position;
    
    particles[id] = particle;
    half4 color = half4(particle.color) * (lifespan / 100) * info.progress;
    uint2 pos = uint2(position.x, position.y);
    
    for (int y = -100; y < 100; y++) {
        for (int x = -100; x < 100; x++) {
            float s_radius = x * x + y * y;
            if (sqrt(s_radius) <= particle.radius * info.progress) {
                output.write(color, pos + uint2(x, y));
            }
        }
    }
}
