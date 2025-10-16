import Foundation
import Testing

@testable import Hub

@Suite("Organizations API Tests")
struct OrganizationsTests {
    @Test("OrganizationInfo can be decoded from JSON")
    func testOrganizationInfoDecoding() throws {
        let json = """
            {
                "name": "huggingface",
                "fullname": "Hugging Face",
                "avatarUrl": "https://avatars.example.com/huggingface",
                "isEnterprise": true,
                "createdAt": "2016-01-01T00:00:00Z",
                "numMembers": 100,
                "numModels": 5000,
                "numDatasets": 1000,
                "numSpaces": 500,
                "description": "The AI community building the future",
                "website": "https://huggingface.co"
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        let data = json.data(using: .utf8)!
        let org = try decoder.decode(Organization.self, from: data)

        #expect(org.name == "huggingface")
        #expect(org.fullName == "Hugging Face")
        #expect(org.isEnterprise == true)
        #expect(org.numberOfMembers == 100)
        #expect(org.website == "https://huggingface.co")
    }

    @Test("Organization.Member can be decoded from JSON")
    func testOrganizationMemberDecoding() throws {
        let json = """
            {
                "name": "johndoe",
                "fullname": "John Doe",
                "avatarUrl": "https://avatars.example.com/johndoe",
                "role": "admin"
            }
            """

        let data = json.data(using: .utf8)!
        let member = try JSONDecoder().decode(Organization.Member.self, from: data)

        #expect(member.name == "johndoe")
        #expect(member.fullName == "John Doe")
        #expect(member.role == "admin")
    }
}
