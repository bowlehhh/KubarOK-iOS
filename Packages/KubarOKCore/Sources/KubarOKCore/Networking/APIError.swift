import Foundation

public enum APIError: Error, LocalizedError {

    case invalidResponse
    case httpError(statusCode: Int, body: String?)
    case invalidData
    case decoding(Error)
    case network(Error)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Response dari server tidak valid."
        case .httpError(let statusCode, let body):
            var description = "Server mengembalikan HTTP status \(statusCode)."

            if let message = Self.extractBackendMessage(from: body) {
                description += " \(message)"
            }

            return description
        case .invalidData:
            return "Data dari server tidak dapat dibaca."
        case .decoding(let error):
            return "Response server tidak sesuai format yang diharapkan: \(error.localizedDescription)"
        case .network(let error):
            return "Terjadi kesalahan jaringan: \(error.localizedDescription)"
        }
    }

    /// Extracts Laravel/October API validation messages without exposing an
    /// entire response body that may contain account data.
    public var backendMessage: String? {
        guard case .httpError(_, let body) = self else { return nil }
        return Self.extractBackendMessage(from: body)
    }

    private static func extractBackendMessage(from body: String?) -> String? {
        guard let body, !body.isEmpty, let data = body.data(using: .utf8) else {
            return nil
        }

        guard let json = try? JSONSerialization.jsonObject(with: data),
              let object = json as? [String: Any],
              let error = object["error"] ?? object["message"] else {
            return nil
        }

        return flatten(error).first
    }

    private static func flatten(_ value: Any) -> [String] {
        if let string = value as? String {
            return string.isEmpty ? [] : [string]
        }
        if let values = value as? [Any] {
            return values.flatMap(flatten)
        }
        if let values = value as? [String: Any] {
            return values.keys.sorted().flatMap { key -> [String] in
                guard let nested = values[key] else { return [] }
                return flatten(nested).map { "\(key): \($0)" }
            }
        }
        return []
    }
}
