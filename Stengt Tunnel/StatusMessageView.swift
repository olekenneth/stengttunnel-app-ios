//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct StatusMessageView: View {
    @State var color: StatusType
    @State var statusMessage: String

    var body: some View {
        HStack(alignment: .center) {
            TrafficLightView(color: color)
            Text(LocalizedStringKey(statusMessage))
                .baselineOffset(0)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

struct StatusMessageView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack(alignment: .leading) {
            StatusMessageView(color: .green, statusMessage: "Oslofjordtunnelen ser ut til å være åpen.")
            StatusMessageView(color: .red, statusMessage: "Hammersborgtunnelen ser ut til å være stengt. Rødt lys kan bety at veien/tunnelen er stengt nå, men les meldingene under for nærmere informasjon.")
        }
        .padding()
        .background(Color("lightGray"))
    }
}
