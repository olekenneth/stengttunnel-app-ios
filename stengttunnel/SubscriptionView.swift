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
    
    let later = Date()
    
    var body: some View {
        VStack {
            Text("By subscribing to Stengt tunnel+, you'll enjoy an **ad-free experience** and the ability to **add more than two roads**.")
                .multilineTextAlignment(.center)
                .padding()
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
                ForEach(storeManager.products, id: \.self) { product in
                    Button(action: {
                        storeManager.purchaseProduct(product)
                    }) {
                        Text("Subscribe for \(product.localizedPrice) \(product.subscriptionPeriodText)")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding(.vertical, 5)
                }
                
            }
            
            Button("Restore purchase") {
                storeManager.restorePurchases()
            }
            .padding(.top, 20)

            Text("By subscribing to Stengt tunnel+, you'll be directly supporting the continued development of the app")
                .multilineTextAlignment(.center)
                .padding(.top, 20)
        }
        .padding()
    }
}

#Preview {
    SubscriptionView()
}
