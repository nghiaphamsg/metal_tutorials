import PlaygroundSupport
import MetalKit

// 1. Initialization
// 1.1 Checks for a suitable GPU
guard let device = MTLCreateSystemDefaultDevice() else {
  fatalError("GPU is not supported")
}

// 1.2 Setup queues & shader func
// Note: create one
guard let commandQueue = device.makeCommandQueue() else {
  fatalError("Could not create a command queue")
}

let shader = """
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float4 position [[attribute(0)]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[stage_in]]) {
  return vertex_in.position;
}

fragment float4 fragment_main() {
  return float4(0, 0.4, 0.21, 1);
}
"""

// 1.3 Setup a Metal library containing these two shader functions
let library = try device.makeLibrary(source: shader, options: nil)
let vertexFunction = library.makeFunction(name: "vertex_main")
let fragmentFunction = library.makeFunction(name: "fragment_main")


// 2. Setup view
let frame = CGRect(x: 0, y: 0, width: 600, height: 600)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)

// 3. Create & load a model
// 3.1 Allocate manages the memory for the mesh data.
let allocator = MTKMeshBufferAllocator(device: device)

// 3.2 Create a model
let mdlMesh = MDLMesh(sphereWithExtent: [0.75, 0.75, 0.75],
                      segments: [100, 100],
                      inwardNormals: false,
                      geometryType: .triangles,
                      allocator: allocator)
// 3.3 Load
let mesh = try MTKMesh(mesh: mdlMesh, device: device)

// 3.4 Submesh
guard let submesh = mesh.submeshes.first else {
  fatalError()
}

// 4. Setup pipeline state
let pipelineDescriptor = MTLRenderPipelineDescriptor()
pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
pipelineDescriptor.vertexFunction = vertexFunction
pipelineDescriptor.fragmentFunction = fragmentFunction
pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

let pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)

// 5. Rendering (Queues -> Buffers -> Render Pass -> Encoders)
// Note: single render passes (Chapter 1)
// 1 Create a command buffer. This stores all the commands that you’ll ask the GPU to run.
guard let commandBuffer = commandQueue.makeCommandBuffer(),

// 2 Reference to the view’s render pass descriptor
 let renderPassDescriptor = view.currentRenderPassDescriptor,

// 3 Render command encoder holds all the information necessary to send to the GPU so that it can draw the vertices.
 let renderEncoder = commandBuffer.makeRenderCommandEncoder(
    descriptor:    renderPassDescriptor)
else { fatalError() }

// Gives the render encoder the pipeline state
renderEncoder.setRenderPipelineState(pipelineState)
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer, offset: 0, index: 0)

// Draw
renderEncoder.drawIndexedPrimitives(
  type: .triangle,
  indexCount: submesh.indexCount,
  indexType: submesh.indexType,
  indexBuffer: submesh.indexBuffer.buffer,
  indexBufferOffset: 0)

// 1 Tell the render encoder that there are no more draw calls and end the render pass
renderEncoder.endEncoding()

// 2
guard let drawable = view.currentDrawable else {
  fatalError()
}

// 3
commandBuffer.present(drawable)
commandBuffer.commit()

PlaygroundPage.current.liveView = view


