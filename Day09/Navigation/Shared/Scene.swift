//
//  Scene.swift
//  Navigation
//
//  Created by Pham Nghia on 2022/06/11.
//

import MetalKit

struct Scene {
  // var camera = FPCamera()
  // var camera = OrthographicCamera()
  var camera = ArcballCamera()
  // var camera = PlayerCamera()
  lazy var house: Model = {
    Model(name: "lowpoly-house.obj")
  }()
  
  lazy var ground: Model = {
    var ground = Model(name: "plane.obj")
    ground.tiling = 16
    ground.scale = 40
    return ground
  }()
  lazy var models: [Model] = [ground, house]
  
  init() {
    // Orthographic configuration
    // camera.position = [0, 2, 0]
    // camera.rotation.x = .pi / 2

    // Arcball configuration
    camera.position = [0, 1.5, -7]
    camera.distance = length(camera.position)
    camera.target = [0, 1.5, 0]
  }
  
  mutating func update(size: CGSize) {
    camera.update(size: size)
  }
  
  mutating func update(deltaTime: Float) {
    ground.scale = 40
    camera.update(deltaTime: deltaTime)
  }
}
