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
                Text("Thank you for subscribing to Stengt tunnel+").font(.title2).multilineTextAlignment(.center)
                
            } else {
                ForEach(storeManager.products, id: \.self) { product in
                    Button(action: {
                        storeManager.purchaseProduct(product)
                    }) {
                        Text("Subscribe for \(product.localizedPrice) every \(product.subscriptionPeriodText)")
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
