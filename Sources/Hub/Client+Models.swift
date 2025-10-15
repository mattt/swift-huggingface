import Foundation

// MARK: - Models API

extension Client {
    /// Lists models from the Hub.
    ///
    /// - Parameters:
    ///   - search: Filter based on substrings for repos and their usernames.
    ///   - author: Filter models by an author or organization.
    ///   - filter: Filter based on tags (e.g., "text-classification").
    ///   - sort: Property to use when sorting (e.g., "downloads", "author").
    ///   - direction: Direction in which to sort.
    ///   - limit: Limit the number of models fetched.
    ///   - full: Whether to fetch most model data, such as all tags, the files, etc.
    ///   - config: Whether to also fetch the repo config.
    /// - Returns: A paginated response containing model information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func listModels(
        search: String? = nil,
        author: String? = nil,
        filter: String? = nil,
        sort: String? = nil,
        direction: SortDirection? = nil,
        limit: Int? = nil,
        full: Bool? = nil,
        config: Bool? = nil
    ) async throws -> PaginatedResponse<Model> {
        var params: [String: Value] = [:]

        if let search { params["search"] = .string(search) }
        if let author { params["author"] = .string(author) }
        if let filter { params["filter"] = .string(filter) }
        if let sort { params["sort"] = .string(sort) }
        if let direction { params["direction"] = .int(direction.rawValue) }
        if let limit { params["limit"] = .int(limit) }
        if let full { params["full"] = .bool(full) }
        if let config { params["config"] = .bool(config) }

        return try await fetchPaginated(.get, "/api/models", params: params)
    }

    /// Gets information for a specific model.
    ///
    /// - Parameters:
    ///   - id: The repository identifier (e.g., "facebook/bart-large-cnn").
    ///   - revision: The git revision (branch, tag, or commit hash). If nil, uses the repo's default branch (usually "main").
    ///   - full: Whether to fetch most model data.
    /// - Returns: Information about the model.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getModel(
        _ id: Repo.ID,
        revision: String? = nil,
        full: Bool? = nil
    ) async throws -> Model {
        let path: String
        if let revision {
            path = "/api/models/\(id.namespace)/\(id.name)/revision/\(revision)"
        } else {
            path = "/api/models/\(id.namespace)/\(id.name)"
        }

        var params: [String: Value] = [:]
        if let full { params["full"] = .bool(full) }

        return try await fetch(.get, path, params: params)
    }

    /// Gets all available model tags hosted in the Hub.
    ///
    /// - Returns: Tag information organized by type.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getModelTags() async throws -> Tags {
        return try await fetch(.get, "/api/models-tags-by-type")
    }

    // MARK: - Model Access Requests

    /// Requests access to a gated model repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - fields: Additional form fields to include with the access request (e.g., "reason", "institution").
    /// - Returns: `true` if the request was submitted successfully.
    /// - Throws: An error if the request fails.
    public func requestModelAccess(
        _ id: Repo.ID,
        fields: [String: String]? = nil
    ) async throws -> Bool {
        let path = "/\(id.namespace)/\(id.name)/ask-access"
        let params: [String: Value] = fields?.mapValues { .string($0) } ?? [:]
        let result: Bool = try await fetch(.post, path, params: params)
        return result
    }

    /// Cancels the current user's access request to a gated model repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if the request was cancelled successfully.
    /// - Throws: An error if the request fails.
    public func cancelModelAccessRequest(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/models/\(id.namespace)/\(id.name)/user-access-request/cancel"
        let result: Bool = try await fetch(.post, path)
        return result
    }

    /// Grants access to a user for a gated model repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if access was granted successfully.
    /// - Throws: An error if the request fails.
    public func grantModelAccess(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/models/\(id.namespace)/\(id.name)/user-access-request/grant"
        let result: Bool = try await fetch(.post, path)
        return result
    }

    /// Handles an access request for a gated model repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if the request was handled successfully.
    /// - Throws: An error if the request fails.
    public func handleModelAccessRequest(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/models/\(id.namespace)/\(id.name)/user-access-request/handle"
        let result: Bool = try await fetch(.post, path)
        return result
    }

    /// Lists access requests for a gated model repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - status: The status to filter by ("pending", "accepted", "rejected").
    /// - Returns: A list of access requests.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func listModelAccessRequests(
        _ id: Repo.ID,
        status: AccessRequest.Status
    ) async throws -> [AccessRequest] {
        let path = "/api/models/\(id.namespace)/\(id.name)/user-access-request/\(status.rawValue)"
        return try await fetch(.get, path)
    }

    /// Gets user access report for a model repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: User access report data.
    /// - Throws: An error if the request fails.
    public func getModelUserAccessReport(_ id: Repo.ID) async throws -> Data {
        let path = "/\(id.namespace)/\(id.name)/user-access-report"
        return try await fetchData(.get, path)
    }

    // MARK: - Model Advanced Features

    /// Sets the resource group for a model repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - resourceGroupId: The resource group ID to set, or nil to unset.
    /// - Returns: Resource group response information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func setModelResourceGroup(
        _ id: Repo.ID,
        resourceGroupId: String?
    ) async throws -> ResourceGroup {
        let path = "/api/models/\(id.namespace)/\(id.name)/resource-group"

        let params: [String: Value] = [
            "resourceGroupId": resourceGroupId.map { .string($0) } ?? .null
        ]

        return try await fetch(.post, path, params: params)
    }

    /// Scans a model repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if the scan was initiated successfully.
    /// - Throws: An error if the request fails.
    public func scanModel(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/models/\(id.namespace)/\(id.name)/scan"
        let result: Bool = try await fetch(.post, path)
        return result
    }

    /// Creates a new tag for a model repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - revision: The git revision to tag.
    ///   - tag: The name of the tag to create.
    ///   - message: An optional message for the tag.
    /// - Returns: `true` if the tag was created successfully.
    /// - Throws: An error if the request fails.
    public func createModelTag(
        _ id: Repo.ID,
        revision: String,
        tag: String,
        message: String? = nil
    ) async throws -> Bool {
        let path = "/api/models/\(id.namespace)/\(id.name)/tag/\(revision)"

        let params: [String: Value] = [
            "tag": .string(tag),
            "message": message.map { .string($0) } ?? .null,
        ]

        let result: Bool = try await fetch(.post, path, params: params)
        return result
    }

    /// Super-squashes commits in a model repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - revision: The git revision to squash.
    ///   - message: The commit message for the squashed commit.
    /// - Returns: The new commit ID.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func superSquashModel(
        _ id: Repo.ID,
        revision: String,
        message: String
    ) async throws -> String {
        let path = "/api/models/\(id.namespace)/\(id.name)/super-squash/\(revision)"

        let params: [String: Value] = [
            "message": .string(message)
        ]

        struct Response: Decodable { let commitID: String }
        let resp: Response = try await fetch(.post, path, params: params)
        return resp.commitID
    }
}
