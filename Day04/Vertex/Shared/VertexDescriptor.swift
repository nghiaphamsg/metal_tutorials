//
//  VertexDescriptor.swift
//  Vertex
//
//  Created by Pham Nghia on 2022/06/01.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor {
    
    // Description vetex
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    
    let strideVetex = MemoryLayout<Float>.stride * 3
    vertexDescriptor.layouts[0].stride = strideVetex
    
    // Description color
    vertexDescriptor.attributes[1].format = .float3
    vertexDescriptor.attributes[1].offset = 0
    vertexDescriptor.attributes[1].bufferIndex = 1
    let strideColor = MemoryLayout<simd_float3>.stride
    vertexDescriptor.layouts[1].stride = strideColor

    return vertexDescriptor
  }
}
