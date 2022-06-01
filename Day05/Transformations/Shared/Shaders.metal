//
//  Shaders.metal
//  Transformations
//
//  Created by Pham Nghia on 2022/06/01.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

struct VertexOut {
  float4 position [[position]];
};

vertex VertexOut vertex_main(
  VertexIn in [[stage_in]],
  constant float4x4 &matrix [[buffer(11)]])
{
  float4 translation = matrix * in.position;
  VertexOut out {
    .position = translation
  };
  return out;
}

fragment float4 fragment_main(
  constant float4 &color [[buffer(0)]])
{
  return color;
}
