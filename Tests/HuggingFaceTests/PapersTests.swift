import Foundation
import Testing

@testable import Hub

@Suite("Papers API Tests")
struct PapersTests {
    @Test("PaperInfo can be decoded from JSON")
    func testPaperInfoDecoding() throws {
        let json = """
            {
                "id": "2103.00020",
                "title": "An Image is Worth 16x16 Words",
                "authors": ["Alexey Dosovitskiy", "Lucas Beyer"],
                "summary": "A paper about vision transformers",
                "published": "2021-03-01T00:00:00Z",
                "updated": "2021-03-15T00:00:00Z",
                "url": "https://arxiv.org/abs/2103.00020",
                "arxiv_id": "2103.00020",
                "upvotes": 150,
                "featured": true,
                "models": ["google/vit-base"],
                "datasets": ["imagenet"],
                "spaces": []
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        let data = json.data(using: .utf8)!
        let paper = try decoder.decode(Paper.self, from: data)

        #expect(paper.id == "2103.00020")
        #expect(paper.title == "An Image is Worth 16x16 Words")
        #expect(paper.authors?.count == 2)
        #expect(paper.summary == "A paper about vision transformers")
        #expect(paper.arXivID == "2103.00020")
    }
}
