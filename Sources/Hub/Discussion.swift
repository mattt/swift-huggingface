import Foundation

/// Represents a full discussion with all its details.
public struct Discussion: Hashable, Codable, Sendable {
    // MARK: - Nested Types

    /// The status of a discussion.
    public enum Status: String, CustomStringConvertible, Hashable, Codable, Sendable {
        /// The discussion is open.
        case open

        /// The discussion is closed.
        case closed

        public var description: String {
            return rawValue
        }
    }

    /// Represents an author of a discussion or comment.
    public struct Author: Hashable, Codable, Sendable {
        /// The author's username.
        public let name: String

        /// The URL to the author's avatar image.
        public let avatarURL: String?

        /// Whether the author is a Hugging Face team member.
        public let isHfTeam: Bool?

        /// Whether the author is a moderator.
        public let isMod: Bool?
    }

    /// Represents a comment in a discussion.
    public struct Comment: Identifiable, Hashable, Codable, Sendable {
        /// The unique identifier of the comment.
        public let id: String

        /// The author of the comment.
        public let author: Author

        /// The content of the comment.
        public let content: String

        /// The date the comment was created.
        public let createdAt: Date

        /// Whether the comment is hidden.
        public let isHidden: Bool?

        /// The number of edits made to the comment.
        public let numberOfEdits: Int?

        /// The ID of the comment this is replying to, if any.
        public let replyTo: String?
    }

    /// Represents a reaction on a discussion.
    public struct Reaction: Hashable, Codable, Sendable {
        /// The reaction emoji.
        public let reaction: String

        /// The number of users who reacted with this emoji.
        public let count: Int
    }

    /// Represents repository owner information in a discussion.
    public struct RepoOwner: Hashable, Codable, Sendable {
        /// The owner's name.
        public let name: String

        /// The owner's type (org or user).
        public let type: String

        /// Whether the owner is participating in the discussion.
        public let isParticipating: Bool

        /// Whether the owner is the discussion author.
        public let isDiscussionAuthor: Bool
    }

    /// Represents a preview of a discussion (used in list responses).
    public struct Preview: Codable, Sendable {
        /// The discussion number.
        public let number: Int

        /// The author of the discussion.
        public let author: User

        /// The repository identifier.
        public let repo: Repo.ID

        /// The title of the discussion.
        public let title: String

        /// The date the discussion was created.
        public let createdAt: Date

        /// Top reactions on the discussion.
        public let topReactions: [Reaction]

        /// The current status of the discussion.
        public let status: Status

        /// Whether the discussion is a pull request.
        public let isPullRequest: Bool

        /// Number of comments in the discussion.
        public let numberOfComments: Int

        /// Number of users who reacted to the discussion.
        public let numberOfReactionUsers: Int

        /// Whether the discussion is pinned.
        public let pinned: Bool

        /// Repository owner information.
        public let repoOwner: RepoOwner
    }

    /// The discussion number.
    public let number: Int

    /// The title of the discussion.
    public let title: String

    /// The current status of the discussion.
    public let status: Status

    /// The author of the discussion.
    public let author: Author

    /// Whether the discussion is pinned.
    public let isPinned: Bool?

    /// Whether the discussion is a pull request.
    public let isPullRequest: Bool?

    /// The date the discussion was created.
    public let createdAt: Date

    /// The endpoint path for this discussion.
    public let endpoint: String?

    /// The comments in the discussion.
    public let comments: [Comment]?

    /// The number of comments in the discussion.
    public let numberOfComments: Int?

    /// The repository kind (model, dataset, or space).
    public let repoKind: Repo.Kind?

    /// The repository ID.
    public let repoID: Repo.ID?

    private enum CodingKeys: String, CodingKey {
        case number = "num"
        case title
        case status
        case author
        case isPinned
        case isPullRequest
        case createdAt
        case endpoint
        case comments
        case numberOfComments = "numComments"
        case repoKind = "repoType"
        case repoID = "repoId"
    }
}
