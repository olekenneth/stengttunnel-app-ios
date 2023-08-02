//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

enum StatusTypes {
    case green
    case yellow
    case red
}

struct Status: Identifiable {
    var id = UUID()
    var roadName: String
    var messages: [Message]
    var urlFriendly: String
    var statusMessage: String
    var status: StatusTypes
    var gps = {
        var lat: Float
        var lon: Float
    }
}

struct RoadView: View {
    @State var status: Status
    
    var body: some View {
        VStack(alignment: .leading) {
            StatusMessageView(color: status.status, statusMessage: status.statusMessage)
                .padding()
            if status.messages.count > 0 {
                Rectangle()
                    .foregroundColor(Color("lightGray"))
                    .frame(height: 1)
                MessageTableView(data: status.messages).padding()
            }
        }
        .background(Color("white"))
    }
}



struct RoadView_Previews: PreviewProvider {
    static var previews: some View {
        let open = Status(roadName: "Oslofjordtunnelen", messages: [], urlFriendly: "oslofjordtunnelen", statusMessage: "Oslofjordtunnelen ser ut til å være åpen.", status: .green)
        
        let m = Message(message: "Rv. 162 (avkjøringsveg) Hammersborgtunnelen i Oslo i retning mot Filipstad: Vegarbeid, vegen er stengt. Omkjøring er skiltet", source: "train.side.front.car", validFrom: Date.now, validTo: Date.now.addingTimeInterval(6000))

        
        let closed = Status(roadName: "Oslofjordtunnelen", messages: [m, m], urlFriendly: "oslofjordtunnelen", statusMessage: "Hammersborgtunnelen ser ut til å være stengt. Rødt lys kan bety at veien/tunnelen er stengt nå, men les meldingene under for nærmere informasjon.", status: .red)
        
        let unknown = Status(roadName: "Oslofjordtunnelen", messages: [m, m, m], urlFriendly: "oslofjordtunnelen", statusMessage: "Oslofjordtunnelen ser ut til å være stengt. Gult lys kan bety at veien/tunnelen er stengt nå, eller blir stengt i løpet av kort tid. Les meldingene under for nærmere informasjon.", status: .yellow)
        

        ScrollView {
            VStack(alignment: .leading) {
                RoadView(status: open)
                RoadView(status: unknown)
                RoadView(status: unknown)
                RoadView(status: unknown)
                RoadView(status: closed)
            }
        }.background(Color("lightGray"))
    }
}
