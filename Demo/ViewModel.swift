//
//  ViewModel.swift
//  Demo
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import SwiftUI
import Combine

struct Episode: Identifiable, Hashable {
  let id = UUID()
  let title: String
  let coverUrl: String
  let description: String
}

let __episodes: [Episode] = [
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
    description: "Build a working BxRefreshableScrollView demo."),
  Episode(
    title: "SwiftUI refreshable scroll view 4",
    coverUrl: "cover-1",
    description: "SwiftUI refreshable scroll view 4 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 5",
    coverUrl: "cover-2",
    description: "SwiftUI refreshable scroll view 5 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 6",
    coverUrl: "cover-3",
    description: "SwiftUI refreshable scroll view 6 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 7",
    coverUrl: "cover-1",
    description: "SwiftUI refreshable scroll view 7 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 8",
    coverUrl: "cover-2",
    description: "SwiftUI refreshable scroll view 8 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 9",
    coverUrl: "cover-3",
    description: "SwiftUI refreshable scroll view 9 description."),
  Episode(
    title: "SwiftUI refreshable scroll view 10",
    coverUrl: "cover-1",
    description: "SwiftUI refreshable scroll view 10 description.")
]

class ViewModel: ObservableObject {
  @Published var loading: Bool = false {
    didSet {
      if oldValue == false && loading == true {
        self.load()
      }
    }
  }
  
  @Published var showBottomLoading: Bool = false {
    didSet {
      if oldValue == false && showBottomLoading == true {
        self.incrementalLoad()
      }
    }
  }
  
  @Published var showNoMoreData: Bool = false
  
  @Published var episodes: [Episode] = Array(__episodes[0...2])
  
  var idx = 0
  
  func load() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
      self.idx = self.idx == 0 ? self.idx + 3 : 0
      self.loading = false
      self.episodes = Array(__episodes[self.idx...self.idx + 4])
    }
  }
  
  func incrementalLoad() {
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
      if self.idx == __episodes.endIndex {
        self.showBottomLoading = false
        self.showNoMoreData = true
      }
      else {
        var endPos = __episodes.endIndex
        
        if self.idx + 3 < __episodes.endIndex {
          self.idx += 3
          self.showNoMoreData = false
        }
        
        if self.idx + 3 <= endPos {
          endPos = self.idx + 3
        }
        
        self.episodes.insert(contentsOf: __episodes[self.idx ..< endPos], at: self.episodes.endIndex)
        
        if self.idx + 3 >= __episodes.endIndex {
          self.idx = __episodes.endIndex
          self.showNoMoreData = true
        }
        
        self.showBottomLoading = false
      }
    }
  }
}
