//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

enum StatusType: String, Codable {
    case green = "green"
    case yellow = "yellow"
    case red = "red"
}

struct GPS: Codable {
    var lat: Float
    var lon: Float
}

struct Status: Identifiable, Codable {
    var id: UUID { UUID() }
    var statusMessage: String
    var messages: [Message]?
    var status: StatusType
    var localizedStatusMessage: LocalizedStringKey {
        return LocalizedStringKey(statusMessage)
    }
    // var gps: GPS
}

struct RoadView: View {
    let urlFriendly: String
    @State var status: Status?
    @Binding var lastUpdated: Date
    @Environment(\.scenePhase) private var scenePhase
    
    func reload() {
        Dataloader.shared.loadRoad(road: urlFriendly) { status in
            guard status == nil else {
                self.status = status
                return
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if (status != nil) {
                StatusMessageView(color: status!.status, statusMessage: status!.localizedStatusMessage)
                    .padding()
                if !status!.messages!.isEmpty {
                    Rectangle()
                        .foregroundColor(Color("lightGray"))
                        .frame(height: 1)
                    MessageTableView(data: status!.messages!)
                        .padding()
                }
            } else {
                StatusMessageView(color: .yellow, statusMessage: "Tunnelen er ...")
                    .padding()
            }
            
        }
        .background(Color("white"))
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                reload()
            }
        }
        .onChange(of: lastUpdated, { _, _ in
            reload()
        })
        .onAppear() {
            reload()
        }
        
    }
}



//struct RoadView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScrollView {
//            VStack(alignment: .leading) {
//                RoadView(urlFriendly: "oslofjordtunnelen")
//            }
//        }
//        .background(Color("lightGray"))
//    }
//}
