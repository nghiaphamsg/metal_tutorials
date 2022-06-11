//
//  Submesh.swift
//  Textures
//
//  Created by Pham Nghia on 2022/06/05.
//

import MetalKit

struct Submesh {
  let indexCount: Int
  let indexType: MTLIndexType
  let indexBuffer: MTLBuffer
  let indexBufferOffset: Int
  
  struct Textures {
    let baseColor: MTLTexture?
  }

  let textures: Textures
}

extension Submesh {
  init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
    indexCount = mtkSubmesh.indexCount
    indexType = mtkSubmesh.indexType
    indexBuffer = mtkSubmesh.indexBuffer.buffer
    indexBufferOffset = mtkSubmesh.indexBuffer.offset
    textures = Textures(material: mdlSubmesh.material)
  }
}

private extension Submesh.Textures {
  init(material: MDLMaterial?) {
    func property(with semantic: MDLMaterialSemantic)
      -> MTLTexture? {
      guard let property = material?.property(with: semantic), property.type == .string,
            let filename = property.stringValue,
            let texture = TextureController.texture(filename: filename)
      else {
        return nil
      }
      print(filename)
      return texture
    }
    baseColor = property(with: MDLMaterialSemantic.baseColor)
  }
}

