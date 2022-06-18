//
//  InputController.swift
//  Navigation
//
//  Created by Pham Nghia on 2022/06/13.
//

import GameController

class InputController {
  static let shared = InputController()
  var keysPressed: Set<GCKeyCode> = []
  struct Point {
    var x: Float
    var y: Float
    static let zero = Point(x: 0, y: 0)
  }
  var leftMouseDown = false
  var mouseDelta = Point.zero
  var mouseScroll = Point.zero

  private init() {
    let center = NotificationCenter.default
    
    // Connect the keyboard
    center.addObserver(
      forName: .GCKeyboardDidConnect,
      object: nil,
      queue: nil) { notification in
        let keyboard = notification.object as? GCKeyboard
        keyboard?.keyboardInput?.keyChangedHandler = { _, _, keyCode, pressed in
          if pressed {
            self.keysPressed.insert(keyCode)
          } else {
            self.keysPressed.remove(keyCode)
          }
        }
      }

    // Connect the mouse to handle
    center.addObserver(
      forName: .GCMouseDidConnect,
      object: nil,
      queue: nil) { notification in
        let mouse = notification.object as? GCMouse
      // Event mouse click
      mouse?.mouseInput?.leftButton.pressedChangedHandler = { _, _, pressed in
        self.leftMouseDown = pressed
      }
        
      // Event mouse moves
      mouse?.mouseInput?.mouseMovedHandler = { _, deltaX, deltaY in
        self.mouseDelta = Point(x: deltaX, y: deltaY)
      }
      // Event mouse scroll
        mouse?.mouseInput?.scroll.valueChangedHandler = { _, xValue, yValue in
        self.mouseScroll.x = xValue
        self.mouseScroll.y = yValue
      }
    }
    #if os(macOS)
      NSEvent.addLocalMonitorForEvents(
      matching: [.keyUp, .keyDown]) { _ in nil }
    #endif
  }
}
