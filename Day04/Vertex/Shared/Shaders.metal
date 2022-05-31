//
//  Shaders.metal
//  Vertex
//
//  Created by Pham Nghia on 2022/05/31.
//

#include <metal_stdlib>
using namespace metal;

// [[attribute(0)]] is the attribute in the vertex descriptor that describes the position.
// [[attribute(1)]] is the attribute in the vertex descriptor that describes the color.
struct VertexIn {
  float4 position [[attribute(0)]];
  float4 color [[attribute(1)]];
};

// [[point_size]] is the attribute in drawIndexedPrimitives() type = ".point"
struct VertexOut {
  float4 position [[position]];
  float4 color;
  float pointSize [[point_size]];
};

// You describe each per-vertex input with the [[stage_in]] attribute.
// The GPU now looks at the pipeline state’s vertex descriptor.
//vertex float4 vertex_main(
//  VertexIn input [[stage_in]],
//  constant float &timer [[buffer(11)]])
//{
//  input.position.y += timer;
//  return input.position;
//}

vertex VertexOut vertex_main(
  VertexIn input [[stage_in]],
  constant float &timer [[buffer(11)]]) {
    
    // Set timer
    input.position.y += timer;

    VertexOut output {
      .position = input.position,
      .color = input.color,
      .pointSize = 30
    };
  return output;
}

fragment float4 fragment_main(VertexOut input [[stage_in]]) {
  return input.color;
}
