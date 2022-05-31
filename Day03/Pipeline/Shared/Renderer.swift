//
//  Renderer.swift
//  Pipeline
//
//  Created by Pham Nghia on 2022/05/31.
//

import MetalKit

class Renderer: NSObject {
  /*
   MTKView is a special Metal rendering view. This subclass of NSView on macOS and UIView on iOS
   MTLDevice: The software reference to the GPU hardware device.
   MTLCommandQueue: Responsible for creating and organizing MTLCommandBuffers every frame.
   MTLLibrary: Contains the source code from your vertex and fragment shader functions.
   MTLRenderPipelineState: Sets the information for the draw — such as which shader functions to use,
   what depth and color settings to use and how to read the vertex data.
   MTKMesh: A container for the vertex data of a Model I/O mesh, suitable for use in a Metal app.
   MTLBuffer: Holds data — such as vertex information — in a form that you can send to the GPU.
   */
  static var device: MTLDevice!
  static var commandQueue: MTLCommandQueue!
  static var library: MTLLibrary!
  var pipelineState: MTLRenderPipelineState!
  var mesh: MTKMesh!
  var vertexBuffer: MTLBuffer!
  
  init(metalView: MTKView) {
    
    // Initializes the GPU and creates the command queue
    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue() else {
      fatalError("GPU not available")
    }
    Renderer.device = device
    Renderer.commandQueue = commandQueue
    metalView.device = device
    let allocator = MTKMeshBufferAllocator(device: device)

    // Setup path to resource
    guard let assetURL = Bundle.main.url(
      forResource: "train",
      withExtension: "usd") else {
      fatalError("Model not found")
    }
    
    let vertexDescriptor = MTLVertexDescriptor()
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0
    vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride
    let meshDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
    (meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
    MDLVertexAttributePosition
    
    let asset = MDLAsset(
      url: assetURL,
      vertexDescriptor: meshDescriptor,
      bufferAllocator: allocator)
    let mdlMesh =
    asset.childObjects(of: MDLMesh.self).first as! MDLMesh
    do {
      mesh = try MTKMesh(mesh: mdlMesh, device: device)
    } catch {
      fatalError("Mesh not loaded")
    }
    
    // Setup the MTLBuffer that contains the vertex data & send to the GPU
    vertexBuffer = mesh.vertexBuffers[0].buffer
    
    // Create the shader function library
    let library = device.makeDefaultLibrary()
    Renderer.library = library
    let vertexFunction = library?.makeFunction(name: "vertex_main")
    let fragmentFunction = library?.makeFunction(name: "fragment_main")
    
    // Create the pipeline state object (PSO)
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    pipelineDescriptor.vertexDescriptor =
    MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
    do {
      pipelineState =
      try device.makeRenderPipelineState(
        descriptor: pipelineDescriptor)
    } catch let error {
      fatalError(error.localizedDescription)
    }
    
    super.init()
    
    // Set the cream color of the view
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
    
    // Render frame: send a series of commands to the GPU
    // Flow: Command Buffer -> Render Pass -> Command Encoder
    guard
      let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
      let descriptor = view.currentRenderPassDescriptor,
      let renderEncoder =
        commandBuffer.makeRenderCommandEncoder(
          descriptor: descriptor)
    else {
      return
    }
    
    // Drawing code here
    renderEncoder.setRenderPipelineState(pipelineState)
    renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
    for submesh in mesh.submeshes {
      renderEncoder.drawIndexedPrimitives(
        type: .triangle,
        indexCount: submesh.indexCount,
        indexType: submesh.indexType,
        indexBuffer: submesh.indexBuffer.buffer,
        indexBufferOffset: submesh.indexBuffer.offset)
    }
    
    // Done & commit the command to GPU
    renderEncoder.endEncoding()
    guard let drawable = view.currentDrawable else {
      return
    }
    commandBuffer.present(drawable)
    commandBuffer.commit()
  }
}
