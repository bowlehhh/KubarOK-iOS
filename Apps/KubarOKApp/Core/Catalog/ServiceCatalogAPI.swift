import Foundation
import KubarOKCore

public protocol ServiceCatalogAPI: Sendable {

    func fetchBureaus(
        apiToken: String,
        page: Int?
    ) async throws -> PaginatedResponse<Bureau>
    func fetchServices(
        apiToken: String,
        bureauID: Int,
        page: Int?
    ) async throws -> PaginatedResponse<GovernmentService>
    func fetchServiceDetail(
        apiToken: String,
        serviceID: Int
    ) async throws -> GovernmentService
}

public final class LiveServiceCatalogAPI: ServiceCatalogAPI, Sendable {

    public init() {}

    public func fetchBureaus(
        apiToken: String,
        page: Int?
    ) async throws -> PaginatedResponse<Bureau> {
        try await BureauService.shared.getBureaus(apiToken: apiToken, page: page)
    }

    public func fetchServices(
        apiToken: String,
        bureauID: Int,
        page: Int?
    ) async throws -> PaginatedResponse<GovernmentService> {
        try await GovernmentServiceAPI.shared.getServices(
            apiToken: apiToken,
            bureauID: bureauID,
            page: page
        )
    }

    public func fetchServiceDetail(
        apiToken: String,
        serviceID: Int
    ) async throws -> GovernmentService {
        try await GovernmentServiceAPI.shared.getServiceDetail(
            apiToken: apiToken,
            id: serviceID
        )
    }
}
