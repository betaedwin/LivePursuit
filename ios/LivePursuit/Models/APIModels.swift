import Foundation

struct APIResponse<T: Decodable>: Decodable {
    let data: T?
    let error: APIError?
}

struct APIError: Decodable, Error {
    let code: String
    let message: String
    let details: [APIErrorDetail]?
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        message
    }

    var failureReason: String? {
        code
    }

    var recoverySuggestion: String? {
        guard let details, !details.isEmpty else { return nil }
        return details.map { detail in
            if let field = detail.field, !field.isEmpty {
                return "\(field): \(detail.message)"
            }
            return detail.message
        }.joined(separator: " ")
    }
}

struct APIErrorDetail: Decodable {
    let field: String?
    let message: String
}
