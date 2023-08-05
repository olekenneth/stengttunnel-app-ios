//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

enum SourceType: String, Codable {
    case svv = "Statens Vegvesen"
    case user = "Brukerinnmeldt"
}

struct Message: Identifiable, Codable {
    var id: UUID { UUID() }
    var type: String?
    var source: SourceType
    var message: String
    var validFrom: Date
    var validTo: Date
}

struct MessageTableView: View {
    @State var data: [Message]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(data) { message in
                HStack(alignment: .top) {
                    Image(message.source.rawValue)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(message.validFrom.formatted(date: .abbreviated, time: .shortened))
                            Text("-")
                            Text(message.validTo.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.caption)
                            
                        Text(message.message)
                            .font(.subheadline)
                    }
                    
                }
                Spacer().frame(height: 20)
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct MessageTableView_Previews: PreviewProvider {
    static var previews: some View {

        let d = [
            Message(source: .svv, message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000)),
            Message(source: .svv, message: "Vegarbeid, vegen er stengt. Omkjøring er skiltet", validFrom: Date.now.addingTimeInterval(86400), validTo: Date.now.addingTimeInterval(86400+86400)),
        ]
        ScrollView {
            MessageTableView(data: d).padding()
        }
    }
}
