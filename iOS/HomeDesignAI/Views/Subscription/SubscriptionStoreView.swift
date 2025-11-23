import SwiftUI
import RevenueCat
#if canImport(RevenueCatUI)
import RevenueCatUI
#endif

struct SubscriptionStoreView: View {
    @ObservedObject var viewModel: HomeDesignViewModel
    @EnvironmentObject private var purchasesManager: PurchasesManager
    @Environment(\.dismiss) private var dismiss
    @State private var showCustomerCenter = false
    private let featuredProductOrder = [
        AppConfig.revenueCatBasicPackProduct,
        AppConfig.revenueCatHolidayUnlimitedProduct
    ]

    var body: some View {
        customerCenterWrappedView
    }

    private var holidayPackages: [Package] {
        guard let packages = purchasesManager.activeOffering?.availablePackages else { return [] }
        let allowed = Set(featuredProductOrder)
        let filtered = packages.filter { allowed.contains($0.storeProduct.productIdentifier) }
        return filtered.sorted { lhs, rhs in
            let lhsIndex = featuredProductOrder.firstIndex(of: lhs.storeProduct.productIdentifier) ?? Int.max
            let rhsIndex = featuredProductOrder.firstIndex(of: rhs.storeProduct.productIdentifier) ?? Int.max
            return lhsIndex < rhsIndex
        }
    }

    @ViewBuilder
    private var customerCenterWrappedView: some View {
        #if canImport(RevenueCatUI)
        if #available(iOS 15.0, *) {
            content
                .presentCustomerCenter(
                    isPresented: $showCustomerCenter,
                    presentationMode: .sheet,
                    restoreCompleted: { info in
                        purchasesManager.handleUpdated(customerInfo: info)
                    },
                    restoreFailed: { error in
                        purchasesManager.errorMessage = error.localizedDescription
                    },
                    onDismiss: { showCustomerCenter = false }
                )
        } else {
            content
        }
        #else
        content
        #endif
    }

    private var content: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    header
                    if purchasesManager.isProUnlocked,
                       let entitlement = purchasesManager.customerInfo?.entitlements[AppConfig.revenueCatEntitlementId] {
                        SubscriptionStatusCard(entitlement: entitlement)
                    }
                    paywallSection
                    packageList
                    helperButtons
                    if let message = purchasesManager.errorMessage {
                        ErrorBanner(message: message)
                    }
                }
                .padding()
            }
            .navigationTitle("Unlock More Designs")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Restore") {
                        Task { await purchasesManager.restorePurchases() }
                    }
                    .disabled(purchasesManager.isLoading)
                }
            }
        }
        .task {
            await purchasesManager.fetchOfferings(force: false)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Holiday Boosts")
                .font(AppFonts.title2)
                .fontWeight(.bold)

            Text("Grab a Basic pack or unlock Unlimited access for the rest of the season.")
                .font(AppFonts.callout)
                .foregroundColor(.secondary)

            HStack {
                Label("\(viewModel.generationsRemaining) designs remaining", systemImage: "flame")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.primary)

                Spacer()

                if purchasesManager.isProUnlocked {
                    Label("JMM Production Pro active", systemImage: "checkmark.seal.fill")
                        .font(AppFonts.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(12)
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: AppColors.deepShadow.opacity(0.1), radius: 6, x: 0, y: 3)
        }
    }

    @ViewBuilder
    private var paywallSection: some View {
        #if canImport(RevenueCatUI)
        if #available(iOS 15.0, *), let offering = purchasesManager.activeOffering, offering.hasPaywall {
            PaywallView(offering: offering, displayCloseButton: false)
                .frame(minHeight: 460)
                .background(AppColors.surface)
                .cornerRadius(AppCornerRadius.lg)
                .shadow(color: AppColors.deepShadow.opacity(0.15), radius: 10, x: 0, y: 6)
        }
        #endif
    }

    private var packageList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Plans & Pricing")
                    .font(AppFonts.headline)
                Spacer()
                if purchasesManager.isPurchasing {
                    ProgressView()
                }
            }

            if !holidayPackages.isEmpty {
                ForEach(holidayPackages) { package in
                    PackageCard(package: package) {
                        Task {
                            await purchasesManager.purchase(package: package)
                        }
                    }
                }
            } else {
                Text("Holiday packages are loading from the App Store...")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
            }
        }
    }

    private var helperButtons: some View {
        VStack(spacing: 12) {
            Button {
                Task { await purchasesManager.refreshCustomerInfo() }
            } label: {
                Text("Refresh Status")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.15))
                    .cornerRadius(AppCornerRadius.md)
            }

            #if canImport(RevenueCatUI)
            if #available(iOS 15.0, *) {
                Button {
                    showCustomerCenter = true
                } label: {
                    HStack {
                        Image(systemName: "person.crop.circle.badge.questionmark")
                        Text("Manage Holiday Pass")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.surface)
                    .cornerRadius(AppCornerRadius.md)
                }
            }
            #endif
        }
    }
}

private struct PackageCard: View {
    let package: Package
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(AppFonts.headline)
                        .foregroundColor(AppColors.primary)
                    Text(subtitle)
                        .font(AppFonts.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Text(package.localizedPriceString)
                    .font(AppFonts.headline)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.primary)
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(AppColors.surface)
            .cornerRadius(AppCornerRadius.md)
            .shadow(color: AppColors.deepShadow.opacity(0.08), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var title: String {
        switch package.storeProduct.productIdentifier {
        case AppConfig.revenueCatBasicPackProduct:
            return "Basic Holiday Boost"
        case AppConfig.revenueCatHolidayUnlimitedProduct:
            return "Holiday Unlimited Pass"
        default:
            return package.storeProduct.localizedTitle
        }
    }

    private var subtitle: String {
        switch package.storeProduct.productIdentifier {
        case AppConfig.revenueCatBasicPackProduct:
            return "One-time +\(AppConfig.subscriptionBonusGenerations) designs"
        case AppConfig.revenueCatHolidayUnlimitedProduct:
            return "Unlimited redesigns through the holidays"
        default:
            return package.storeProduct.localizedDescription
        }
    }
}

private struct SubscriptionStatusCard: View {
    let entitlement: EntitlementInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("JMM Production Pro active", systemImage: "checkmark.seal.fill")
                .font(AppFonts.headline)
                .foregroundColor(.green)

            if let expiration = entitlement.expirationDate {
                Text("Access through \(expiration.formatted(date: .abbreviated, time: .omitted))")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Unlimited access active")
                    .font(AppFonts.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.1))
        .cornerRadius(AppCornerRadius.md)
    }
}

private struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.yellow)
            Text(message)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.text)
        }
        .padding()
        .background(Color.yellow.opacity(0.15))
        .cornerRadius(AppCornerRadius.md)
    }
}

#Preview {
    SubscriptionStoreView(viewModel: HomeDesignViewModel())
        .environmentObject(PurchasesManager())
}
