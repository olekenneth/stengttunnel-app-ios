//
//  ContentView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct Road: Identifiable, Codable, Equatable {
    static func == (lhs: Road, rhs: Road) -> Bool {
        lhs.roadName == rhs.roadName
    }
    
    var id: String { urlFriendly }
    let roadName: String
    let urlFriendly: String
    let messages: [Message]
    let gps: GPS
    var distance: Double? = 0.0
}

struct GPS: Codable {
    var lat: Double
    var lon: Double
}

enum StatusType: String, Codable {
    case green = "green"
    case yellow = "yellow"
    case red = "red"
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
    @State var shouldUpdate: Bool = true
    
    func reload() {
        guard shouldUpdate == true else { return }
        self.status = nil
        print("Reloading for \(road.roadName)")
        Dataloader.shared.loadRoad(road: road.urlFriendly) { status in
            guard status != nil else { return }
            self.status = status
        }
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let status {
                let statusMessage = status.statusMessage.replacingOccurrences(of: "Tunnelen", with: road.roadName)
                StatusMessageView(color: status.status, statusMessage: statusMessage)
                if status.messages != nil && !status.messages!.isEmpty {
                    Rectangle()
                        .foregroundColor(Color("lightGray"))
                        .frame(height: 1)
                    MessageTableView(data: status.messages!)
                        .padding([.top, .leading, .bottom])
                }
            } else {
                StatusMessageView(color: .yellow, statusMessage: "\(road.roadName) "  + NSLocalizedString("is ...", comment: ""), disabled: !shouldUpdate)
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
                RoadView(road: Road(roadName: "Bamletunnelen", urlFriendly: "bamletunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: Status(statusMessage: "Bamletunnelen er åpen", messages: [
                    Message(source: .svv, message: "Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now.addingTimeInterval(86400), validTo: Date.now.addingTimeInterval(86400+86400)),
                ], status: .green), lastUpdated: $lastRefreshed, shouldUpdate: false)
                RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                RoadView(road: Road(roadName: "Bragernestunnelen", urlFriendly: "bragernestunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: Status(statusMessage: "Bragernestunnelen er stengt", messages: [
                    Message(source: .svv, message: "Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now.addingTimeInterval(-86400), validTo: Date.now.addingTimeInterval(86400+86400)),
                    Message(source: .svv, message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000)),
                ], status: .red), lastUpdated: $lastRefreshed, shouldUpdate: false)
            }.background(Color.lightGray)
        }
    }

    return Preview()
}

