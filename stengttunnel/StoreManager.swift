import StoreKit
import TPInAppReceipt

extension SKProduct {
    var localizedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price) ?? ""
    }
    
    var subscriptionPeriodText: String {
           guard let period = self.subscriptionPeriod else {
               return ""
           }

           let unit: String
           switch period.unit {
           case .day:
               unit = period.numberOfUnits == 1 ? "dag" : "dager"
           case .week:
               unit = period.numberOfUnits == 1 ? "uke" : "uker"
           case .month:
               unit = period.numberOfUnits == 1 ? "måned" : "måneder"
           case .year:
               unit = period.numberOfUnits == 1 ? "år" : "år"
           @unknown default:
               unit = "periode"
           }

           return "hver \(period.numberOfUnits) \(unit)"
       }
}

class StoreManager: NSObject, ObservableObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    static let shared = StoreManager() // Singleton
    
    let productIds = ["adfreeProduct"]
        
    @Published var purchase: InAppPurchase? = nil
    @Published var products: [SKProduct] = []
    @Published var subscriptionActive: Bool = false {
        didSet {
            UserDefaults.standard.set(subscriptionActive, forKey: "subscriptionActive")
        }
    }

    override init() {
        super.init()
        print("INIT StoreManager")
        loadSubscriptionState()

        SKPaymentQueue.default().add(self)
        fetchProducts()
        startValidation()
    }
    
    private var isOnDebouncePeriod = false
    
    func startValidation() {
        guard !isOnDebouncePeriod else { return }
        
        validateReceipt()
        isOnDebouncePeriod = true
        
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.isOnDebouncePeriod = false
        }
    }
    
    func validateReceipt() {
        print("VALIDATING")
        DispatchQueue.global().async {
            do {
                let receipt = try InAppReceipt.localReceipt()
                try receipt.validate()
                  
                let purchase = receipt.activeAutoRenewableSubscriptionPurchases(ofProductIdentifier: self.productIds.first!, forDate: Date())
                  
                DispatchQueue.main.async {
                    self.purchase = purchase
                    self.subscriptionActive = purchase != nil
                    print("Receipt validation successfull: ", purchase != nil, purchase!)
                }
            } catch {
                DispatchQueue.main.async {
                    self.subscriptionActive = false
                    print("Receipt validation failed: ", error)
                }
            }
        }
    }


    func fetchProducts() {
        let productIdentifiers = Set(productIds) // Add your product identifiers here
        let request = SKProductsRequest(productIdentifiers: productIdentifiers)
        request.delegate = self
        request.start()
    }
    
    func requestDidFinish(_ request: SKRequest) {
        print("Request did Finish")
        print(request)
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Fetching Products Failed with Error: \(error.localizedDescription)")
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.invalidProductIdentifiers.isEmpty == false {
            print("Invalid product identifiers received!")
        }
        
        guard response.products.isEmpty == false else {
            print("No products received!")
            return
        }

        print("Yey")
        print(response)
        print(response.products)
                
        DispatchQueue.main.async {
            self.products = response.products
        }
    }

    func purchaseProduct(_ product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased, .restored:
                startValidation()
                SKPaymentQueue.default().finishTransaction(transaction)
        
            case .failed:
                if let error = transaction.error as NSError? {
                    print("Transaction failed: \(error.localizedDescription)")
                }
                SKPaymentQueue.default().finishTransaction(transaction)
            default:
                break
            }
        }
    }

    func loadSubscriptionState() {
        self.subscriptionActive = UserDefaults.standard.bool(forKey: "subscriptionActive")
    }

    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}
