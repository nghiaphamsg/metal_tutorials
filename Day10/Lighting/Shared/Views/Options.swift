//
//  Options.swift
//  Lighting
//
//  Created by Pham Nghia on 2022/06/19.
//

import Foundation

enum RenderChoice {
  case train, quad
}

class Options: ObservableObject {
  @Published var renderChoice = RenderChoice.quad
}
