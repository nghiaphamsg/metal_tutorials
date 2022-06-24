//
//  Model.swift
//  Lighting
//
//  Created by Pham Nghia on 2022/06/19.
//

import MetalKit

class Model: Transformable {
  var transform = Transform()
  let meshes: [Mesh]
  var tiling: UInt32 = 1
  var name: String

  init(device: MTLDevice, name: String) {
    guard let assetURL = Bundle.main.url(
      forResource: name,
      withExtension: nil)
    else {
      fatalError("Model: \(name) not found")
    }

    let allocator = MTKMeshBufferAllocator(device: device)
    let asset = MDLAsset(
      url: assetURL,
      vertexDescriptor: .defaultLayout,
      bufferAllocator: allocator)
    let (mdlMeshes, mtkMeshes) = try! MTKMesh.newMeshes(
      asset: asset,
      device: Renderer.device)
    meshes = zip(mdlMeshes, mtkMeshes).map {
      Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
    }
    self.name = name
  }
}

// Rendering
extension Model {
  func render(encoder: MTLRenderCommandEncoder,
              uniforms vertex: Uniforms,
              params fragment: Params) {
    var uniforms = vertex
    uniforms.modelMatrix = transform.modelMatrix
    uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

    var params = fragment
    params.tiling = tiling

    encoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index)

    encoder.setFragmentBytes(
      &params,
      length: MemoryLayout<Params>.stride,
      index: ParamsBuffer.index)

    for mesh in meshes {
      for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
        encoder.setVertexBuffer(
          vertexBuffer,
          offset: 0,
          index: index)
      }

      for submesh in mesh.submeshes {
        // Set the fragment texture here
        encoder.setFragmentTexture(
          submesh.textures.baseColor,
          index: BaseColor.index)

        encoder.drawIndexedPrimitives(
          type: .triangle,
          indexCount: submesh.indexCount,
          indexType: submesh.indexType,
          indexBuffer: submesh.indexBuffer,
          indexBufferOffset: submesh.indexBufferOffset
        )
      }
    }
  }
}
