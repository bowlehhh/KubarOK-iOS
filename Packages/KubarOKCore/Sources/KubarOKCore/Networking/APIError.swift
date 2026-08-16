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

            if let body, !body.isEmpty {
                description += " Response backend: \(body)"
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
}
