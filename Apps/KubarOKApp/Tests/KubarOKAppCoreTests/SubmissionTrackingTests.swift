import Testing
import KubarOKAppCore
import KubarOKCore

@Test func historyStateStartsEmpty() {
    let state = SubmissionHistoryState()
    #expect(state.submissions.isEmpty)
    #expect(!state.canLoadNextPage)
    #expect(state.nextPage == nil)
}

@Test func historyStateKeepsFilterAndReplacesFirstPage() {
    var state = SubmissionHistoryState()
    state.setStateFilter(.open)
    state.replace(with: response(items: [history(id: "001")], page: 1, lastPage: 2))
    #expect(state.stateFilter == .open)
    #expect(state.submissions.map(\.id) == ["001"])
    #expect(state.nextPage == 2)
}

@Test func historyStateAppendsWithoutDuplicates() {
    var state = SubmissionHistoryState()
    state.replace(with: response(items: [history(id: "001")], page: 1, lastPage: 2))
    state.append(response(items: [history(id: "001"), history(id: "002")], page: 2, lastPage: 2))
    #expect(state.submissions.map(\.id) == ["001", "002"])
    #expect(!state.canLoadNextPage)
}

@Test func timelineUsesValidationFromBackendDetail() {
    let progress = SubmissionProgress(id: 11, state: .accepted, notes: "Berkas lengkap", dispatchedAt: "2026-08-16 08:00:00", validatedAt: "2026-08-16 09:00:00", submissionId: 1, procedureId: 2, validatorId: 3)
    let detail = SubmissionDetail(id: "001", state: .open, serviceId: 8, submitterId: 9, applicantId: 10, submittedAt: nil, requisiteChecks: [], validation: [
        SubmissionValidationProcedure(id: 3, name: "Tahap akhir", description: nil, sequence: 2, serviceId: 8, progress: nil, isLatest: true),
        SubmissionValidationProcedure(id: 2, name: "Verifikasi", description: "Pemeriksaan berkas", sequence: 1, serviceId: 8, progress: progress, isLatest: false)
    ])
    let items = SubmissionTimelineMapper.items(from: detail)
    #expect(items.map(\.title) == ["Verifikasi", "Tahap akhir"])
    #expect(items.first?.note == "Berkas lengkap")
    #expect(items.last?.isLatest == true)
}

private func history(id: String) -> SubmissionHistoryItem {
    SubmissionHistoryItem(id: id, state: .open, serviceId: 8, submitterId: 9, applicantId: 10, submittedAt: nil, createdAt: nil, updatedAt: nil, service: nil, progress: nil)
}

private func response(items: [SubmissionHistoryItem], page: Int, lastPage: Int) -> PaginatedResponse<SubmissionHistoryItem> {
    PaginatedResponse(
        data: items,
        links: PaginationLinks(first: nil, last: nil, previous: nil, next: nil),
        meta: PaginationMeta(currentPage: page, from: nil, lastPage: lastPage, path: "submission", perPage: 10, to: nil, total: items.count)
    )
}
