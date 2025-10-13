import Foundation

// MARK: - Collections API

extension Client {
    /// Lists collections from the Hub.
    ///
    /// - Parameters:
    ///   - owner: Filter collections by owner (username or organization).
    ///   - search: Search term to filter collections.
    ///   - sort: Property to use when sorting (e.g., "trending", "updated").
    ///   - limit: Limit the number of collections fetched.
    /// - Returns: A paginated response containing collection information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func listCollections(
        owner: String? = nil,
        search: String? = nil,
        sort: String? = nil,
        limit: Int? = nil
    ) async throws -> PaginatedResponse<Collection> {
        var params: [String: Value] = [:]

        if let owner { params["owner"] = .string(owner) }
        if let search { params["search"] = .string(search) }
        if let sort { params["sort"] = .string(sort) }
        if let limit { params["limit"] = .int(limit) }

        return try await fetchPaginated(.get, "/api/collections", params: params)
    }

    /// Gets information for a specific collection.
    ///
    /// - Parameter slug: The collection slug (e.g., "owner/collection-name").
    /// - Returns: Information about the collection.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getCollection(_ slug: String) async throws -> Collection {
        return try await fetch(.get, "/api/collections/\(slug)")
    }

    // MARK: - Collection Items Management

    /// Adds an item to a collection.
    ///
    /// - Parameters:
    ///   - namespace: The namespace of the collection.
    ///   - slug: The slug of the collection.
    ///   - id: The ID of the collection.
    ///   - item: The item to add to the collection.
    ///   - note: Optional note about the item (max 500 characters).
    /// - Returns: The updated collection.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func addCollectionItem(
        namespace: String,
        slug: String,
        id: String,
        item: Collection.Item,
        note: String? = nil
    ) async throws -> Collection {
        let apiPath = "/api/collections/\(namespace)/\(slug)-\(id)/items"

        let params: [String: Value] = [
            "item": [
                "type": .string(item.type ?? ""),
                "id": .string(item.id ?? ""),
            ],
            "note": note.map { .string($0) } ?? .null,
        ]

        return try await fetch(.post, apiPath, params: params)
    }

    /// Batch updates items in a collection.
    ///
    /// - Parameters:
    ///   - namespace: The namespace of the collection.
    ///   - slug: The slug of the collection.
    ///   - id: The ID of the collection.
    ///   - actions: Array of batch update actions.
    /// - Returns: `true` if the batch update was successful.
    /// - Throws: An error if the request fails.
    public func batchUpdateCollectionItems(
        namespace: String,
        slug: String,
        id: String,
        actions: [Collection.BatchAction]
    ) async throws -> Bool {
        let apiPath = "/api/collections/\(namespace)/\(slug)-\(id)/items/batch"

        let encoder = JSONEncoder()
        let actionsData = try actions.map { try encoder.encode($0) }
        let params: [Value] = try actionsData.map { data in
            // Decode the encoded data into `Value` type
            let value = try JSONDecoder().decode(Value.self, from: data)
            return value
        }

        _ = try await fetchData(.post, apiPath, params: ["": .array(params)])
        return true
    }

    /// Deletes an item from a collection.
    ///
    /// - Parameters:
    ///   - namespace: The namespace of the collection.
    ///   - slug: The slug of the collection.
    ///   - id: The ID of the collection.
    ///   - itemId: The ID of the item to delete.
    /// - Returns: `true` if the item was deleted successfully.
    /// - Throws: An error if the request fails.
    public func deleteCollectionItem(
        namespace: String,
        slug: String,
        id: String,
        itemId: String
    ) async throws -> Bool {
        let apiPath = "/api/collections/\(namespace)/\(slug)-\(id)/items/\(itemId)"
        let result: Bool = try await fetch(.delete, apiPath)
        return result
    }
}
