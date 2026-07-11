//
//  CardView.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import SwiftUI

struct CartView: View {
    @EnvironmentObject private var cartManager: CartManager

    var body: some View {
        content
            .navigationTitle("ORDER CONFIRMATION")
            .toolbarBackground(Color.zusBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .alert(
                "Order placed!",
                isPresented: successBinding,
                actions: {
                    Button("OK") { cartManager.resetCheckoutState() }
                },
                message: {
                    if case .success(let orderID) = cartManager.checkoutState {
                        Text("Order #\(orderID) is on its way.")
                    }
                }
            )
            .alert(
                "Checkout failed",
                isPresented: failureBinding,
                actions: {
                    Button("OK") { cartManager.resetCheckoutState() }
                },
                message: {
                    if case .failure(let message) = cartManager.checkoutState {
                        Text(message)
                    }
                }
            )
    }

    @ViewBuilder
    private var content: some View {
        if cartManager.orderedLines.isEmpty {
            emptyState
        } else {
            VStack(spacing: 0) {
                List {
                    ForEach(cartManager.orderedLines) { line in
                        CartRowView(line: line)
                    }
                }
                .listStyle(.insetGrouped)

                summaryFooter
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Your cart is empty")
                .font(.headline)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var summaryFooter: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Total")
                    .font(.headline)
                Spacer()
                Text(cartManager.totalPrice, format: .currency(code: "MYR"))
                    .font(.headline)
            }

            Button {
                Task { await cartManager.placeOrder() }
            } label: {
                Group {
                    if cartManager.checkoutState == .loading {
                        ProgressView()
                    } else {
                        Text("ORDER NOW")
                            .font(.headline)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.zusBlue)
            .buttonBorderShape(.capsule)
            .disabled(cartManager.checkoutState == .loading)
        }
        .padding()
        .background(.bar)
    }

    private var successBinding: Binding<Bool> {
        Binding(
            get: {
                if case .success = cartManager.checkoutState { return true }
                return false
            },
            set: { if !$0 { cartManager.resetCheckoutState() } }
        )
    }

    private var failureBinding: Binding<Bool> {
        Binding(
            get: {
                if case .failure = cartManager.checkoutState { return true }
                return false
            },
            set: { if !$0 { cartManager.resetCheckoutState() } }
        )
    }
}

#Preview {
    NavigationStack { CartView() }
        .environmentObject(CartManager())
}
