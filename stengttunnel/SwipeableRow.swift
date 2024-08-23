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
                        StatusMessageView(color: .green, statusMessage: "Tunnelen er åpen")
                            .padding()
                        Spacer()
                    }
                    .background(Color.white)
                }, buttons: {
                    HStack(spacing:0) {
                        Button(action: {
                            print("Share Item")
                        }) {
                            VStack(spacing: 2) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 24)) // Set the size of the icon

                                Text("Del")
                                    .font(.subheadline)

                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white) // To ensure the text color contrasts with the background
                            //.cornerRadius(8) // Optional: For rounded corners
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
                            .background(Color.primary)
                            .foregroundColor(.white) // To ensure the text color contrasts with the background
                            //.cornerRadius(8) // Optional: For rounded corners
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
    private let maxButtonWidth: CGFloat = UIScreen.main.bounds.width / 2.5
    
    init(@ViewBuilder content: () -> Content, @ViewBuilder buttons: () -> Buttons) {
        self.content = content()
        self.buttons = buttons()
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
                            if value.translation.width < 0 {
                                withAnimation {
                                    offset = max(value.translation.width, -maxButtonWidth)
                                    buttonWidth = -offset
                                }
                            } else {
                                withAnimation {
                                    offset = min(value.translation.width, 0)
                                    buttonWidth = -offset
                                }
                            }
                        }
                        .onEnded { value in
                            if value.translation.width <= -maxButtonWidth / 2 {
                                withAnimation {
                                    offset = -maxButtonWidth
                                    buttonWidth = maxButtonWidth
                                }
                            } else {
                                withAnimation {
                                    offset = 0
                                    buttonWidth = 0
                                }
                            }
                        }
                )
                .onTapGesture {
                    withAnimation {
                        if offset == 0 {
                            offset = -maxButtonWidth
                            buttonWidth = maxButtonWidth
                        } else {
                            offset = 0
                            buttonWidth = 0
                        }
                    }
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
