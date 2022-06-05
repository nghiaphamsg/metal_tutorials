//
//  Options.swift
//  Fragment
//
//  Created by Pham Nghia on 2022/06/04.
//

import Foundation

enum RenderChoice {
  case train, quad
}

class Options: ObservableObject {
  @Published var renderChoice = RenderChoice.train
}
