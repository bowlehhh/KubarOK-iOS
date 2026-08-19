import Foundation
import Testing
@testable import KubarOKCore

@Test func submissionCreateRequestUsesBackendKeys() throws {
    let request = CreateSubmissionRequest(serviceId: 8, submitterId: 9, applicableId: 10, submittedAt: "2026-08-16 10:00:00")
    let payload = try JSONSerialization.jsonObject(with: JSONEncoder().encode(request)) as? [String: Any]
    #expect(payload?["service_id"] as? Int == 8)
    #expect(payload?["submitter_id"] as? Int == 9)
    #expect(payload?["applicable_id"] as? Int == 10)
    #expect(payload?["submitted_at"] as? String == "2026-08-16 10:00:00")
}

@Test func submissionDetailDecodesBackendStateAndChecks() throws {
    let data = Data(#"{"data":{"id":"0082608160001","state":0,"service_id":8,"submitter_id":9,"applicant_id":10,"submitted_at":"2026-08-16 10:00:00","requisite_check":[{"id":3,"is_completed":0,"submission_id":82608160001,"requisite_id":4}]}}"#.utf8)
    let detail = try JSONDecoder().decode(APIDataResponse<SubmissionDetail>.self, from: data).data
    #expect(detail.state == .draft)
    #expect(detail.requisiteChecks.first?.submissionId == 82_608_160_001)
}

@Test func submissionHistoryAndTrackingDetailDecodeBackendPayloads() throws {
    let listData = Data(#"{"data":[{"id":"0082608160001","state":1,"service_id":8,"submitter_id":9,"applicant_id":10,"submitted_at":"2026-08-16 10:00:00","service":{"id":8,"name":"KTP","description":null,"is_enable":1,"sort_order":1,"bureau_id":2,"external_link":null,"is_external":0},"progress":[]}],"links":{"first":null,"last":null,"prev":null,"next":null},"meta":{"current_page":1,"from":1,"last_page":1,"path":"https://example.test/submission","per_page":10,"to":1,"total":1}}"#.utf8)
    let list = try JSONDecoder().decode(PaginatedResponse<SubmissionHistoryItem>.self, from: listData)
    #expect(list.data.first?.service?.name == "KTP")
    #expect(list.meta.perPage == 10)

    let detailData = Data(#"{"data":{"id":"0082608160001","state":1,"service_id":8,"submitter_id":9,"applicant_id":10,"submitted_at":"2026-08-16 10:00:00","requisite_check":[],"validation":[{"id":4,"name":"Verifikasi","description":"Pemeriksaan","sequence":1,"service_id":8,"latest":true,"progress":{"id":7,"state":9,"notes":"Lengkap","dispatched_at":"2026-08-16 10:05:00","validated_at":"2026-08-16 10:10:00","submission_id":82608160001,"procedure_id":4,"validator_id":2}}]}}"#.utf8)
    let detail = try JSONDecoder().decode(APIDataResponse<SubmissionDetail>.self, from: detailData).data
    #expect(detail.validation.first?.isLatest == true)
    #expect(detail.validation.first?.progress?.state == .accepted)
    #expect(detail.validation.first?.progress?.notes == "Lengkap")
}

@Test func submissionInputAndAgreementRequestsUseBackendKeys() throws {
    let inputs = SubmissionInputsRequest(requisiteInputs: [SubmissionInputValue(key: "name", value: "Kubar")])
    let inputPayload = try JSONSerialization.jsonObject(with: JSONEncoder().encode(inputs)) as? [String: Any]
    #expect((inputPayload?["requisites_inputs"] as? [[String: String]])?.first?["key"] == "name")

    let agreement = SubmissionAgreementRequest(submissionRequisiteCheckId: 3)
    let agreementPayload = try JSONSerialization.jsonObject(with: JSONEncoder().encode(agreement)) as? [String: Any]
    #expect(agreementPayload?["submission_requisite_check_id"] as? Int == 3)
}

@Test func submissionPathsUseVerifiedRoutesAndTokenHeader() {
    #expect(APIClient.shared.url(for: "submission/store").absoluteString == "https://kubarok.kutaibaratkab.go.id/v1/submission/store")
    #expect(APIClient.shared.url(for: "submission/82608160001/submit-agreement/4").path.hasSuffix("/submission/82608160001/submit-agreement/4"))
    #expect(APIClient.shared.url(for: "submission/82608160001/submit-inputs/4").path.hasSuffix("/submission/82608160001/submit-inputs/4"))
    #expect(APIClient.shared.url(for: "submission/82608160001/submit-files/4").path.hasSuffix("/submission/82608160001/submit-files/4"))
    #expect(APIClient.shared.url(for: "submission/82608160001/send-submit").path.hasSuffix("/submission/82608160001/send-submit"))
    let historyURL = APIClient.shared.url(for: "submission", queryItems: [
        URLQueryItem(name: "state", value: "1"),
        URLQueryItem(name: "service_id", value: "8"),
        URLQueryItem(name: "page", value: "2")
    ])
    #expect(historyURL.path.hasSuffix("/submission"))
    #expect(historyURL.query?.contains("state=1") == true)
    #expect(historyURL.query?.contains("service_id=8") == true)
    #expect(historyURL.query?.contains("page=2") == true)
    #expect(CatalogAPIHeaders.authenticated(apiToken: "test-token") == ["api-token": "test-token"])
}

@Test func multipartFileUsesBackendFieldAndBoundary() {
    let body = MultipartFormData.make(fields: ["document_id": "4"], files: [
        MultipartFile(fieldName: "value", filename: "document.pdf", mimeType: "application/pdf", data: Data("fixture".utf8))
    ], boundary: "test-boundary")
    let string = String(decoding: body.data, as: UTF8.self)
    #expect(body.contentType == "multipart/form-data; boundary=test-boundary")
    #expect(string.contains("name=\"document_id\""))
    #expect(string.contains("name=\"value\"; filename=\"document.pdf\""))
    #expect(string.contains("Content-Type: application/pdf"))
}

@Test func submissionValidationErrorIsPreservedByAPIError() {
    let error = APIError.httpError(statusCode: 405, body: #"{"error":{"submitted_at":["The submitted at field is required."]}}"#)
    #expect(error.errorDescription?.contains("405") == true)
    #expect(error.errorDescription?.contains("submitted_at") == true)
}
