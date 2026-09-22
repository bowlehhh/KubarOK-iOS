import Foundation
import Testing
@testable import KubarOKCore

@Test func accountAndOTPRequestsUseBackendKeys() throws {
    let update = try JSONSerialization.jsonObject(
        with: JSONEncoder().encode(
            UpdateUserRequest(
                name: "Test User",
                email: "user@example.test",
                phone: "081234567890",
                password: nil
            )
        )
    ) as? [String: Any]
    #expect(update?["name"] as? String == "Test User")
    #expect(update?["email"] as? String == "user@example.test")
    #expect(update?["phone"] as? String == "081234567890")
    #expect(update?["password"] == nil)

    let expiration = try JSONDecoder().decode(
        APIDataResponse<OTPExpiration>.self,
        from: Data(#"{"data":{"otp_expired_at":"2026-09-22 21:00:00"}}"#.utf8)
    )
    #expect(expiration.data.expiresAt == "2026-09-22 21:00:00")
}

@Test func webParityPathsMatchBackendRoutes() {
    let paths = [
        "auth/otp/request",
        "auth/forgot-password/check-otp",
        "auth/forgot-password/reset-password",
        "user/verify-phone",
        "bureau/search",
        "service/search",
        "information/latest-info",
        "information/last-announcement",
        "notification",
        "notification/total-unread",
        "notification/mark-all-read",
        "notification/delete-all",
        "submission/123/delete",
        "submission/7/delete-file",
        "submission/8/delete-data",
    ]

    for path in paths {
        #expect(
            APIClient.shared.url(for: path).absoluteString
                == "https://kubarok.kutaibaratkab.go.id/v1/\(path)"
        )
    }
}

@Test func informationResponseDecodesProductionShape() throws {
    let data = Data(
        #"{"data":[{"id":3,"title":"Informasi layanan","description":"<p>Isi informasi</p>","is_announcement":1,"bureau_id":2,"created_at":"2026-09-22 10:00:00","updated_at":"2026-09-22 11:00:00","file":{"id":5,"file_name":"info.png","file_size":1200,"content_type":"image/png","title":null,"description":null,"path":"https://example.test/info.png","extension":"png"},"content_file":null,"bureau":{"id":2,"name":"Dinas Contoh"}}],"links":{"first":null,"last":null,"prev":null,"next":null},"meta":{"current_page":1,"from":1,"last_page":1,"path":"https://example.test/v1/information/latest-info","per_page":10,"to":1,"total":1}}"#.utf8
    )

    let response = try JSONDecoder().decode(PaginatedResponse<InformationItem>.self, from: data)
    #expect(response.data.first?.isAnnouncement == 1)
    #expect(response.data.first?.file?.path == "https://example.test/info.png")
    #expect(response.data.first?.bureau?.id == 2)

    let announcement = try JSONDecoder().decode(
        APIDataResponse<AnnouncementFile>.self,
        from: Data(#"{"data":{"id":5,"path":"https://example.test/announcement.pdf"}}"#.utf8)
    )
    #expect(announcement.data.id == 5)
    #expect(announcement.data.path == "https://example.test/announcement.pdf")
}

@Test func notificationResponseDecodesBackendIntegerReadState() throws {
    let data = Data(
        #"{"data":[{"id":3,"title":"Perubahan status","description":"Pengajuan sedang diproses.","submission_id":"0012609220001","is_read":0,"user_id":2,"created_at":"2026-09-22 10:00:00","updated_at":"2026-09-22 10:00:00"}],"links":{"first":null,"last":null,"prev":null,"next":null},"meta":{"current_page":1,"from":1,"last_page":1,"path":"https://example.test/v1/notification","per_page":25,"to":1,"total":1}}"#.utf8
    )

    let response = try JSONDecoder().decode(PaginatedResponse<UserNotification>.self, from: data)
    #expect(response.data.first?.isRead == 0)
    #expect(response.data.first?.submissionId == "0012609220001")
}

@Test func submissionDetailDecodesEditableDraftDataAndProducts() throws {
    let data = Data(
        #"{"data":{"id":"0012609220001","state":0,"service_id":8,"submitter_id":9,"applicant_id":10,"requisite_check":[],"validation":[],"products":[{"id":1,"ref":"DOC-1","file":{"id":3,"path":"https://example.test/result.pdf"}}],"submission_files":[{"id":7,"submission_id":12609220001,"document_id":4,"file_id":3,"file":{"id":3,"file_name":"document.pdf","path":"https://example.test/document.pdf"}}],"submission_data":[{"id":11,"value":"Nilai","submission_id":12609220001,"input_id":5,"input":{"id":5,"label":"Keterangan","key":"description","type":"text","comment":null}}]}}"#.utf8
    )

    let detail = try JSONDecoder().decode(APIDataResponse<SubmissionDetail>.self, from: data).data
    #expect(detail.products.first?.reference == "DOC-1")
    #expect(detail.submissionFiles.first?.documentId == 4)
    #expect(detail.submissionData.first?.input?.key == "description")
}
