//
//  ContentView.swift
//  Demo
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import BxRefreshableScrollView
import SwiftUI

struct ContentView: View {
  @State private var loading: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      RefreshableScrollView(height: 70, refreshing: $loading, content: {
        Text("Hehe")
      })
      .background(Color(UIColor.secondarySystemBackground))
    }
  }
}
