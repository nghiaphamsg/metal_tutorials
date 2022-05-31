//
//  ContentView.swift
//  Shared
//
//  Created by Pham Nghia on 2022/05/31.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      MetalView()
        .border(Color.black, width: 2)
    }
    .padding()
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
      .preferredColorScheme(.dark)
      .environment(\.sizeCategory, .accessibilityLarge)
  }
}
