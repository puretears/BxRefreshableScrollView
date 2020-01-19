//
//  BxRefreshableScrollView.swift
//  BxRefreshableScrollView
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//

import SwiftUI

public struct RefreshableScrollView<Content: View>: View {
  @State private var previousScrollOffset: CGFloat = 0
  @State private var scrollOffset: CGFloat = 0
  // Keep the loading indication area above the scroll view.
  @State private var frozen: Bool = false
  @State private var rotation: Angle = .degrees(0)
  
  @Binding var refreshing: Bool
  
  // Trigger the action after scrolling over the threshold.
  var threshold: CGFloat = 80
  let content: Content
  
  public init(height: CGFloat = 80, refreshing: Binding<Bool>, @ViewBuilder content: () -> Content) {
    self.threshold = height
    self._refreshing = refreshing /// Use `_` to assign the underlying binding object
    self.content = content()
  }
  
  public var body: some View {
    return VStack {
      ScrollView {
        ZStack(alignment: .top) {
          MovingView()
          VStack {
            self.content
          }
          .alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen ? -self.threshold : 0.0) })
          
          SymbolView(height: self.threshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation)
        }
      }
      .background(FixedView())
      .onPreferenceChange(RefreshableKey.PrefKey.self, perform: {
        self.refreshLogic(values: $0)
      })
    }
  }
  
  func refreshLogic(values: [RefreshableKey.PrefData]) {
    DispatchQueue.main.async {
      let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
      let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
      
      self.scrollOffset = movingBounds.minY - fixedBounds.minY
      self.rotation = self.symbolRotation(self.scrollOffset)
      
      // Crossing the threshold on the way down, we start the refreshing process
      if !self.refreshing && (self.scrollOffset > self.threshold && self.previousScrollOffset <= self.threshold) {
        self.refreshing = true
      }
      
      if self.refreshing {
        // Keep the symbol view above the scrollview during updating process.
        if self.previousScrollOffset > self.threshold && self.scrollOffset <= self.threshold { 
          self.frozen = true
        }
      }
      else {
        self.frozen = false
      }
      
      self.previousScrollOffset = self.scrollOffset
    }
  }
  
  func symbolRotation(_ scrollOffset: CGFloat) -> Angle {
    if scrollOffset < threshold * 0.6 {
      return .degrees(0)
    }
    else {
      let h = Double(threshold)
      let d = Double(scrollOffset)
      let v = max(min(d - (h * 0.6), h * 0.4), 0)
      
      return .degrees(180 * v / (h * 0.4))
    }
  }
  
  struct SymbolView: View {
    var height: CGFloat
    var loading: Bool
    var frozen: Bool
    var rotation: Angle
    
    var body: some View {
      Group {
        if self.loading {
          VStack {
            Spacer()
            ActivityIndicator()
            Spacer()
          }
          .frame(height: height).fixedSize()
          .offset(y: -height + (self.loading && self.frozen ? height : 0))
        }
        else {
          Image(systemName: "arrow.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: height * 0.25, height: height*0.25).fixedSize()
            .padding(height * 0.375)
            .rotationEffect(rotation)
            .offset(y: -height + (self.loading && self.frozen ? height : 0))
        }
      }
    }
  }
  
  struct MovingView: View {
    var body: some View {
      GeometryReader {
        Color.clear
          .preference(key: RefreshableKey.PrefKey.self,
                      value: [RefreshableKey.PrefData(vType: .movingView, bounds: $0.frame(in: .global))])
      }
      .frame(height: 0)
    }
  }
  
  struct FixedView: View {
    var body: some View {
      GeometryReader {
        Color.clear
          .preference(key: RefreshableKey.PrefKey.self,
                      value: [RefreshableKey.PrefData(vType: .fixedView, bounds: $0.frame(in: .global))])
      }
    }
  }
}
