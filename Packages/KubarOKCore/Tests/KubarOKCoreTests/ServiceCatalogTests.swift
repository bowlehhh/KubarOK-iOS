import Foundation
import Testing
@testable import KubarOKCore

@Test func bureauListDecodesPaginatedBackendResponse() throws {
    let response = try JSONDecoder().decode(
        PaginatedResponse<Bureau>.self,
        from: fixtureData(
            #"""
            {
              "data": [{
                "id": 7,
                "name": "Dinas Kependudukan",
                "short_name": "Disdukcapil",
                "address": "Sendawar",
                "phone": null,
                "email": "disdukcapil@example.test",
                "background_image": "/storage/bureau.jpg",
                "thumb_image": "/storage/emblem.jpg",
                "services_count": 3,
                "created_at": "2026-08-16 10:00:00",
                "updated_at": "2026-08-16 10:00:00"
              }],
              "links": { "first": "https://example.test/v1/bureau?page=1", "last": "https://example.test/v1/bureau?page=1", "prev": null, "next": null },
              "meta": { "current_page": 1, "from": 1, "last_page": 1, "path": "https://example.test/v1/bureau", "per_page": 10, "to": 1, "total": 1 }
            }
            """#
        )
    )

    #expect(response.data.count == 1)
    #expect(response.data[0].shortName == "Disdukcapil")
    #expect(response.data[0].servicesCount == 3)
    #expect(response.meta.perPage == 10)
}

@Test func governmentServiceListDecodesBureauFilterResponse() throws {
    let response = try JSONDecoder().decode(
        PaginatedResponse<GovernmentService>.self,
        from: fixtureData(
            #"""
            {
              "data": [{
                "id": 11,
                "name": "Penerbitan KTP-el",
                "description": "Perekaman dan penerbitan KTP-el",
                "is_enable": 1,
                "sort_order": 1,
                "bureau_id": 7,
                "external_link": null,
                "is_external": 0,
                "bureau": { "id": 7, "name": "Dinas Kependudukan", "short_name": "Disdukcapil", "address": null, "phone": null, "email": null, "background_image": null, "thumb_image": null, "created_at": null, "updated_at": null },
                "procedures_count": 2,
                "requisites_count": 3,
                "created_at": "2026-08-16 10:00:00",
                "updated_at": "2026-08-16 10:00:00"
              }],
              "links": { "first": "https://example.test/v1/service?bureau_id=7&page=1", "last": "https://example.test/v1/service?bureau_id=7&page=1", "prev": null, "next": null },
              "meta": { "current_page": 1, "from": 1, "last_page": 1, "path": "https://example.test/v1/service", "per_page": 10, "to": 1, "total": 1 }
            }
            """#
        )
    )

    #expect(response.data[0].isEnabled == 1)
    #expect(response.data[0].bureau?.name == "Dinas Kependudukan")
    #expect(response.data[0].requisitesCount == 3)
}

@Test func serviceDetailDecodesProceduresAndRequisites() throws {
    let response = try JSONDecoder().decode(
        APIDataResponse<GovernmentService>.self,
        from: fixtureData(
            #"""
            {
              "data": {
                "id": 11,
                "name": "Penerbitan KTP-el",
                "description": "Perekaman dan penerbitan KTP-el",
                "is_enable": 1,
                "sort_order": 1,
                "bureau_id": 7,
                "external_link": null,
                "is_external": 0,
                "bureau": { "id": 7, "name": "Dinas Kependudukan", "short_name": null, "address": null, "phone": null, "email": null, "background_image": null, "thumb_image": null, "created_at": null, "updated_at": null },
                "procedures": [{ "id": 1, "name": "Verifikasi data", "description": null, "sequence": 1, "service_id": 11 }],
                "requisites": [{
                  "id": 2,
                  "service_id": 11,
                  "doc_type_id": null,
                  "title": "Isi formulir",
                  "description": "Lengkapi data permohonan",
                  "is_required": 1,
                  "kind": 2,
                  "sequence": 1,
                  "external_link": null,
                  "documents": [{ "id": 3, "requisite_id": 2, "doc_type_id": 4, "comment": "Dokumen pendukung" }],
                  "inputs": [{ "id": 5, "label": "Nama", "key": "name", "type": "text", "comment": null }]
                }],
                "created_at": "2026-08-16 10:00:00",
                "updated_at": "2026-08-16 10:00:00"
              }
            }
            """#
        )
    )

    #expect(response.data.procedures?.first?.name == "Verifikasi data")
    #expect(response.data.requisites?.first?.kind == 2)
    #expect(response.data.requisites?.first?.documents?.first?.documentTypeId == 4)
    #expect(response.data.requisites?.first?.inputs?.first?.key == "name")
}

@Test func catalogPathsAndPaginationQueriesUseVerifiedRoutes() {
    #expect(
        APIClient.shared.url(for: "bureau", queryItems: [
            URLQueryItem(name: "page", value: "2")
        ]).absoluteString == "https://kubarok.kutaibaratkab.go.id/v1/bureau?page=2"
    )
    #expect(
        APIClient.shared.url(for: "service", queryItems: [
            URLQueryItem(name: "bureau_id", value: "7"),
            URLQueryItem(name: "page", value: "2")
        ]).absoluteString == "https://kubarok.kutaibaratkab.go.id/v1/service?bureau_id=7&page=2"
    )
    #expect(
        APIClient.shared.url(for: "service/11").absoluteString
            == "https://kubarok.kutaibaratkab.go.id/v1/service/11"
    )
}

@Test func catalogEndpointsUseTheAPITokenHeader() {
    #expect(CatalogAPIHeaders.authenticated(apiToken: "test-token") == ["api-token": "test-token"])
}

@Test func catalogHTTPErrorKeepsTheBackendErrorResponse() {
    let error = APIError.httpError(
        statusCode: 404,
        body: #"{"error":"No query results for model"}"#
    )

    #expect(error.errorDescription?.contains("404") == true)
    #expect(error.errorDescription?.contains("No query results") == true)
}

private func fixtureData(_ fixture: String) -> Data {
    Data(fixture.utf8)
}
