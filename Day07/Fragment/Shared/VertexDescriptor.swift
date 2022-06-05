//
//  VertexDescriptor.swift
//  Fragment
//
//  Created by Pham Nghia on 2022/06/04.
//

import MetalKit

extension MTLVertexDescriptor {
  static var defaultLayout: MTLVertexDescriptor? {
    MTKMetalVertexDescriptorFromModelIO(.defaultLayout)
  }
}

extension MDLVertexDescriptor {
  static var defaultLayout: MDLVertexDescriptor {
    let vertexDescriptor = MDLVertexDescriptor()
    var offset = 0

    // Position
    vertexDescriptor.attributes[0] = MDLVertexAttribute(
      name: MDLVertexAttributePosition,
      format: .float3,
      offset: 0,
      bufferIndex: 0)
    offset += MemoryLayout<float3>.stride

    // Normals
    vertexDescriptor.attributes[1] = MDLVertexAttribute(
      name: MDLVertexAttributeNormal,
      format: .float3,
      offset: offset,
      bufferIndex: 0)
    offset += MemoryLayout<float3>.stride

    vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: offset)
    return vertexDescriptor
  }
}

extension Attributes {
  var index: Int {
    return Int(self.rawValue)
  }
}

extension BufferIndices {
  var index: Int {
    return Int(self.rawValue)
  }
}
