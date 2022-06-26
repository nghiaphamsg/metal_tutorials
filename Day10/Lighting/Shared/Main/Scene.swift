//
//  Scene.swift
//  Lighting
//
//  Created by Pham Nghia on 2022/06/19.
//

import MetalKit
//
//struct Scene {
//  lazy var sphere: Model = {
//    Model(device: Renderer.device, name: "sphere.obj")
//  }()
//  lazy var gizmo: Model = {
//    Model(device: Renderer.device, name: "gizmo.usd")
//  }()
//  var models: [Model] = []
//  var camera = ArcballCamera()
//
//  var defaultView: Transform {
//    Transform(
//      position: [-1.18, 1.57, -1.28],
//      rotation: [-0.73, 13.3, 0.0])
//  }
//  let lighting = SceneLighting()
//
//  init() {
//    camera.distance = 2.5
//    camera.transform = defaultView
//    models = [sphere, gizmo]
//  }
//
//  mutating func update(size: CGSize) {
//    camera.update(size: size)
//  }
//
//  mutating func update(deltaTime: Float) {
//    let input = InputController.shared
//    if input.keysPressed.contains(.one) {
//      camera.transform = Transform()
//    }
//    if input.keysPressed.contains(.two) {
//      camera.transform = defaultView
//    }
//    camera.update(deltaTime: deltaTime)
//    calculateGizmo()
//  }
//
//  mutating func calculateGizmo() {
//    var forwardVector: float3 {
//      let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
//      return [
//        lookat.columns.0.z, lookat.columns.1.z, lookat.columns.2.z
//      ]
//    }
//    var rightVector: float3 {
//      let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
//      return [
//        lookat.columns.0.x, lookat.columns.1.x, lookat.columns.2.x
//      ]
//    }
//
//    let heightNear = 2 * tan(camera.fov / 2) * camera.near
//    let widthNear = heightNear * camera.aspect
//    let cameraNear = camera.position + forwardVector * camera.near
//    let cameraUp = float3(0, 1, 0)
//    let bottomLeft = cameraNear - (cameraUp * (heightNear / 2)) - (rightVector * (widthNear / 2))
//    gizmo.position = bottomLeft
//    gizmo.position = (forwardVector - rightVector) * 10
//  }
//}

struct Scene {
  lazy var fs: Model = {
    Model(device: Renderer.device, name: "head3d.obj")
  }()
  lazy var gizmo: Model = {
    Model(device: Renderer.device, name: "gizmo.usd")
  }()
  var models: [Model] = []
  var camera = ArcballCamera()

  var defaultView: Transform {
    Transform(
      position: [-1.18, 1.57, -1.28],
      rotation: [-0.73, 13.3, 0.0])
  }
  let lighting = SceneLighting()
  let deg12 = Float(12).degreesToRadians
  let deg45 = Float(45).degreesToRadians
  let deg90 = Float(90).degreesToRadians

  init() {
    camera.distance = 2.5
    camera.transform = Transform()
    models = [fs, gizmo]
    models[0].scale = 0.005
    models[0].transform.rotation.y = Float(180).degreesToRadians
  }

  mutating func update(size: CGSize) {
    camera.update(size: size)
  }

  mutating func update(deltaTime: Float) {
    let cameraAngle = (camera.transform.rotation.y).radiansToDegrees
    let modelAngle = (models[0].transform.rotation.x).radiansToDegrees
    let input = InputController.shared
    if input.keysPressed.contains(.one) {
      camera.transform = Transform()
      models[0].transform.rotation.x = Float(0).degreesToRadians
    }
    if input.keysPressed.contains(.two) {
      camera.transform = defaultView
    }
    if input.keysPressed.contains(.three) {
      camera.transform.rotation.y = -deg45
    }
    if input.keysPressed.contains(.four) {
      camera.transform.rotation.y = deg45
    }
    if input.keysPressed.contains(.five) {
      if cameraAngle != 0 || modelAngle != 0 {
        models[0].transform.rotation.x = -deg12
      } else {
        camera.transform.rotation.x = deg12
      }
    }
    if input.keysPressed.contains(.six) {
      if cameraAngle != 0 || modelAngle != 0 {
        models[0].transform.rotation.x = deg12
      } else {
        camera.transform.rotation.x = -deg12
      }
    }
    if input.keysPressed.contains(.seven) {
      camera.transform.rotation.y = -deg90
    }
    if input.keysPressed.contains(.eight) {
      camera.transform.rotation.y = deg90
    }
    camera.update(deltaTime: deltaTime)
    calculateGizmo()
  }

  mutating func calculateGizmo() {
    var forwardVector: float3 {
      let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
      return [
        lookat.columns.0.z, lookat.columns.1.z, lookat.columns.2.z
      ]
    }
    var rightVector: float3 {
      let lookat = float4x4(eye: camera.position, center: .zero, up: [0, 1, 0])
      return [
        lookat.columns.0.x, lookat.columns.1.x, lookat.columns.2.x
      ]
    }

    let heightNear = 2 * tan(camera.fov / 2) * camera.near
    let widthNear = heightNear * camera.aspect
    let cameraNear = camera.position + forwardVector * camera.near
    let cameraUp = float3(0, 1, 0)
    let bottomLeft = cameraNear - (cameraUp * (heightNear / 2)) - (rightVector * (widthNear / 2))
    gizmo.position = bottomLeft
    gizmo.position = (forwardVector - rightVector) * 10
  }
}
