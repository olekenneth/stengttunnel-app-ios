//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI
struct Message: Identifiable {
    var id = UUID()
    var message: String
    var source: String
    var validFrom: Date
    var validTo: Date
}

struct MessageTableView: View {
    @State var data: [Message]

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(data) { message in
                HStack(alignment: .top) {
                    Image(systemName: message.source)
                    VStack(alignment: .leading) {
                        HStack {
                            Text(message.validFrom.formatted(date: .abbreviated, time: .shortened))
                            Text("-")
                            Text(message.validFrom.formatted(date: .abbreviated, time: .shortened))
                        }
                        .font(.caption)
                            
                        Text(message.message)
                            .font(.subheadline)
                    }
                    
                }
                Spacer().frame(height: 20)
            }
        }
    }
}

struct MessageTableView_Previews: PreviewProvider {
    static var previews: some View {
        
        let d = [
            Message(message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", source: "train.side.front.car", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000)),
            Message(message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", source: "train.side.front.car", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000)),
        ]
        ScrollView {
            MessageTableView(data: d).padding()
        }
    }
}
