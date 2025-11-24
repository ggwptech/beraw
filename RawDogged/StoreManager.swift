//
//  StoreManager.swift
//  RawDogged
//

import Foundation
import StoreKit
import Combine

@MainActor
class StoreManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var purchaseError: String?
    
    weak var appStateManager: AppStateManager?
    
    private let productIDs = [
        "com.getcode.BeRaw.weekly",
        "com.getcode.BeRaw.yearly"
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    
    init() {
        updateListenerTask = listenForTransactions()
        
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    // MARK: - Load Products
    
    func loadProducts() async {
        do {
            isLoading = true
            products = try await Product.products(for: productIDs)
            isLoading = false
        } catch {
            print("Failed to load products: \(error)")
            isLoading = false
        }
    }
    
    // MARK: - Purchase
    
    func purchase(_ product: Product) async throws {
        isLoading = true
        purchaseError = nil
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await updatePurchasedProducts()
            await transaction.finish()
            isLoading = false
            
        case .userCancelled:
            isLoading = false
            throw PurchaseError.userCancelled
            
        case .pending:
            isLoading = false
            throw PurchaseError.pending
            
        @unknown default:
            isLoading = false
            throw PurchaseError.unknown
        }
    }
    
    // MARK: - Restore Purchases
    
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            isLoading = false
        } catch {
            print("Failed to restore purchases: \(error)")
            isLoading = false
        }
    }
    
    // MARK: - Update Purchased Products
    
    func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                // Check if subscription is active (not revoked and not expired)
                let isActive: Bool
                if let expirationDate = transaction.expirationDate {
                    isActive = transaction.revocationDate == nil && expirationDate > Date()
                } else {
                    // Non-subscription purchases (shouldn't happen for subscriptions)
                    isActive = transaction.revocationDate == nil
                }
                
                if isActive {
                    purchasedIDs.insert(transaction.productID)
                }
            } catch {
                print("Transaction verification failed: \(error)")
            }
        }
        
        let hadPremium = !purchasedProductIDs.isEmpty
        purchasedProductIDs = purchasedIDs
        let hasPremium = !purchasedProductIDs.isEmpty
        
        // Notify AppState if premium status changed
        if hadPremium != hasPremium {
            appStateManager?.updatePremiumStatus()
        }
    }
    
    // MARK: - Listen for Transactions
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached { @MainActor [weak self] in
            guard let self = self else { return }
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchasedProducts()
                    await transaction.finish()
                } catch {
                    print("Transaction update failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Verification
    
    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Helper
    
    var isPremium: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    func product(for id: String) -> Product? {
        products.first { $0.id == id }
    }
}

// MARK: - Errors

enum PurchaseError: LocalizedError {
    case userCancelled
    case pending
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .userCancelled:
            return "Purchase was cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .verificationFailed:
            return "Purchase verification failed"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
