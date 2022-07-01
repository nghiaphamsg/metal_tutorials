//
//  Camera.swift
//  Navigation
//
//  Created by Pham Nghia on 2022/06/11.
//

import CoreGraphics

protocol Camera: Transformable {
  var projectionMatrix: float4x4 { get }
  var viewMatrix: float4x4 { get }
  mutating func update(size: CGSize)
  mutating func update(deltaTime: Float)
}

// MARK: First Person Camera
struct FPCamera: Camera, Movement {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }

  // Camera’s view matrix calculation
  var viewMatrix: float4x4 {
    // (float4x4(rotation: rotation) * float4x4(translation: position)).inverse
    (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
  }
  
  // Update the camera’s aspect ratio
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  mutating func update(deltaTime: Float) {
    let transform = updateInput(deltaTime: deltaTime)
    rotation += transform.rotation
    position += transform.position
  }
}

// MARK: Arcball Camera
struct ArcballCamera: Camera {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }
  let minDistance: Float = 0.0
  let maxDistance: Float = 20
  var target: float3 = [0, 0, 0]
  var distance: Float = 2.5
  
  // Camera’s view matrix calculation
  var viewMatrix: float4x4 {
    let matrix: float4x4
    if target == position {
      matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
    } else {
      matrix = float4x4(position: position, target: target, up: [0, 1, 0])
    }
    return matrix
  }
  
  // Update the camera’s aspect ratio
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  mutating func update(deltaTime: Float) {
    let input = InputController.shared
    
    // Mouse scroll
    let scrollSensitivity = Settings.mouseScrollSensitivity
    distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
    distance = min(maxDistance, distance)
    distance = max(minDistance, distance)
    input.mouseScroll = .zero
    
    // Left-mouse down
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
      input.mouseDelta = .zero
    }
    
    let rotateMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotateMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}

// MARK: Fly Camera
struct FlyCamera: Camera {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }
  let minDistance: Float = 0.0
  let maxDistance: Float = 20
  var target: float3 = [0, 0, 0]
  var distance: Float = 2.5
  
  // Camera’s view matrix calculation
  var viewMatrix: float4x4 {
    let matrix: float4x4
    if target == position {
      matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
    } else {
      let up: float3 = (rotation.x < -.pi / 2) || (rotation.x > .pi / 2) ? [0, -1, 0] : [0, 1, 0]
      matrix = float4x4(position: position, target: target, up: up)
    }
    return matrix
  }
  
  // Update the camera’s aspect ratio
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  mutating func update(deltaTime: Float) {
    let input = InputController.shared
    
    // Mouse scroll
    let scrollSensitivity = Settings.mouseScrollSensitivity
    distance -= (input.mouseScroll.x + input.mouseScroll.y) * scrollSensitivity
    distance = min(maxDistance, distance)
    distance = max(minDistance, distance)
    input.mouseScroll = .zero
    
    // Left-mouse down
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      if rotation.x > ((3 * .pi) / 2) {
        rotation.x = -.pi / 2
      }
      if rotation.x < ((3 * -.pi) / 2) {
        rotation.x = .pi / 2
      }
      input.mouseDelta = .zero
    }
    
    let rotateMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
    let distanceVector = float4(0, 0, -distance, 0)
    let rotatedVector = rotateMatrix * distanceVector
    position = target + rotatedVector.xyz
  }
}

// MARK: Orthographic Camera
struct OrthographicCamera: Camera, Movement {
  var transform = Transform()
  var aspect: CGFloat = 1
  var viewSize: CGFloat = 10
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    let rect = CGRect(
      x: -viewSize * aspect * 0.5,
      y: viewSize * 0.5,
      width: viewSize * aspect,
      height: viewSize)
    return float4x4(orthographic: rect, near: near, far: far)
  }

  var viewMatrix: float4x4 {
    (float4x4(translation: position) * float4x4(rotation: rotation)).inverse
  }
  
  mutating func update(size: CGSize) {
    aspect = size.width / size.height
  }

  mutating func update(deltaTime: Float) {
    let transform = updateInput(deltaTime: deltaTime)
    position += transform.position
    let input = InputController.shared
    let zoom = input.mouseScroll.x + input.mouseScroll.y
    viewSize -= CGFloat(zoom)
    input.mouseScroll = .zero
  }

}

// MARK: Player Camera
struct PlayerCamera: Camera, Movement {
  var transform = Transform()
  var aspect: Float = 1.0
  var fov = Float(70).degreesToRadians
  var near: Float = 0.1
  var far: Float = 100
  var projectionMatrix: float4x4 {
    float4x4(
      projectionFov: fov,
      near: near,
      far: far,
      aspect: aspect)
  }

  // Camera’s view matrix calculation
  var viewMatrix: float4x4 {
    let rotateMatrix = float4x4(rotationYXZ: [-rotation.x, rotation.y, 0])
    return (float4x4(translation: position) * rotateMatrix).inverse
  }
  
  // Update the camera’s aspect ratio
  mutating func update(size: CGSize) {
    aspect = Float(size.width / size.height)
  }

  mutating func update(deltaTime: Float) {
    let transform = updateInput(deltaTime: deltaTime)
    let input = InputController.shared
    rotation += transform.rotation
    position += transform.position
    
    // Left-mouse down
    if input.leftMouseDown {
      let sensitivity = Settings.mousePanSensitivity
      rotation.x += input.mouseDelta.y * sensitivity
      rotation.y += input.mouseDelta.x * sensitivity
      rotation.x = max(-.pi / 2, min(rotation.x, .pi / 2))
      input.mouseDelta = .zero
    }
  }
}
