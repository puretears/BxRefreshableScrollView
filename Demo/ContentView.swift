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
  @ObservedObject var vm = ViewModel()
//  @State private var loading: Bool = false
  
  var body: some View {
    VStack(spacing: 0) {
      HeaderView(title: "Refreshable Scroll View Demo")
      
      RefreshableScrollView(
      height: 70,
      refreshing: self.$vm.loading, showBottomLoading: self.$vm.showBottomLoading,
      showNoMoreData: self.$vm.showNoMoreData, noDataPrompt: "No more data...") {
        VStack {
          ForEach(vm.episodes, id: \.self) {
            EpisodeView(episode: $0)
          }
        }
      }
      .padding(5)
      .background(Color(UIColor.secondarySystemBackground))
    }
  }
  
  struct HeaderView: View {
    var title = ""
    
    var body: some View {
      VStack {
        Color(.systemBackground).frame(height: 30).overlay(Text(self.title))
        Color(.secondarySystemBackground).frame(height: 2)
      }
    }
  }
  
  struct EpisodeView: View {
    let episode: Episode
    
    var body: some View {
      VStack {
        Image(episode.coverUrl, defaultSystemImage: "play.rectangle.fill")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .clipShape(RoundedRectangle(cornerRadius: 20))
          .padding(10)
        Text(episode.title).font(.title).fontWeight(.bold)
        Text(episode.description)
      }
      .padding(6)
      .background(RoundedRectangle(cornerRadius: 20).fill(Color.blue))
    }
  }
}
