// Developed by Artem Bartle

import Foundation
import Combine
import SwiftUI

enum ConverterError: Error {
    case badURL
    case network
    case decoding
    case unknown(description: String)
}

@MainActor
class CurrencyConverter: ObservableObject {
    private var rate: Double?
    @Published var loading = false
    @Published var converted = false
    @Published var failed = false
    
    private let urlSession = URLSession.shared
    private let priceFormatter = NumberFormatter()
    private var disposables = Set<AnyCancellable>()
    
    let from: Currency
    let to: Currency
    
    init(from: Currency, to: Currency) {
        self.from = from
        self.to = to
        
        priceFormatter.isLenient = true
        priceFormatter.numberStyle = .currency
        priceFormatter.currencyCode = self.from.rawValue.lowercased()
        
        $converted
            .debounce(for: .seconds(0.25), scheduler: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                if value {
                    Task {
                        await self.refreshRate()
                    }
                }
            }
            .store(in: &disposables)
    }
        
    func formattedPrice(_ value: Double?) -> String {
        guard let value = value else { return "" }
        
        if converted {
            guard let rate = rate else { return "..." }
            priceFormatter.currencyCode = to.rawValue.lowercased()
            return priceFormatter.string(from: NSNumber(value: value * rate)) ?? ""
        } else {
            priceFormatter.currencyCode = from.rawValue.lowercased()
            return priceFormatter.string(from: NSNumber(value: value)) ?? ""
        }
    }
        
    func refreshRate() async {
        loading = true
        failed = false
        
        defer {
            loading = false
        }
        
        let request = Request(amount: 1.0, fromCurrency: from, toCurrency: to)
        do {
            let response = try await load(request: request)
            rate = response.rate
        } catch {
            failed = true
            converted = false
        }
    }
    
    private func load(request: Request) async throws -> Response {
        guard let url = URL(string: "https://elementsofdesign.api.stdlib.com/aavia-currency-converter@dev/") else {
            throw ConverterError.badURL
        }
        
        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(request)
                                    
            let (data, _) = try await urlSession.data(for: urlRequest)

            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(Response.self, from: data)
        } catch is URLError {
            throw ConverterError.network
        } catch is DecodingError {
            throw ConverterError.decoding
        } catch {
            throw ConverterError.unknown(description: error.localizedDescription)
        }
    }
}

extension CurrencyConverter {
    enum Currency: String, Encodable {
        case eur = "EUR"
        case usd = "USD"
    }
    
    struct Request: Encodable {
        var amount: Double
        var fromCurrency: Currency
        var toCurrency: Currency
    }

    struct Response: Decodable {
        var amount: Double
        var rate: Double
    }
}
