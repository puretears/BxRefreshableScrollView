//
//  RefreshableKey.swift
//  BxRefreshableScrollView
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import SwiftUI
import Foundation

struct RefreshableKey {
  enum ViewType: Int {
    case movingView
    case fixedView
  }
  
  struct PrefData: Equatable {
    let vType: ViewType
    let bounds: CGRect
  }
  
  struct PrefKey: PreferenceKey {
    typealias Value = [PrefData]
    static var defaultValue: [PrefData] = []
    
    static func reduce(
      value: inout [RefreshableKey.PrefData],
      nextValue: () -> [RefreshableKey.PrefData]) {
      value.append(contentsOf: nextValue())
    }
  }
}
