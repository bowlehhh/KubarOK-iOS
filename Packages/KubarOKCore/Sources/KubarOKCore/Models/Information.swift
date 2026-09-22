import Foundation

public struct RemoteFile: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let fileName: String?
    public let fileSize: Int?
    public let contentType: String?
    public let title: String?
    public let description: String?
    public let path: String
    public let fileExtension: String?

    public init(
        id: Int,
        fileName: String?,
        fileSize: Int?,
        contentType: String?,
        title: String?,
        description: String?,
        path: String,
        fileExtension: String?
    ) {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
        self.contentType = contentType
        self.title = title
        self.description = description
        self.path = path
        self.fileExtension = fileExtension
    }

    enum CodingKeys: String, CodingKey {
        case id
        case fileName = "file_name"
        case fileSize = "file_size"
        case contentType = "content_type"
        case title
        case description
        case path
        case fileExtension = "extension"
    }
}

public struct InformationItem: Codable, Sendable, Equatable, Identifiable {

    public let id: Int
    public let title: String
    public let description: String
    public let isAnnouncement: Int
    public let bureauId: Int?
    public let createdAt: String?
    public let updatedAt: String?
    public let file: RemoteFile?
    public let contentFile: RemoteFile?
    public let bureau: Bureau?

    public init(
        id: Int,
        title: String,
        description: String,
        isAnnouncement: Int,
        bureauId: Int?,
        createdAt: String?,
        updatedAt: String?,
        file: RemoteFile?,
        contentFile: RemoteFile?,
        bureau: Bureau?
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isAnnouncement = isAnnouncement
        self.bureauId = bureauId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.file = file
        self.contentFile = contentFile
        self.bureau = bureau
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case isAnnouncement = "is_announcement"
        case bureauId = "bureau_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case file
        case contentFile = "content_file"
        case bureau
    }
}

public struct AnnouncementFile: Codable, Sendable, Equatable {

    public let id: Int
    public let path: String

    public init(id: Int, path: String) {
        self.id = id
        self.path = path
    }
}
