//
//  HomeDesignAIApp.swift
//  HomeDesignAI
//
//  Main app entry point
//

import SwiftUI
import RevenueCat

@main
struct HomeDesignAIApp: App {
    @StateObject private var purchasesManager: PurchasesManager

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: AppConfig.revenueCatAPIKey)
        _purchasesManager = StateObject(wrappedValue: PurchasesManager())
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(purchasesManager)
                .task {
                    await purchasesManager.refreshCustomerInfo()
                }
        }
    }
}
