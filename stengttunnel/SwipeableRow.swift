//
//  SwipeableRow.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 23/08/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List {
            ForEach(0..<10) { index in
                SwipeableRow(content: {
                    HStack {
                        HStack(alignment: .center) {
                            TrafficLightView(color: .green)
                            Text(LocalizedStringKey("Tunnelen er åpen"))
                                .multilineTextAlignment(.leading)
                                .baselineOffset(0)
                                .font(.headline)
                                .foregroundStyle(.foreground)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .padding()
                        .blur(radius: false ? 3 : 0)
                    }
                }, buttons: {
                    HStack(spacing:0) {
                        ShareLink(item: URL(string: "https://stengttunnel.no/")!, preview: SharePreview("Tunnelen er åpen", image: Image("App"))) {
                            VStack(spacing: 2) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24)) // Set the size of the icon
                                
                                Text("Del")
                                    .font(.subheadline)
                                
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                        }
                        
                        Button(action: {
                            print("Edit Item")
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "square.and.pencil")
                                    .font(.system(size: 24))
                                
                                Text("Meld inn")
                                    .font(.subheadline)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.secondary)
                            .foregroundColor(.white)
                        }
                    }.frame(minWidth: 130)
                    
                })
                .background(Color.gray.opacity(0.2))
                .listRowInsets(EdgeInsets()) // Remove default insets for full width
            }
        }
        .listStyle(PlainListStyle())
    }
}

struct SwipeableRow<Content: View, Buttons: View>: View {
    var content: Content
    var buttons: Buttons
    @Environment(\.colorScheme) var colorScheme

    
    @State private var offset = CGFloat.zero
    @State private var buttonWidth = CGFloat.zero
    @State private var isOpen = false
    private let maxButtonWidth: CGFloat = UIScreen.main.bounds.width / 2.5
    
    init(@ViewBuilder content: () -> Content, @ViewBuilder buttons: () -> Buttons) {
        self.content = content()
        self.buttons = buttons()
    }
    
    func openClose(_ newState: Bool) {
        isOpen = newState
        withAnimation {
            if newState == true {
                offset = -maxButtonWidth
                buttonWidth = maxButtonWidth
            } else {
                offset = 0
                buttonWidth = 0
            }
        }

    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            buttons
                .frame(width: buttonWidth)
            
            content
                .background(colorScheme == .dark ? .black : .white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isOpen {
                                offset = max(min(-maxButtonWidth + value.translation.width, 0), -maxButtonWidth * 1.5)
                            } else {
                                offset = max(min(value.translation.width, 0), -maxButtonWidth * 1.5)
                            }
                        }
                        .onEnded { value in
                            if value.translation.width <= -maxButtonWidth / 2 {
                                openClose(true)
                            } else {
                                openClose(false)
                            }
                        }
                )
                .onTapGesture {
                    openClose(!isOpen)
                }
        }
        .clipped()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
