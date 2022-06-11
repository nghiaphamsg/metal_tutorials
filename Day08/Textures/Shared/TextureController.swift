//
//  TextureController.swift
//  Textures
//
//  Created by Pham Nghia on 2022/06/06.
//

import MetalKit

enum TextureController {
  static var textures: [String: MTLTexture] = [:]
  
  static func loadTexture(filename: String) throws -> MTLTexture? {

    // Create a texture loader using MetalKit
    let textureLoader = MTKTextureLoader(device: Renderer.device)
    
    // 1. Using resource from the asset catalog
    if let texture = try? textureLoader.newTexture(
      name: filename,
      scaleFactor: 1.0,
      bundle: Bundle.main,
      options: nil) {
      print("loaded texture: \(filename)")
      return texture
    }

    // 2. Change the texture’s origin (bottom-left)
    let textureLoaderOptions: [MTKTextureLoader.Option: Any] =
      [.origin: MTKTextureLoader.Origin.bottomLeft,
       .SRGB: false,
       .generateMipmaps: NSNumber(value: true)
      ]
    
    // 2.1 Provide a default extension for the image name
    let fileExtension =
      URL(fileURLWithPath: filename).pathExtension.isEmpty ?
        "png" : nil

    // 2.2 Create a new texture using the provided image name and loader options
    guard
      let url = Bundle.main.url(
      forResource: filename,
      withExtension: fileExtension)
    else {
        print("Failed to load \(filename)")
        return nil
    }
    let texture = try textureLoader.newTexture(
      URL: url,
      options: textureLoaderOptions)
    print("loaded texture: \(url.lastPathComponent)")
    return texture
  }

  // If the filename is new, save the new texture to the
  // central texture dictionary
  static func texture(filename: String) -> MTLTexture? {
    if let texture = textures[filename] {
      return texture
    }
    let texture = try? loadTexture(filename: filename)
    if texture != nil {
      textures[filename] = texture
    }
    return texture
  }
}


