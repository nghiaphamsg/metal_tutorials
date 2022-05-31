//
//  Renderer.swift
//  Vertex
//
//  Created by Pham Nghia on 2022/05/31.
//

import MetalKit
import SwiftUI

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var pipelineState: MTLRenderPipelineState!
  var timer: Float = 0
  
  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
      fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device
    
    // Create the shader function library
    let library = device.makeDefaultLibrary()
    Self.library = library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction =
    library?.makeFunction(name: "fragment_main")
    
    // Create the pipeline state object
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
    do {
      pipelineState =
      try device.makeRenderPipelineState(
        descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    super.init()
    metalView.clearColor = MTLClearColor(
      red: 1.0,
      green: 1.0,
      blue: 0.8,
      alpha: 1.0)
    metalView.delegate = self
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(
    _ view: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
  }
  
  func draw(in view: MTKView) {
    guard
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor) else {
      return
    }
    // Setup timer
    timer += 0.01
    var currentTime = sin(timer)
    renderEncoder.setVertexBytes(
      &currentTime,
      length: MemoryLayout<Float>.stride,
      index: 11)

    renderEncoder.setRenderPipelineState(pipelineState)
    
    // Drawing here
    // Create quad model with 6 vertex
    lazy var quad: Quad = {
      Quad(device: Renderer.device, scale: 0.5)
    }()
    renderEncoder.setVertexBuffer(quad.vertexBuffer, offset: 0, index: 0)
    renderEncoder.setVertexBuffer(quad.colorBuffer, offset: 0, index: 1)
    renderEncoder.drawIndexedPrimitives(
      type: .triangle,
      indexCount: quad.indices.count,
      indexType: .uint16,
      indexBuffer: quad.indexBuffer,
      indexBufferOffset: 0)
    
    // Commit & sending to GPU
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}

