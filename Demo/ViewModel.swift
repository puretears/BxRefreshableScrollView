//
//  ViewModel.swift
//  Demo
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import SwiftUI
import Combine

struct Episode: Identifiable {
  let id = UUID()
  let title: String
  let coverUrl: String
  let description: String
}

let episodes: [Episode] = [
  Episode(
    title: "SwiftUI refreshable scroll view 1",
    coverUrl: "cover-1",
    description: "Understanding view preferences in SwiftUI"),
  Episode(
    title: "SwiftUI refreshable scroll view 2",
    coverUrl: "cover-2",
    description: "Understanding refreshable scroll view architecture"),
  Episode(
    title: "SwiftUI refreshable scroll view 3",
    coverUrl: "cover-3",
    description: "Build a working BxRefreshableScrollView demo.")
]

class ViewModel: ObservableObject {
  @Published var loading: Bool = false {
    didSet {
      if oldValue == false && loading == true {
        self.load()
      }
    }
  }
  
  @Published var episode: Episode = episodes[0]
  
  var idx = 0
  
  func load() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
      self.idx = (self.idx + 1) < episodes.count ? (self.idx + 1) : 0
      self.loading = false
      self.episode = episodes[self.idx]
    }
  }
}
