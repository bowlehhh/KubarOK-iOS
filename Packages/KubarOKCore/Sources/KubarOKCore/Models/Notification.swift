import Foundation

public struct UserNotification: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let title: String
    public let description: String
    public let submissionId: String?
    public let isRead: Int
    public let userId: Int
    public let createdAt: String?
    public let updatedAt: String?

    public init(
        id: Int,
        title: String,
        description: String,
        submissionId: String?,
        isRead: Int,
        userId: Int,
        createdAt: String?,
        updatedAt: String?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.submissionId = submissionId
        self.isRead = isRead
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case submissionId = "submission_id"
        case isRead = "is_read"
        case userId = "user_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
