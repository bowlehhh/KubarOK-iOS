import Foundation
import Testing
@testable import KubarOKCore

@Test func citizenProfileRequestUsesBackendCodingKeys() throws {
    let request = CitizenProfileRequest(
        applicableId: "PASSPORT-123",
        name: "Test Citizen",
        kkNumber: "6400000000000001",
        birthPlace: "Sendawar",
        birthDate: "1990-01-01",
        sex: "M",
        citizenship: "WNA"
    )
    let data = try JSONEncoder().encode(request)
    let payload = try #require(
        JSONSerialization.jsonObject(with: data) as? [String: Any]
    )

    #expect(payload["applicable_id"] as? String == "PASSPORT-123")
    #expect(payload["kk_number"] as? String == "6400000000000001")
    #expect(payload["birth_place"] as? String == "Sendawar")
    #expect(payload["birth_date"] as? String == "1990-01-01")
    #expect(payload["applicableId"] == nil)
    #expect(payload["kkNumber"] == nil)
    #expect(payload["birthPlace"] == nil)
    #expect(payload["birthDate"] == nil)
}

@Test func citizenDecodesBackendSnakeCaseKeys() throws {
    let data = Data(
        #"""
        {
          "id": 1,
          "applicable_id": "PASSPORT-123",
          "full_name": "Test Citizen",
          "birth_place": "Sendawar",
          "birth_date": "1990-01-01",
          "sex": "M",
          "citizenship": "WNA",
          "kk_number": null,
          "created_at": "2026-08-16 10:00:00",
          "updated_at": "2026-08-16 10:00:00"
        }
        """#.utf8
    )

    let citizen = try JSONDecoder().decode(Citizen.self, from: data)

    #expect(citizen.applicableId == "PASSPORT-123")
    #expect(citizen.fullName == "Test Citizen")
    #expect(citizen.birthPlace == "Sendawar")
    #expect(citizen.birthDate == "1990-01-01")
    #expect(citizen.kkNumber == nil)
}

@Test func userProfileDecodesWithoutCitizen() throws {
    let data = Data(
        #"""
        {
          "data": {
            "id": 1507,
            "name": "KubarOK iOS Test",
            "email": "user@example.com",
            "is_activated": true,
            "activated_at": "2026-08-16 10:00:00",
            "username": "kubaroktest",
            "phone": "08123456789",
            "citizen": null,
            "created_at": "2026-08-16 10:00:00",
            "updated_at": "2026-08-16 10:00:00"
          }
        }
        """#.utf8
    )

    let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)

    #expect(response.data.id == 1507)
    #expect(response.data.citizen == nil)
}

@Test func userProfileDecodesNestedCitizen() throws {
    let data = Data(
        #"""
        {
          "data": {
            "id": 1507,
            "name": "KubarOK iOS Test",
            "email": "user@example.com",
            "is_activated": true,
            "activated_at": null,
            "username": null,
            "phone": null,
            "citizen": {
              "id": 1,
              "applicable_id": "PASSPORT-123",
              "full_name": "Test Citizen",
              "birth_place": "Sendawar",
              "birth_date": "1990-01-01",
              "sex": "M",
              "citizenship": "WNA",
              "kk_number": null,
              "created_at": null,
              "updated_at": null
            },
            "created_at": "2026-08-16 10:00:00",
            "updated_at": "2026-08-16 10:00:00"
          }
        }
        """#.utf8
    )

    let response = try JSONDecoder().decode(UserProfileResponse.self, from: data)

    #expect(response.data.citizen?.id == 1)
    #expect(response.data.citizen?.fullName == "Test Citizen")
}

@Test func apiClientBuildsUserAndProfilePaths() {
    #expect(
        APIClient.shared.url(for: "user").absoluteString
            == "https://kubarok.kutaibaratkab.go.id/v1/user"
    )
    #expect(
        APIClient.shared.url(for: "profile").absoluteString
            == "https://kubarok.kutaibaratkab.go.id/v1/profile"
    )
}
