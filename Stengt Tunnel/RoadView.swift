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
    // var gps: GPS
}

struct RoadView: View {
    let urlFriendly: String
    @State var status: Status?
    
    var body: some View {
        VStack(alignment: .leading) {
            if (status != nil) {
                StatusMessageView(color: status!.status, statusMessage: status!.statusMessage.replacingOccurrences(of: "Tunnelen", with: urlFriendly.capitalized))
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
        .onAppear() {
            loadData(road: urlFriendly) { status in
                self.status = status
            }
        }
    }
}


private func loadData(road: String, completion:@escaping (_ status: Status) -> ()) {
    guard let url = URL(string: "https://api.stengttunnel.no/" + road + "/v2") else {
        print("unable to fetch")
        return
    }
    let jsonDecoder = JSONDecoder()

    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    formatter.formatOptions.insert(.withFractionalSeconds)

    jsonDecoder.dateDecodingStrategy = .custom({ decoder in
        let container = try decoder.singleValueContainer()
        let dateStr = try container.decode(String.self)

        if let date = formatter.date(from: dateStr) {
            return date
        }

        return Date.now
    })

    let request = URLRequest(url: url)
    URLSession.shared.dataTask(with: request) { data, resp, error in

        if let data = data {
//             do {
//                 let res = try jsonDecoder.decode(Status.self, from: data)
//             } catch {
//                 print(error)
//             }
            if let response = try? jsonDecoder.decode(Status.self, from: data) {
                print(response)
                DispatchQueue.main.async {
                    completion(response)
                }
            } else {
                print("Unable to decode JSON")
            }
        }
        
    }.resume()
}

struct RoadView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(alignment: .leading) {
                RoadView(urlFriendly: "oslofjordtunnelen")
            }
        }
        .background(Color("lightGray"))
    }
}
