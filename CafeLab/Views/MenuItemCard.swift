//
//  MenuItemCard.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import SwiftUI

struct MenuItemCard: View {
    let item: MenuItem
    @EnvironmentObject private var cartManager: CartManager

    private var quantity: Int { cartManager.quantity(for: item.id) }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            thumbnail

            Text(item.name)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(item.isAvailable ? .primary : .secondary)
                .lineLimit(1)

            Text(item.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(2)
                .frame(height: 32, alignment: .top)

            HStack(alignment: .center) {
                Text(item.price, format: .currency(code: "USD"))
                    .font(.footnote.weight(.medium))
                Spacer()
                if item.isAvailable {
                    addControl
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.background)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(.separator, lineWidth: 0.5)
        )
        .opacity(item.isAvailable ? 1 : 0.6)
    }

    private var thumbnail: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { proxy in
                thumbnailImage
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .clipped()
            }
            .aspectRatio(1.3, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            if !item.isAvailable {
                Text("Out of stock")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 3)
                    .background(Capsule().fill(.black.opacity(0.65)))
                    .padding(6)
            }
        }
    }

    @ViewBuilder
    private var thumbnailImage: some View {
        if let urlString = item.thumbnailURL, let url = URL(string: urlString) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color.secondary.opacity(0.12)
                        ProgressView()
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                case .failure:
                    placeholder
                @unknown default:
                    placeholder
                }
            }
        } else {
            placeholder
        }
    }

    private var placeholder: some View {
        ZStack {
            Color.secondary.opacity(0.12)
            Image(systemName: "fork.knife")
                .font(.title2)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private var addControl: some View {
        if quantity == 0 {
            Button {
                cartManager.add(item)
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
            }
            .buttonStyle(.plain)
        } else {
            HStack(spacing: 8) {
                Button {
                    cartManager.decrement(item.id)
                } label: {
                    Image(systemName: "minus.circle.fill")
                }
                Text("\(quantity)")
                    .font(.footnote.monospacedDigit())
                    .frame(minWidth: 14)
                Button {
                    cartManager.increment(item.id)
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
            .font(.title3)
            .buttonStyle(.plain)
        }
    }
}
