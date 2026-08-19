import Foundation
import KubarOKCore

public struct SubmissionHistoryState: Sendable {
    public private(set) var submissions: [SubmissionHistoryItem]
    public private(set) var pagination: PaginationMeta?
    public private(set) var stateFilter: SubmissionState?

    public init(
        submissions: [SubmissionHistoryItem] = [],
        pagination: PaginationMeta? = nil,
        stateFilter: SubmissionState? = nil
    ) {
        self.submissions = submissions
        self.pagination = pagination
        self.stateFilter = stateFilter
    }

    public var canLoadNextPage: Bool {
        guard let pagination else { return false }
        return pagination.currentPage < pagination.lastPage
    }

    public var nextPage: Int? {
        guard canLoadNextPage, let pagination else { return nil }
        return pagination.currentPage + 1
    }

    public mutating func setStateFilter(_ state: SubmissionState?) {
        stateFilter = state
    }

    public mutating func replace(with response: PaginatedResponse<SubmissionHistoryItem>) {
        submissions = response.data
        pagination = response.meta
    }

    public mutating func append(_ response: PaginatedResponse<SubmissionHistoryItem>) {
        var seenIDs = Set(submissions.map(\.id))
        submissions.append(contentsOf: response.data.filter { seenIDs.insert($0.id).inserted })
        pagination = response.meta
    }
}

public struct SubmissionTimelineItem: Sendable, Equatable, Identifiable {
    public let id: Int
    public let title: String
    public let description: String?
    public let state: SubmissionProgressState?
    public let note: String?
    public let occurredAt: String?
    public let isLatest: Bool

    public init(
        id: Int,
        title: String,
        description: String?,
        state: SubmissionProgressState?,
        note: String?,
        occurredAt: String?,
        isLatest: Bool
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.state = state
        self.note = note
        self.occurredAt = occurredAt
        self.isLatest = isLatest
    }
}

public enum SubmissionTimelineMapper {
    public static func items(from detail: SubmissionDetail) -> [SubmissionTimelineItem] {
        detail.validation
            .sorted { ($0.sequence ?? 0) < ($1.sequence ?? 0) }
            .map { procedure in
                SubmissionTimelineItem(
                    id: procedure.id,
                    title: procedure.name,
                    description: procedure.description,
                    state: procedure.progress?.state,
                    note: procedure.progress?.notes,
                    occurredAt: procedure.progress?.validatedAt ?? procedure.progress?.dispatchedAt,
                    isLatest: procedure.isLatest
                )
            }
    }
}
