import Foundation

// MARK: - Spaces API

extension Client {
    /// Lists Spaces from the Hub.
    ///
    /// - Parameters:
    ///   - search: Filter based on substrings for repos and their usernames.
    ///   - author: Filter spaces by an author or organization.
    ///   - filter: Filter based on tags.
    ///   - sort: Property to use when sorting (e.g., "likes", "author").
    ///   - direction: Direction in which to sort.
    ///   - limit: Limit the number of spaces fetched.
    ///   - full: Whether to fetch most space data, such as all tags, the files, etc.
    /// - Returns: A paginated response containing space information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func listSpaces(
        search: String? = nil,
        author: String? = nil,
        filter: String? = nil,
        sort: String? = nil,
        direction: SortDirection? = nil,
        limit: Int? = nil,
        full: Bool? = nil
    ) async throws -> PaginatedResponse<Space> {
        var params: [String: Value] = [:]

        if let search { params["search"] = .string(search) }
        if let author { params["author"] = .string(author) }
        if let filter { params["filter"] = .string(filter) }
        if let sort { params["sort"] = .string(sort) }
        if let direction { params["direction"] = .int(direction.rawValue) }
        if let limit { params["limit"] = .int(limit) }
        if let full { params["full"] = .bool(full) }

        return try await fetchPaginated(.get, "/api/spaces", params: params)
    }

    /// Gets information for a specific Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier (e.g., "user/space-name").
    ///   - revision: The git revision (branch, tag, or commit hash). If nil, uses the repo's default branch (usually "main").
    ///   - full: Whether to fetch most space data.
    /// - Returns: Information about the space.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getSpace(
        _ id: Repo.ID,
        revision: String? = nil,
        full: Bool? = nil
    ) async throws -> Space {
        let path: String
        if let revision {
            path = "/api/spaces/\(id.namespace)/\(id.name)/revision/\(revision)"
        } else {
            path = "/api/spaces/\(id.namespace)/\(id.name)"
        }

        var params: [String: Value] = [:]
        if let full { params["full"] = .bool(full) }

        return try await fetch(.get, path, params: params)
    }

    /// Gets runtime information for a Space.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: Runtime information for the space.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func spaceRuntime(_ id: Repo.ID) async throws -> Space.Runtime {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/runtime"
        return try await fetch(.get, path)
    }

    /// Puts a Space to sleep.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if the operation was successful.
    /// - Throws: An error if the request fails.
    public func sleepSpace(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/sleeptime"
        return try await fetch(.post, path)
    }

    /// Restarts a Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - factory: Whether to perform a factory restart (rebuild from scratch).
    /// - Returns: `true` if the operation was successful.
    /// - Throws: An error if the request fails.
    public func restartSpace(_ id: Repo.ID, factory: Bool = false) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/restart"
        var params: [String: Value] = [:]
        if factory {
            params["factory"] = .bool(true)
        }
        return try await fetch(.post, path, params: params)
    }

    // MARK: - Space Streaming

    /// Streams logs for a Space using Server-Sent Events.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - logType: The type of logs to stream ("build" or "run").
    /// - Returns: An async stream of log entries.
    public func streamSpaceLogs(
        _ id: Repo.ID,
        logType: String
    ) -> AsyncThrowingStream<Space.LogEntry, Error> {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/logs/\(logType)"
        return fetchStream(.get, path)
    }

    /// Streams live metrics for a Space using Server-Sent Events.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: An async stream of metrics.
    public func streamSpaceMetrics(_ id: Repo.ID) -> AsyncThrowingStream<Space.Metrics, Error> {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/metrics"
        return fetchStream(.get, path)
    }

    /// Streams events for a Space using Server-Sent Events.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - sessionUUID: Optional session UUID to filter events.
    /// - Returns: An async stream of events.
    public func streamSpaceEvents(
        _ id: Repo.ID,
        sessionUUID: String? = nil
    ) -> AsyncThrowingStream<Space.Event, Error> {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/events"
        var params: [String: Value] = [:]
        if let sessionUUID {
            params["session_uuid"] = .string(sessionUUID)
        }
        return fetchStream(.get, path, params: params)
    }

    // MARK: - Space Secrets Management

    /// Creates or updates a secret for a Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - key: The secret key name.
    ///   - description: An optional description for the secret.
    ///   - value: The secret value.
    /// - Returns: `true` if the secret was created/updated successfully.
    /// - Throws: An error if the request fails.
    public func upsertSpaceSecret(
        _ id: Repo.ID,
        key: String,
        description: String? = nil,
        value: String? = nil
    ) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/secrets"

        let params: [String: Value] = [
            "key": .string(key),
            "description": description.map { .string($0) } ?? .null,
            "value": value.map { .string($0) } ?? .string(""),
        ]

        let result: Bool = try await fetch(.post, path, params: params)
        return result
    }

    /// Deletes a secret from a Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - key: The secret key name to delete.
    /// - Returns: `true` if the secret was deleted successfully.
    /// - Throws: An error if the request fails.
    public func deleteSpaceSecret(
        _ id: Repo.ID,
        key: String
    ) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/secrets"

        let params: [String: Value] = [
            "key": .string(key)
        ]

        let result: Bool = try await fetch(.delete, path, params: params)
        return result
    }

    // MARK: - Space Variables Management

    /// Creates or updates a variable for a Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - key: The variable key name.
    ///   - description: An optional description for the variable.
    ///   - value: The variable value.
    /// - Returns: `true` if the variable was created/updated successfully.
    /// - Throws: An error if the request fails.
    public func upsertSpaceVariable(
        _ id: Repo.ID,
        key: String,
        description: String? = nil,
        value: String? = nil
    ) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/variables"

        let params: [String: Value] = [
            "key": .string(key),
            "description": description.map { .string($0) } ?? .null,
            "value": value.map { .string($0) } ?? .string(""),
        ]

        let result: Bool = try await fetch(.post, path, params: params)
        return result
    }

    /// Deletes a variable from a Space.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - key: The variable key name to delete.
    /// - Returns: `true` if the variable was deleted successfully.
    /// - Throws: An error if the request fails.
    public func deleteSpaceVariable(
        _ id: Repo.ID,
        key: String
    ) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/variables"

        let params: [String: Value] = [
            "key": .string(key)
        ]

        let result: Bool = try await fetch(.delete, path, params: params)
        return result
    }

    // MARK: - Space Advanced Features

    /// Sets the resource group for a space repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - resourceGroupId: The resource group ID to set, or nil to unset.
    /// - Returns: Resource group response information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func setSpaceResourceGroup(
        _ id: Repo.ID,
        resourceGroupId: String?
    ) async throws -> ResourceGroup {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/resource-group"

        let params: [String: Value] = [
            "resourceGroupId": resourceGroupId.map { .string($0) } ?? .null
        ]

        return try await fetch(.post, path, params: params)
    }

    /// Scans a space repository.
    ///
    /// - Parameter id: The repository identifier.
    /// - Returns: `true` if the scan was initiated successfully.
    /// - Throws: An error if the request fails.
    public func scanSpace(_ id: Repo.ID) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/scan"
        let result: Bool = try await fetch(.post, path)
        return result
    }

    /// Creates a new tag for a space repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - revision: The git revision to tag.
    ///   - tag: The name of the tag to create.
    ///   - message: An optional message for the tag.
    /// - Returns: `true` if the tag was created successfully.
    /// - Throws: An error if the request fails.
    public func createSpaceTag(
        _ id: Repo.ID,
        revision: String,
        tag: String,
        message: String? = nil
    ) async throws -> Bool {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/tag/\(revision)"

        let params: [String: Value] = [
            "tag": .string(tag),
            "message": message.map { .string($0) } ?? .null,
        ]

        let result: Bool = try await fetch(.post, path, params: params)
        return result
    }

    /// Super-squashes commits in a space repository.
    ///
    /// - Parameters:
    ///   - id: The repository identifier.
    ///   - revision: The git revision to squash.
    ///   - message: The commit message for the squashed commit.
    /// - Returns: The new commit ID.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func superSquashSpace(
        _ id: Repo.ID,
        revision: String,
        message: String
    ) async throws -> String {
        let path = "/api/spaces/\(id.namespace)/\(id.name)/super-squash/\(revision)"

        let params: [String: Value] = [
            "message": .string(message)
        ]

        struct Response: Decodable { let commitID: String }
        let resp: Response = try await fetch(.post, path, params: params)
        return resp.commitID
    }
}
