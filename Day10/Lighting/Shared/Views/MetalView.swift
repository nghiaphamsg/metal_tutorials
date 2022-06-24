//
//  MetalView.swift
//  Lighting
//
//  Created by Pham Nghia on 2022/06/19.
//

import SwiftUI
import MetalKit

struct MetalView: View {
  let options: Options
  @State private var metalView = MTKView()
  @State private var appController: Controller?
  @State private var previousTranslation = CGSize.zero
  @State private var previousScroll: CGFloat = 1

  var body: some View {
    VStack {
      MetalViewRepresentable(
        appController: appController,
        metalView: $metalView,
        options: options)
        .onAppear {
            appController = Controller(
            metalView: metalView,
            options: options)
        }
        .gesture(DragGesture(minimumDistance: 0)
        .onChanged { value in
          InputController.shared.touchLocation = value.location
          InputController.shared.touchDelta = CGSize(
            width: value.translation.width - previousTranslation.width,
            height: value.translation.height - previousTranslation.height)
          previousTranslation = value.translation
          // if the user drags, cancel the tap touch
          if abs(value.translation.width) > 1 ||
            abs(value.translation.height) > 1 {
            InputController.shared.touchLocation = nil
          }
        }
        .onEnded {_ in
          previousTranslation = .zero
        })
        .gesture(MagnificationGesture()
        .onChanged { value in
          let scroll = value - previousScroll
          InputController.shared.mouseScroll.x = Float(scroll)
            * Settings.touchZoomSensitivity
          previousScroll = value
        }
        .onEnded {_ in
          previousScroll = 1
        })
    }
  }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#endif

struct MetalViewRepresentable: ViewRepresentable {
  let appController: Controller?
  @Binding var metalView: MTKView
  let options: Options

  #if os(macOS)
  func makeNSView(context: Context) -> some NSView {
    return metalView
  }
  func updateNSView(_ uiView: NSViewType, context: Context) {
    updateMetalView()
  }
  #elseif os(iOS)
  func makeUIView(context: Context) -> MTKView {
    metalView
  }

  func updateUIView(_ uiView: MTKView, context: Context) {
    updateMetalView()
  }
  #endif

  func updateMetalView() {
    appController?.options = options
  }
}

struct MetalView_Previews: PreviewProvider {
  static var previews: some View {
    VStack {
      MetalView(options: Options())
      Text("Metal View")
    }
  }
}
