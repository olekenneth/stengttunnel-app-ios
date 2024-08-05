//
//  SubscriptionView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 05/08/2024.
//

import SwiftUI

struct SubscriptionView: View {
    @ObservedObject var storeManager = StoreManager.shared
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()
    
    func localDateString(_ date: Date?) -> String {
        guard date != nil else { return "" }
        
        return dateFormatter.string(from: date!)
    }
    
    let later = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
    
    var body: some View {
        VStack {
            if storeManager.subscriptionActive {
                Text("Takk for at du abonnerer! Ingen reklame vises.")
                VStack(alignment: .leading, spacing: 10) {
                    Text("Product Identifier : \(storeManager.purchase?.productIdentifier)")
                    Text("Purchase Date : \(self.localDateString(storeManager.purchase?.purchaseDate))")
                    Text("Original Purchase Date : \(self.localDateString(storeManager.purchase?.originalPurchaseDate))")
                    Text("Subscription Expiration Date : \(self.localDateString(storeManager.purchase?.subscriptionExpirationDate))")
                    Text("isActiveAutoRenewableSub for \(self.localDateString(later)): \(storeManager.purchase?.isActiveAutoRenewableSubscription(forDate: later).description)")
                    Text("Quantity : \(storeManager.purchase?.quantity.description)")
                    Text("isRenewable : \(storeManager.purchase?.isRenewableSubscription.description)")


                }
            } else {
                Text("Abonner for å fjerne reklame")
                    .font(.title)
                    .padding(.bottom)
                
                ForEach(storeManager.products, id: \.self) { product in
                    Button(action: {
                        print("Trykket på kjøp-knappen")
                        storeManager.purchaseProduct(product)
                    }) {
                        Text("Abonner for \(product.localizedPrice) \(product.subscriptionPeriodText)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 5)
                }
                
            }
            
            Button("Gjenopprett kjøp") {
                storeManager.restorePurchases()
            }
            .padding(.top, 20)

            Text("Ved å abonnere, støtter du videre utvikling av appen.")
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
        .padding()
    }
}
