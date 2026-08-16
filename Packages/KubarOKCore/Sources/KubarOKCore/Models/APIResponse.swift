import Foundation

public struct APIDataResponse<Item: Codable & Sendable>: Codable, Sendable {

    public let data: Item

    public init(data: Item) {
        self.data = data
    }
}

public struct PaginatedResponse<Item: Codable & Sendable>: Codable, Sendable {

    public let data: [Item]
    public let links: PaginationLinks
    public let meta: PaginationMeta

    public init(data: [Item], links: PaginationLinks, meta: PaginationMeta) {
        self.data = data
        self.links = links
        self.meta = meta
    }
}

public struct PaginationLinks: Codable, Sendable, Equatable {

    public let first: String?
    public let last: String?
    public let previous: String?
    public let next: String?

    public init(first: String?, last: String?, previous: String?, next: String?) {
        self.first = first
        self.last = last
        self.previous = previous
        self.next = next
    }

    enum CodingKeys: String, CodingKey {
        case first
        case last
        case previous = "prev"
        case next
    }
}

public struct PaginationMeta: Codable, Sendable, Equatable {

    public let currentPage: Int
    public let from: Int?
    public let lastPage: Int
    public let path: String
    public let perPage: Int
    public let to: Int?
    public let total: Int

    public init(
        currentPage: Int,
        from: Int?,
        lastPage: Int,
        path: String,
        perPage: Int,
        to: Int?,
        total: Int
    ) {
        self.currentPage = currentPage
        self.from = from
        self.lastPage = lastPage
        self.path = path
        self.perPage = perPage
        self.to = to
        self.total = total
    }

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case from
        case lastPage = "last_page"
        case path
        case perPage = "per_page"
        case to
        case total
    }
}
