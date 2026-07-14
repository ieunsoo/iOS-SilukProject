//
//  ContentView.swift
//  Siluk
//
//  Created by eunsoo on 7/1/26.
//

//import SwiftUI
//
//struct ContentView: View {
//    @State private var fireworksTrigger = 0
//
//    var body: some View {
//        VStack(spacing: 24) {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//
//            Button {
//                fireworksTrigger += 1
//            } label: {
//                Label("폭죽 터뜨리기", systemImage: "sparkles")
//                    .font(.headline)
//            }
//            .buttonStyle(.borderedProminent)
//        }
//        .padding()
//        .frame(maxWidth: .infinity, maxHeight: .infinity)
//        // Fireworks are drawn on top of the whole screen but ignore touches.
//        .overlay(FireworksView(trigger: fireworksTrigger))
//    }
//}
//
//#Preview {
//    ContentView()
//}
