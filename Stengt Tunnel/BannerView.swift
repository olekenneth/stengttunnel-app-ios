//
//  BannerView.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 18/07/2024.
//

import SwiftUI
import GoogleMobileAds

// Delegate methods for receiving width update messages.

protocol BannerViewControllerWidthDelegate: AnyObject {
    func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat)
}

struct BannerView: UIViewControllerRepresentable {
    @State private var viewWidth: CGFloat = .zero
    private let bannerView = GADBannerView()
    private let adUnitID = "ca-app-pub-8133897183984535/3599635240" // TEST id; "ca-app-pub-3940256099942544/2435281174" // ROAD BANNER STENGT TUNNEL:
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let bannerViewController = BannerViewController()
        bannerView.adUnitID = adUnitID
        bannerView.rootViewController = bannerViewController
        bannerViewController.view.addSubview(bannerView)
        bannerViewController.delegate = context.coordinator
        
        return bannerViewController
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        guard viewWidth != .zero else { return }
        // Request a banner ad with the updated viewWidth.   
        print("Loading ads with \(viewWidth)")
        bannerView.adSize = GADCurrentOrientationAnchoredAdaptiveBannerAdSizeWithWidth(viewWidth)
        bannerView.load(GADRequest())
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, BannerViewControllerWidthDelegate {
        let parent: BannerView
        
        init(_ parent: BannerView) {
            self.parent = parent
        }
        
        // MARK: - BannerViewControllerWidthDelegate methods
        
        func bannerViewController(_ bannerViewController: BannerViewController, didUpdate width: CGFloat) {
            // Pass the viewWidth from Coordinator to BannerView.
            parent.viewWidth = width
        }
    }
    
    // MARK: - GADBannerViewDelegate methods
    
    func bannerViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("\(#function) called")
    }
    
    func bannerView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: Error) {
        print("\(#function) called")
    }
    
    func bannerViewDidRecordImpression(_ bannerView: GADBannerView) {
        print("\(#function) called")
    }
    
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("\(#function) called")
    }
    
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("\(#function) called")
    }
    
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
        print("\(#function) called")
    }
    
}

#Preview {
    BannerView()
}
