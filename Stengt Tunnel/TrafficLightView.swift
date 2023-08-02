//
//  ContentView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 02/08/2023.
//

import SwiftUI

struct TrafficLightView: View {
    @State var color: StatusTypes

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Rectangle()
                .fill(color == .red ? Color("red") : .gray)
                .clipShape(Circle())
            Rectangle()
                .fill(color == .yellow ? Color("yellow") : .gray)
                .clipShape(Circle())
            Rectangle()
                .fill(color == .green ? Color("green") : .gray)
                .clipShape(Circle())
        }
        .padding(4)
        .background(Color("black"))
        .cornerRadius(180)
        .aspectRatio(0.36, contentMode: .fit)
        .frame(width: 36, height: 100)
    }
}

struct TrafficLightView_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack(alignment: .leading) {
            TrafficLightView(color: .green)
            TrafficLightView(color: .red)
            TrafficLightView(color: .yellow)
            TrafficLightView(color: .green)
        }.padding()
    }
}
