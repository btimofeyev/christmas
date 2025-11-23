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
        let deviceId = UIDevice.current.identifierForVendor?.uuidString ?? UUID().uuidString
        let configuration = Configuration.Builder(withAPIKey: AppConfig.revenueCatAPIKey)
            .with(appUserID: deviceId)
            .build()
        Purchases.configure(with: configuration)
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
