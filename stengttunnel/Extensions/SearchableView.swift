//
//  SearchableView.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 05/08/2023.
//

import SwiftUI

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension SwiftUI.View {
    public func searchableOnce(text: SwiftUI.Binding<Swift.String>, placement: SwiftUI.SearchFieldPlacement = .automatic, prompt: SwiftUI.Text? = nil, isPresented: SwiftUI.Binding<Swift.Bool>) -> some SwiftUI.View {
        return SearchableOnce(isPresented: isPresented, content: self, text: text, placement: placement, prompt: prompt)
  }

    public func searchableOnce(text: SwiftUI.Binding<Swift.String>, placement: SwiftUI.SearchFieldPlacement = .automatic, prompt: SwiftUI.LocalizedStringKey, isPresented: SwiftUI.Binding<Swift.Bool>) -> some SwiftUI.View {
        return SearchableOnce(isPresented: isPresented, content: self, text: text, placement: placement, prompt: Text(prompt))
  }

    @_disfavoredOverload public func searchableOnce<S>(text: SwiftUI.Binding<Swift.String>, placement: SwiftUI.SearchFieldPlacement = .automatic, prompt: S, isPresented: SwiftUI.Binding<Swift.Bool>) -> some SwiftUI.View where S : Swift.StringProtocol {
        return SearchableOnce(isPresented: isPresented, content: self, text: text, placement: placement, prompt: Text(prompt))
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
fileprivate struct SearchableOnce<Content: View>: View {
    @State private var wantDismiss = false
    var isPresented: Binding<Bool>
    var content: Content
    var text: Binding<String>
    var placement: SearchFieldPlacement
    var prompt: Optional<Text>

    var body: some View {
        Dismisser(wantDismiss: $wantDismiss, content: content)
            .searchable(text: text, isPresented: isPresented, placement: placement, prompt: prompt)
            .onSubmit(of: .search) {
                wantDismiss = true
            }
    }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
fileprivate struct Dismisser<Content: View>: View {
    @Environment(\.dismissSearch) private var dismissSearch
    @Binding var wantDismiss: Bool
    var content: Content

    var body: some View {
        content
            .onChange(of: wantDismiss) {
                _, newValue in
                    if newValue {
                        dismissSearch()
                        wantDismiss = false
                    }

            }
    }
}
