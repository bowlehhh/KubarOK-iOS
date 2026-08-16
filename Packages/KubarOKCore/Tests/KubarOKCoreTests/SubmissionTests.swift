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
