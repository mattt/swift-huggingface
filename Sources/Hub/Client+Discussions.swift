import Foundation

// MARK: - Discussions API

extension Client {
    // MARK: - List Discussions

    /// Lists discussions for a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - page: Page number for pagination (default: 0).
    ///   - type: Filter by discussion type ("all", "discussion", "pull_request", default: "all").
    ///   - status: Filter by discussion status ("all", "open", "closed", default: "all").
    ///   - author: Filter by author username.
    ///   - search: Search term to filter discussions.
    ///   - sort: Sort order ("recently-created", "trending", "reactions", default: "recently-created").
    /// - Returns: A discussions response with pagination info.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func listDiscussions(
        kind: Repo.Kind,
        _ id: Repo.ID,
        page: Int? = nil,
        type: String? = nil,
        status: String? = nil,
        author: String? = nil,
        search: String? = nil,
        sort: String? = nil
    ) async throws -> (discussions: [Discussion.Preview], count: Int, start: Int, numberOfClosedDiscussions: Int?) {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions"

        var params: [String: Value] = [:]
        if let page { params["p"] = .int(page) }
        if let type { params["type"] = .string(type) }
        if let status { params["status"] = .string(status) }
        if let author { params["author"] = .string(author) }
        if let search { params["search"] = .string(search) }
        if let sort { params["sort"] = .string(sort) }

        struct Response: Codable, Sendable {
            let discussions: [Discussion.Preview]
            let count: Int
            let start: Int
            let numberOfClosedDiscussions: Int?
        }

        let response: Response = try await fetch(.get, apiPath, params: params)
        return (response.discussions, response.count, response.start, response.numberOfClosedDiscussions)
    }

    // MARK: - Get Discussion

    /// Gets a specific discussion from a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    /// - Returns: The full discussion details.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getDiscussion(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int
    ) async throws -> Discussion {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)"
        return try await fetch(.get, apiPath)
    }

    // MARK: - Add Comment

    /// Adds a comment to a repository discussion.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    ///   - comment: The comment text to add.
    /// - Returns: `true` if the comment was added successfully.
    /// - Throws: An error if the request fails.
    public func addCommentToDiscussion(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int,
        comment: String
    ) async throws -> Bool {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)/comment"

        let params: [String: Value] = ["comment": .string(comment)]
        let result: Bool = try await fetch(.post, apiPath, params: params)
        return result
    }

    // MARK: - Merge Discussion

    /// Merges a pull request discussion in a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    /// - Returns: `true` if the discussion was merged successfully.
    /// - Throws: An error if the request fails.
    public func mergeDiscussion(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int
    ) async throws -> Bool {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)/merge"
        let result: Bool = try await fetch(.post, apiPath)
        return result
    }

    // MARK: - Pin Discussion

    /// Pins a discussion in a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    /// - Returns: `true` if the discussion was pinned successfully.
    /// - Throws: An error if the request fails.
    public func pinDiscussion(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int
    ) async throws -> Bool {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)/pin"
        let result: Bool = try await fetch(.post, apiPath)
        return result
    }

    // MARK: - Update Status

    /// Updates the status of a discussion in a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    ///   - status: The new status.
    /// - Returns: `true` if the status was updated successfully.
    /// - Throws: An error if the request fails.
    public func updateDiscussionStatus(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int,
        status: Discussion.Status
    ) async throws -> Bool {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)/status"

        let params: [String: Value] = ["status": .string(status.rawValue)]
        let result: Bool = try await fetch(.patch, apiPath, params: params)
        return result
    }

    // MARK: - Update Title

    /// Updates the title of a discussion in a repository.
    ///
    /// - Parameters:
    ///   - kind: The kind of repository.
    ///   - id: The repository identifier.
    ///   - number: The discussion number.
    ///   - title: The new title.
    /// - Returns: `true` if the title was updated successfully.
    /// - Throws: An error if the request fails.
    public func updateDiscussionTitle(
        kind: Repo.Kind,
        _ id: Repo.ID,
        number: Int,
        title: String
    ) async throws -> Bool {
        let repoTypePath = kind.pluralized
        let apiPath = "/api/\(repoTypePath)/\(id.namespace)/\(id.name)/discussions/\(number)/title"

        let params: [String: Value] = ["title": .string(title)]
        let result: Bool = try await fetch(.patch, apiPath, params: params)
        return result
    }

    // MARK: - Mark as Read

    /// Marks multiple discussions as read.
    ///
    /// - Parameter discussionNumbers: The discussion numbers to mark as read.
    /// - Returns: `true` if the discussions were marked as read successfully.
    /// - Throws: An error if the request fails.
    public func markDiscussionsAsRead(_ discussionNumbers: [Int]) async throws -> Bool {
        let apiPath = "/api/discussions/mark-as-read"
        let params: [String: Value] = ["discussionNums": .array(discussionNumbers.map { .int($0) })]
        let result: Bool = try await fetch(.post, apiPath, params: params)
        return result
    }
}
