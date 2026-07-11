//
//  APIService.swift
//  CafeLab
//
//  Created by Mohamad Shawal Sapuan Bin Mohamad on 11/07/2026.
//

import Foundation

private struct ProductsResponse: Decodable {
    let products: [Product]
}

private struct Product: Decodable {
    let id: Int
    let title: String
    let description: String
    let price: Double
    let category: String
    let stock: Int
    let availabilityStatus: String?
    let thumbnail: String?
}

enum APIError: Error, LocalizedError {
    case invalidResponse
    case decoding(Error)
    case transport(Error)

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .decoding:
            return "We couldn't read the menu data."
        case .transport:
            return "Check your connection and try again."
        }
    }
}

enum APIService {
    private static let endpoint = URL(
        string: "https://dummyjson.com/products?limit=100"
    )!

    static func fetchMenuItems() async throws -> [MenuItem] {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: endpoint)
        } catch {
            throw APIError.transport(error)
        }

        guard let http = response as? HTTPURLResponse,
            (200..<300).contains(http.statusCode)
        else {
            throw APIError.invalidResponse
        }

        do {
            let decoded = try JSONDecoder().decode(
                ProductsResponse.self,
                from: data
            )
            return decoded.products.map { product in
                MenuItem(
                    id: product.id,
                    name: product.title,
                    description: product.description,
                    price: product.price,
                    category: product.category.capitalized,
                    isAvailable: product.stock > 0
                        && product.availabilityStatus != "Out of Stock",
                    thumbnailURL: product.thumbnail
                )
            }
        } catch {
            throw APIError.decoding(error)
        }
    }
}
