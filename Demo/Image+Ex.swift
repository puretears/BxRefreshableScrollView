//
//  Image+Ex.swift
//  Demo
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import SwiftUI

extension Image {
  init(_ name: String, defaultImage: String) {
    if let img = UIImage(named: name) {
      self.init(uiImage: img)
    }
    else {
      self.init(defaultImage)
    }
  }
  
  init(_ name: String, defaultSystemImage: String) {
    if let img = UIImage(named: name) {
      self.init(uiImage: img)
    }
    else {
      self.init(defaultSystemImage)
    }
  }
}
