//
//  Options.swift
//  Views
//
//  Created by Pham Nghia on 2022/06/11.
//

import Foundation

enum RenderChoice {
  case train, quad
}

class Options: ObservableObject {
  @Published var renderChoice = RenderChoice.quad
}
