import Foundation
import Testing

@testable import Hub

@Suite("Collections API Tests")
struct CollectionsTests {
    @Test("CollectionInfo can be decoded from JSON")
    func testCollectionInfoDecoding() throws {
        let json = """
            {
                "id": "123",
                "slug": "user/collection",
                "title": "My Collection",
                "description": "A test collection",
                "owner": "user",
                "position": 1,
                "private": false,
                "theme": "default",
                "upvotes": 10,
                "items": []
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds
        let data = json.data(using: .utf8)!
        let collection = try decoder.decode(Collection.self, from: data)

        #expect(collection.id == "123")
        #expect(collection.slug == "user/collection")
        #expect(collection.title == "My Collection")
        #expect(collection.description == "A test collection")
        #expect(collection.owner == "user")
    }

    @Test("CollectionItem can be decoded from JSON")
    func testCollectionItemDecoding() throws {
        let json = """
            {
                "item_type": "model",
                "item_id": "facebook/bart-large",
                "position": 0,
                "note": "A great model"
            }
            """

        let data = json.data(using: .utf8)!
        let item = try JSONDecoder().decode(Collection.Item.self, from: data)

        #expect(item.itemType == "model")
        #expect(item.itemId == "facebook/bart-large")
        #expect(item.position == 0)
        #expect(item.note == "A great model")
    }
}
