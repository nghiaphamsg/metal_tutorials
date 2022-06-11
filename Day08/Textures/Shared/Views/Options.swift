//
//  Options.swift
//  Textures
//
//  Created by Pham Nghia on 2022/06/05.
//

import Foundation

enum RenderChoice {
  case train, quad
}

class Options: ObservableObject {
  @Published var renderChoice = RenderChoice.quad
}
