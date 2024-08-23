//
//  ContentView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct StatusMessageView: View {
    @State var color: StatusType
    @State var statusMessage: String
    var disabled = false
    
    var body: some View {
        let view = HStack {
            HStack(alignment: .center) {
                TrafficLightView(color: color)
                Text(LocalizedStringKey(statusMessage))
                    .multilineTextAlignment(.leading)
                    .baselineOffset(0)
                    .font(.headline)
                    .foregroundStyle(.foreground)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding()
            .blur(radius: disabled ? 3 : 0)
        }
        if disabled {
            view
        } else {
            SwipeableRow(content: {
                view
            }, buttons: {
                HStack(spacing:0) {
                    ShareLink(item: URL(string: "https://stengttunnel.no/")!, preview: SharePreview(statusMessage, image: Image("App"))) {
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
        }
    }
}

struct StatusMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView() {
            StatusMessageView(color: .green, statusMessage: "Oslofjordtunnelen ser ut til å være åpen.")
            StatusMessageView(color: .red, statusMessage: "Hammersborgtunnelen ser ut til å være stengt. Rødt lys kan bety at veien/tunnelen er stengt nå, men les meldingene under for nærmere informasjon.")
            StatusMessageView(color: .red, statusMessage: "Hammersborgtunnelen ser ut til å være stengt. Rødt lys kan bety at veien/tunnelen er stengt nå, men les meldingene under for nærmere informasjon.", disabled: true)
        }
    }
}
