//
//  Shaders.metal
//  Pipeline
//
//  Created by Pham Nghia on 2022/05/31.
//

#include <metal_stdlib>
using namespace metal;

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertexIn [[stage_in]]) {
  float4 position = vertexIn.position;
  position.y -= 1.0;
  return position;
}

fragment float4 fragment_main() {
  return float4(1, 0, 1, 1);
}
