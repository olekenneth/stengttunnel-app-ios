//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct Road: Identifiable, Codable {
    var id: String { urlFriendly }
    let roadName: String
    let urlFriendly: String
    var url: URL { URL(string: "https://api.stengttunnel.no/" + urlFriendly + "/v2")! }
    let messages: [Message]
    let gps: GPS
}

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

public struct RoadView: View {
    let road: Road
    @State var status: Status?
    @State var isSharing = false
    @Binding var lastUpdated: Date
    @Environment(\.scenePhase) private var scenePhase
    
    func reload() {
        Dataloader.shared.loadRoad(road: road.urlFriendly) { status in
            guard status != nil else { return }
            self.status = status
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if (status != nil) {
                StatusMessageView(color: status!.status, statusMessage: status!.statusMessage.replacingOccurrences(of: "Tunnelen", with: road.roadName))
                    .padding()
                if !status!.messages!.isEmpty {
                    Rectangle()
                        .foregroundColor(Color("lightGray"))
                        .frame(height: 1)
                    MessageTableView(data: status!.messages!)
                        .padding()
                }
            } else {
                StatusMessageView(color: .yellow, statusMessage: "The road is ...")
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
