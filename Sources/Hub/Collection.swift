import Foundation

/// Information about a collection on the Hub.
public struct Collection: Sendable {
    /// The collection's unique identifier.
    public let id: String?

    /// The collection's slug (URL-friendly identifier).
    public let slug: String?

    /// The collection's title.
    public let title: String

    /// The collection's description.
    public let description: String?

    /// The owner of the collection.
    public let owner: String?

    /// The position/order of the collection.
    public let position: Int?

    /// The visibility of the collection.
    public let visibility: Repo.Visibility?

    /// The theme of the collection.
    public let theme: String?

    /// The date the collection was created.
    public let createdAt: Date?

    /// The date the collection was last updated.
    public let updatedAt: Date?

    /// The number of upvotes.
    public let upvotes: Int?

    /// An item related to collections.
    public struct Item: Identifiable, Codable, Sendable {
        /// The type of item when used as an input payload (paper, collection, space, model, dataset).
        public let type: String?

        /// The identifier when used as an input payload.
        public let id: String?

        /// The type of item when decoded from collection entries.
        public let itemType: String?

        /// The identifier when decoded from collection entries.
        public let itemID: String?

        /// The item's position in the collection (only present on decoded entries or when updating).
        public let position: Int?

        /// A note about the item (only present on decoded entries or when updating).
        public let note: String?

        /// Convenience initializer for constructing an input payload item.
        public init(type: String, id: String) {
            self.type = type
            self.id = id
            self.itemType = nil
            self.itemID = nil
            self.position = nil
            self.note = nil
        }

        private enum CodingKeys: String, CodingKey {
            case type
            case id
            case itemType = "item_type"
            case itemID = "item_id"
            case position
            case note
        }
    }

    /// The items in the collection.
    public let items: [Item]?
}

// MARK: -

extension Collection {
    /// Represents a batch update action for collection items.
    public enum BatchAction: Sendable {
        /// Batch update action for a collection item.
        case update(id: String, data: UpdateData)

        /// Data for updating a collection item.
        public struct UpdateData: Codable, Sendable {
            /// Gallery URLs for the item.
            public let gallery: [String]?

            /// Note about the item (max 500 characters).
            public let note: String?

            /// Position of the item in the collection.
            public let position: Int?

            public init(gallery: [String]? = nil, note: String? = nil, position: Int? = nil) {
                self.gallery = gallery
                self.note = note
                self.position = position
            }
        }

    }

}

extension Collection: Codable {
    private enum CodingKeys: String, CodingKey {
        case id
        case slug
        case title
        case description
        case owner
        case position
        case visibility = "private"
        case theme
        case createdAt
        case updatedAt
        case upvotes
        case items
    }
}

extension Collection.BatchAction: Codable {
    private enum CodingKeys: String, CodingKey {
        case action
        case id = "_id"
        case data
    }

    private enum ActionType: String, Codable {
        case update
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .update(id, data):
            try container.encode(ActionType.update, forKey: .action)
            try container.encode(id, forKey: .id)
            try container.encode(data, forKey: .data)
        }
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let actionType = try container.decode(ActionType.self, forKey: .action)
        switch actionType {
        case .update:
            let id = try container.decode(String.self, forKey: .id)
            let data = try container.decode(UpdateData.self, forKey: .data)
            self = .update(id: id, data: data)
        }
    }
}
