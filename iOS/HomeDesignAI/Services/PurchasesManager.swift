import Foundation
import RevenueCat

@MainActor
final class PurchasesManager: NSObject, ObservableObject {
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var offerings: Offerings?
    @Published var isProUnlocked: Bool = false
    @Published var isLoading: Bool = false
    @Published var isPurchasing: Bool = false
    @Published var errorMessage: String?

    override init() {
        super.init()
        if Purchases.isConfigured {
            Purchases.shared.delegate = self

            Task {
                await refreshCustomerInfo()
                await fetchOfferings(force: true)
            }
        }
    }

    func refreshCustomerInfo() async {
        guard Purchases.isConfigured else { return }

        errorMessage = nil
        do {
            let info = try await Purchases.shared.customerInfo()
            handleUpdated(customerInfo: info)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func fetchOfferings(force: Bool = false) async {
        guard Purchases.isConfigured else { return }

        if !force, offerings != nil { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            offerings = try await Purchases.shared.offerings()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func purchase(package: Package) async {
        guard Purchases.isConfigured else { return }

        guard !isPurchasing else { return }

        isPurchasing = true
        errorMessage = nil
        defer { isPurchasing = false }

        do {
            let result = try await Purchases.shared.purchase(package: package)

            guard !result.userCancelled else { return }

            handleUpdated(customerInfo: result.customerInfo)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        guard Purchases.isConfigured else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let info = try await Purchases.shared.restorePurchases()
            handleUpdated(customerInfo: info)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func handleUpdated(customerInfo info: CustomerInfo) {
        customerInfo = info
        updateEntitlements(with: info)
    }

    private func updateEntitlements(with info: CustomerInfo) {
        let entitlement = info.entitlements[AppConfig.revenueCatEntitlementId]
        isProUnlocked = entitlement?.isActive == true
    }
}

extension PurchasesManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor [weak self] in
            self?.handleUpdated(customerInfo: customerInfo)
        }
    }
}
