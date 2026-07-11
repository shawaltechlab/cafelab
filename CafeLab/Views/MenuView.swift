//
//  MenuView.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import SwiftUI

struct MenuView: View {
    @StateObject private var viewModel = MenuViewModel()
    @EnvironmentObject private var cartManager: CartManager

    @State private var showCart = false

    private let columns = [
        GridItem(.adaptive(minimum: 150, maximum: 220), spacing: 12)
    ]

    var body: some View {
        content
            .navigationTitle("CAFE LAB")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.zusBlue, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .safeAreaInset(edge: .bottom) {
                cartBar
            }
            .navigationDestination(isPresented: $showCart) {
                CartView()
            }
            .task {
                await viewModel.loadIfNeeded()
            }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .idle, .loading:
            ProgressView("Loading menu…")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .error(let message):
            errorView(message)
        case .loaded:
            menuList
        }
    }

    //MARK: Grid
    private var menuList: some View {
        ScrollView {
            LazyVStack(
                alignment: .leading,
                spacing: 24,
                pinnedViews: [.sectionHeaders]
            ) {
                ForEach(viewModel.itemsByCategory, id: \.category) { section in
                    Section {
                        LazyVGrid(columns: columns, spacing: 12) {
                            ForEach(section.items) { item in
                                MenuItemCard(item: item)
                            }
                        }
                        .padding(.horizontal)
                    } header: {
                        Text(section.category)
                            .font(.title3.weight(.bold))
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.bar)
                    }
                }
            }
            .padding(.vertical)
        }
        .refreshable {
            await viewModel.load()
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("Couldn't load the menu")
                .font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Try Again") {
                Task { await viewModel.load() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.zusBlue)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    //MARK: Bottom cart bar
    private var cartBar: some View {
        Button {
            showCart = true
        } label: {
            HStack(spacing: 12) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: "cart.fill")
                        .font(.title3)
                        .frame(width: 26, height: 26)

                    if cartManager.totalItemCount > 0 {
                        Text("\(cartManager.totalItemCount)")
                            .font(.caption2.bold())
                            .foregroundStyle(Color.zusBlue)
                            .padding(4)
                            .frame(minWidth: 18, minHeight: 18)
                            .background(Circle().fill(Color.liteBlue))
                            .offset(x: 10, y: -8)
                    }
                }
                .padding(.trailing, 4)

                Text(cartItemCountLabel)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                    .layoutPriority(1)

                Spacer(minLength: 12)

                Text(cartManager.totalPrice, format: .currency(code: "USD"))
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .layoutPriority(1)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .opacity(0.8)
            }
            .foregroundStyle(Color.zusBlue)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .background(.white)
        }
        .buttonStyle(.plain)
    }

    private var cartItemCountLabel: String {
        let count = cartManager.totalItemCount
        return "\(count) item\(count == 1 ? "" : "s")"
    }
}

#Preview {
    NavigationStack { MenuView() }
        .environmentObject(CartManager())
}
