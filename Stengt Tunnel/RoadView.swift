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
                        .padding()
                }
                if status?.messages != nil && !status!.messages!.isEmpty {
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
        @State private var searchText = ""
        @State private var showSettings = false
        
        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading) {
                        RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                        BannerView().frame(height: 100)
                        RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                        BannerView().frame(height: 100)
                        RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                        BannerView().frame(height: 100)
                        RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                        BannerView().frame(height: 100)
                        RoadView(road: Road(roadName: "Oslofjordtunnelen", urlFriendly: "oslofjordtunnelen", messages: [], gps: GPS(lat: 0, lon: 0)), status: nil, lastUpdated: $lastRefreshed)
                        BannerView().frame(height: 100)
                    }
                    .padding(.bottom)
                }
                .searchable(text: $searchText)
                .background(Color("lightGray"))
                .navigationTitle(Text("Stengt tunnel"))
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showSettings = true
                        } label: {
                            Image("menu")
                        }.sheet(isPresented: $showSettings) {
                            Text("hello")
                        }

                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Settings", systemImage: "person.circle", role: .destructive) {
                            // Do Nothing
                        }
                    }
                }
                .toolbarTitleDisplayMode(.inlineLarge)
            }
            
        }
    }

    return Preview()
}

