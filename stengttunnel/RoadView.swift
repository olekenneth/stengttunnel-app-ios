//
//  ContentView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct Road: Identifiable, Codable {
    var id: String { urlFriendly }
    let roadName: String
    let urlFriendly: String
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
    @Binding var lastUpdated: Date
    @Environment(\.scenePhase) private var scenePhase
    
    func reload() {
        print("Reloading for \(road.roadName)")
        Dataloader.shared.loadRoad(road: road.urlFriendly) { status in
            guard status != nil else { return }
            self.status = status
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading) {
            if (status != nil) {
                let statusMessage = status!.statusMessage.replacingOccurrences(of: "Tunnelen", with: road.roadName)
                ShareLink(item: URL(string: "https://stengttunnel.no/\(road.urlFriendly)")!, preview: SharePreview(statusMessage, image: Image("App"))) {
                    StatusMessageView(color: status!.status, statusMessage: statusMessage)
                }
                if status?.messages != nil && !status!.messages!.isEmpty {
                    Rectangle()
                        .foregroundColor(Color("lightGray"))
                        .frame(height: 1)
                    MessageTableView(data: status!.messages!)
                        .padding([.top, .leading, .bottom])
                }
            } else {
                StatusMessageView(color: .yellow, statusMessage: "The road is ...")
            }
            
        }
        .background(Color(.systemBackground))
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

#Preview {
    struct Preview: View {
        @State private var lastRefreshed = Date.now
        
        var body: some View {
            ScrollView {
                RoadView(road: Road(roadName: "Bamletunnelen", urlFriendly: "bamletunnelen", messages: [
                    Message(source: .svv, message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000)),
                    Message(source: .svv, message: "Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now.addingTimeInterval(86400), validTo: Date.now.addingTimeInterval(86400+86400)),
                ], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
            }.background(Color.lightGray)
        }
    }

    return Preview()
}

