import Foundation

/// Access request for a gated repository.
public struct AccessRequest: Codable, Sendable {
    /// The user who made the request.
    public let user: User

    /// The user who granted the request (if any).
    public let grantedBy: User?

    /// Status of an access request.
    public enum Status: String, Hashable, CaseIterable, Codable, Sendable {
        case accepted
        case rejected
        case pending
    }

    /// The status of the request.
    public let status: Status

    /// Additional fields provided in the request.
    public let fields: [String: String]?

    /// When the request was made.
    public let timestamp: Date

    /// User information in an access request.
    public struct User: Codable, Sendable {
        /// User ID.
        public let id: String

        /// User's avatar URL.
        public let avatarURL: String

        /// User's full name.
        public let fullName: String

        /// Whether the user is a Pro user.
        public let isPro: Bool

        /// Username.
        public let user: String

        /// User type.
        public let type: String

        /// User's email.
        public let email: String?

        /// Number of models.
        public let numberOfModels: Int?

        /// Number of datasets.
        public let numberOfDatasets: Int?

        /// Number of spaces.
        public let numberOfSpaces: Int?

        /// Number of discussions.
        public let numberOfDiscussions: Int?

        /// Number of papers.
        public let numberOfPapers: Int?

        /// Number of upvotes.
        public let numberOfUpvotes: Int?

        /// Number of likes.
        public let numberOfLikes: Int?

        /// Number of followers.
        public let numberOfFollowers: Int?

        /// Number of following.
        public let numberOfFollowing: Int?

        /// User details.
        public let details: String?

        /// Whether the current user is following this user.
        public let isFollowing: Bool?

        /// Reason to follow.
        public let reasonToFollow: String?

        /// Organizations the user belongs to.
        public let organizations: [Organization]?

        private enum CodingKeys: String, CodingKey {
            case id = "_id"
            case avatarURL = "avatarUrl"
            case fullName = "fullname"
            case isPro
            case user
            case type
            case email
            case numberOfModels = "numModels"
            case numberOfDatasets = "numDatasets"
            case numberOfSpaces = "numSpaces"
            case numberOfDiscussions = "numDiscussions"
            case numberOfPapers = "numPapers"
            case numberOfUpvotes = "numUpvotes"
            case numberOfLikes = "numLikes"
            case numberOfFollowers = "numFollowers"
            case numberOfFollowing = "numFollowing"
            case details
            case isFollowing
            case reasonToFollow
            case organizations = "orgs"
        }
    }

    /// Organization information in an access request.
    public struct Organization: Codable, Sendable {
        /// Organization ID.
        public let id: String

        /// Organization name.
        public let name: String

        /// Organization full name.
        public let fullName: String

        /// Organization avatar URL.
        public let avatarURL: String
    }
}
