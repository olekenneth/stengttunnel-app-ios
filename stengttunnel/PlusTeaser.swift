//
//  PlusTeaser.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 08/08/2024.
//

import SwiftUI

struct PlusTeaser: View {
    @Binding var showSettings: Bool
    let texts = [
        "Vil du slippe annonser? Kjøp Stengt tunnel+",
        "Stengt tunnel+ er uten annonser og har ekstra funksjoner",
        "Klikk for å kjøpe Stengt tunnel+",
    ]
    var body: some View {
        Button {
            showSettings = !showSettings
        } label: {
            Text(texts.randomElement()!)
                .multilineTextAlignment(.center)
        }
    }
}
