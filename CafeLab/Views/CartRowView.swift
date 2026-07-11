//
//  CartRowView.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import SwiftUI

struct CartRowView: View {
    let line: CartLine
    @EnvironmentObject private var cartManager: CartManager

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(line.item.name)
                    .font(.body.weight(.semibold))
                Text(line.item.price, format: .currency(code: "MYR"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 10) {
                Button {
                    cartManager.decrement(line.item.id)
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                Text("\(line.quantity)")
                    .font(.body.monospacedDigit())
                    .frame(minWidth: 16)
                Button {
                    cartManager.increment(line.item.id)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .font(.title3)
            .buttonStyle(.plain)

            Text(line.subtotal, format: .currency(code: "MYR"))
                .font(.subheadline.weight(.medium))
                .frame(width: 64, alignment: .trailing)
        }
        .swipeActions {
            Button("Remove", role: .destructive) {
                cartManager.remove(line.item.id)
            }
        }
    }
}
