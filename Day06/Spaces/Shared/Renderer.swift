//
//  Renderer.swift
//  Spaces
//
//  Created by Pham Nghia on 2022/06/02.
//

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var pipelineState: MTLRenderPipelineState!
  var timer: Float = 0

  lazy var model: Model = {
    Model(device: Renderer.device, name: "train", ext: "usd")
  }()

  var uniforms = Uniforms()

  init(metalView: MTKView) {
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue()
    else {
        fatalError("GPU not available")
    }

    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device

    // Create the shader function library
    let library = device.makeDefaultLibrary()
    Self.library = library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")

    // Create the pipeline state
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
      blue: 0.9,
      alpha: 1.0)
    metalView.delegate = self
    
    mtkView(
      metalView,
      drawableSizeWillChange: metalView.bounds.size)
  }
}

extension Renderer: MTKViewDelegate {
  func mtkView(
    _ view: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
    // Projection matrix
    let aspect = Float(view.bounds.width) / Float(view.bounds.height)
    let projectionMatrix =
    float4x4(
      projectionFov: Float(70).degreesToRadians,
      near: 0.1,
      far: 100,
      aspect: aspect)
    uniforms.projectionMatrix = projectionMatrix
  }

  func draw(in view: MTKView) {
    guard
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor)
    else {
        return
    }

    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setTriangleFillMode(.lines)
    timer += 0.005

    // View matrix
    uniforms.viewMatrix = float4x4(translation: [0, 0, -3]).inverse
    
    model.position.y = -0.6
    model.rotation.y = sin(timer)
    uniforms.modelMatrix = model.transform.modelMatrix
    
    renderEncoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: 11)
    model.render(encoder: renderEncoder)
    
    renderEncoder.endEncoding()
    guard
      let drawable = view.currentDrawable
    else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
