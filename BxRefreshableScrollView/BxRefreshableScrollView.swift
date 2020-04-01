//
//  BxRefreshableScrollView.swift
//  BxRefreshableScrollView
//
//  Created by Mars on 2020/1/17.
//  Copyright © 2020 Mars. All rights reserved.
//
import Combine
import SwiftUI

//private var contentBounds: CGRect = .zero

public struct RefreshableScrollView<Content: View>: View {
  @State private var previousScrollOffset: CGFloat = 0
  @State private var scrollOffset: CGFloat = 0
  
  // Keep the loading indication area above the scroll view.
  @State private var frozen: Bool = false
  @State private var rotation: Angle = .degrees(0)
  
  // Trigger the action after scrolling over the threshold.
  var threshold: CGFloat = 80
  
  // Pull down to refresh
  @Binding var refreshing: Bool
  
  // Pull up to refresh
  private let bottomRefreshable: Bool
  @Binding var showNoMoreData: Bool
  @Binding var showBottomLoading: Bool
  var noDataPrompt: String
  
  @State var contentBounds: CGRect = .zero
  
  let content: Content
  
  public init(height: CGFloat = 80,
              refreshing: Binding<Bool>,
              bottomRefreshable: Bool = false,
              showNoMoreData: Binding<Bool> = .constant(false),
              showBottomLoading: Binding<Bool> = .constant(false),
              noDataPrompt: String = "",
              @ViewBuilder content: () -> Content) {
    self.threshold = height
    self._refreshing = refreshing
    self.bottomRefreshable = bottomRefreshable
    self._showNoMoreData = showNoMoreData
    self._showBottomLoading = showBottomLoading
    self.noDataPrompt = noDataPrompt
    self.content = content()
  }
  
  public var body: some View {
    ScrollView {
      ZStack(alignment: .top) {
        MovingView()
        VStack {
          /// GeometryReader {
          ///   self.content.preference(
          ///     key: RefreshableKey.PrefKey.self,
          ///     value: [
          ///       RefreshableKey.PrefData(vType: .contentView,
          ///       bounds: $0.frame(in: CoordinateSpace.local))
          ///     ]) }
          self.content
            .anchorPreference(
              key: RefreshableKey.ContentPrefKey.self,
              value: .bounds,
              transform: { [RefreshableKey.ContentPrefData(vType: .contentView, bounds: $0)] })
          
          if bottomRefreshable {
            ZStack {
              ActivityIndicator().opacity(showBottomLoading ? 1 : 0)
              Text(noDataPrompt).opacity(showNoMoreData ? 1 : 0)
            }
            .foregroundColor(Color.secondary)
            .padding([.top, .bottom], 5)
          }
        }
        .alignmentGuide(.top, computeValue: { d in (self.refreshing && self.frozen ? -self.threshold : 0.0) })
        SymbolView(height: self.threshold, loading: self.refreshing, frozen: self.frozen, rotation: self.rotation)
      }
    }
//    .backgroundPreferenceValue(RefreshableKey.PrefKey.self) {
//      (preferences: [RefreshableKey.PrefData]) in
//      return GeometryReader { (proxy: GeometryProxy) -> FixedView in
//        let p = preferences.first(where: { $0.vType == .contentView })!
//        self.contentBounds = p.bounds
//
//        return FixedView()
//      }
//    }
    .backgroundPreferenceValue(RefreshableKey.ContentPrefKey.self) {
      (preferences: [RefreshableKey.ContentPrefData]) in
      return GeometryReader { (proxy: GeometryProxy) -> FixedView in
        let p = preferences.first(where: { $0.vType == .contentView })
        
        DispatchQueue.main.async {
          if let pref = p {
            self.contentBounds = proxy[pref.bounds]
          }
        }

        return FixedView()
      }
    }
    .onPreferenceChange(RefreshableKey.PrefKey.self ) { preferences in
      self.refreshLogic(values: preferences)
    }
  }
  
  func refreshLogic(values: [RefreshableKey.PrefData]) {
    let movingBounds = values.first { $0.vType == .movingView }?.bounds ?? .zero
    let fixedBounds = values.first { $0.vType == .fixedView }?.bounds ?? .zero
    
    scrollOffset = movingBounds.minY - fixedBounds.minY
    rotation = symbolRotation(scrollOffset)
    
    // Crossing the threshold on the way down, we start the refreshing process
    if !refreshing && (scrollOffset > threshold && previousScrollOffset <= threshold) {
      refreshing = true
    }
    
    if refreshing {
      /// Keep the symbol view above the scrollview during updating process.
      /// `self.scrollOffset <= self.threshold` prevents the UI from scrolling back
      /// to the top of screen.
      if previousScrollOffset > threshold && scrollOffset <= threshold {
        frozen = true
      }
    }
    else {
      frozen = false
    }
    
    #if DEBUG
    print("Scroll offset: \(scrollOffset)")
    print("Fix height: \(fixedBounds.size.height)")
    print("Content bounds: \(contentBounds)")
    print("-------------------------")
    #endif
    if bottomRefreshable,
      contentBounds.height > 0 &&
      scrollOffset < -(contentBounds.height - fixedBounds.size.height) &&
      showBottomLoading == false &&
      showNoMoreData == false {
      print("display bottom indicator")
      showBottomLoading = true
    }
    
    previousScrollOffset = scrollOffset
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
        if loading {
          VStack {
            Spacer()
            ActivityIndicator()
            Spacer()
          }
          .frame(height: height).fixedSize()
          .offset(y: -height + (loading && frozen ? height : 0))
        }
        else {
          Image(systemName: "arrow.down")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: height * 0.25, height: height*0.25).fixedSize()
            .padding(height * 0.375)
            .rotationEffect(rotation)
            .offset(y: -height + (loading && frozen ? height : 0))
        }
      }
    }
  }
  
  struct MovingView: View {
    var body: some View {
      GeometryReader {
        Color.clear
          /// Compare to:
          /// ```
          /// .anchorPreference(key: TagPreferenceKey.self,
          ///                   value: .bounds,
          ///                   transform: { [TagPreferenceData(bounds: $0)] })
          /// ```
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
