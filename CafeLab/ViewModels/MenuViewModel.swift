//
//  MenuViewModel.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Combine
import Foundation

enum LoadState: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

@MainActor
final class MenuViewModel: ObservableObject {
    @Published private(set) var state: LoadState = .idle
    @Published private(set) var itemsByCategory:
        [(category: String, items: [MenuItem])] = []

    func loadIfNeeded() async {
        guard state == .idle else { return }
        await load()
    }

    func load() async {
        state = .loading
        do {
            let items = try await APIService.fetchMenuItems()
            itemsByCategory = Self.group(items)
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    private static func group(_ items: [MenuItem]) -> [(
        category: String, items: [MenuItem]
    )] {
        let grouped = Dictionary(grouping: items, by: \.category)
        return
            grouped
            .map {
                (category: $0.key, items: $0.value.sorted { $0.name < $1.name })
            }
            .sorted { $0.category < $1.category }
    }
}
