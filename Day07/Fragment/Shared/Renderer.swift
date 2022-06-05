//
//  Renderer.swift
//  Fragment
//
//  Created by Pham Nghia on 2022/06/04.
//

import MetalKit

class Renderer: NSObject {
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var modelPipelineState: MTLRenderPipelineState!
  var quadPipelineState: MTLRenderPipelineState!
  let depthStencilState: MTLDepthStencilState?

  lazy var model: Model = {
    Model(device: Renderer.device, name: "train.usd")
  }()
  var options: Options
  var timer: Float = 0
  var uniforms = Uniforms()
  var params = Params()

  init(metalView: MTKView, options: Options) {
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
    let modelVertexFunction = library?.makeFunction(name: "vertex_main")
    let quadVertexFunction = library?.makeFunction(name: "vertex_quad")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")

    // Create the two pipeline state objects
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = quadVertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = .depth32Float
    do {
      quadPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
      pipelineDescriptor.vertexFunction = modelVertexFunction
      pipelineDescriptor.vertexDescriptor = MTLVertexDescriptor.defaultLayout
      modelPipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    self.options = options

    depthStencilState = Renderer.buildDepthStencilState()
    super.init()
    metalView.clearColor = MTLClearColor(
      red: 1.0,
      green: 1.0,
      blue: 0.9,
      alpha: 1.0)
    metalView.depthStencilPixelFormat = .depth32Float
    metalView.delegate = self
    mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
  }
}

extension Renderer: MTKViewDelegate {

  static func buildDepthStencilState() -> MTLDepthStencilState? {
    let descriptor = MTLDepthStencilDescriptor()
    //  If the current fragment depth is "less" than the depth of the previous fragment in the framebuffer
    //  the current fragment replaces that previous fragment.
    descriptor.depthCompareFunction = .less
    descriptor.isDepthWriteEnabled = true
    return Renderer.device.makeDepthStencilState(
      descriptor: descriptor)
  }

  func mtkView(
    _ view: MTKView,
    drawableSizeWillChange size: CGSize
  ) {
    let aspect =
      Float(view.bounds.width) / Float(view.bounds.height)
    let projectionMatrix =
      float4x4(
        projectionFov: Float(70).degreesToRadians,
        near: 0.1,
        far: 100,
        aspect: aspect)
    uniforms.projectionMatrix = projectionMatrix
    
    params.width = UInt32(size.width)
    params.height = UInt32(size.height)
  }

  func renderModel(encoder: MTLRenderCommandEncoder) {
    encoder.setRenderPipelineState(modelPipelineState)
    timer += 0.005
    uniforms.viewMatrix = float4x4(translation: [0, 0, -2]).inverse
    model.position.y = -0.6
    model.rotation.y = tan(timer)
    uniforms.modelMatrix = model.transform.modelMatrix
    encoder.setVertexBytes(
      &uniforms,
      length: MemoryLayout<Uniforms>.stride,
      index: UniformsBuffer.index)

    model.render(encoder: encoder)
  }

  func renderQuad(encoder: MTLRenderCommandEncoder) {
    encoder.setRenderPipelineState(quadPipelineState)
    encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
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
    
    // Set depth stencil state with render settings
    renderEncoder.setDepthStencilState(depthStencilState)
    
    // Send parameter (drawable size) to fragment function
    renderEncoder.setFragmentBytes(
      &params,
      length: MemoryLayout<Uniforms>.stride,
      index: ParamsBuffer.index)

    if options.renderChoice == .train {
      renderModel(encoder: renderEncoder)
    } else {
      renderQuad(encoder: renderEncoder)
    }

    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable
    else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
