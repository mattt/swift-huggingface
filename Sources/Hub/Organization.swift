import Foundation

/// Information about an organization on the Hub.
public struct Organization: Codable, Sendable {
    /// The organization's name/username.
    public let name: String

    /// The organization's full name.
    public let fullName: String?

    /// The organization's avatar URL.
    public let avatarURL: String?

    /// Whether the organization is an enterprise.
    public let isEnterprise: Bool?

    /// The date the organization was created.
    public let createdAt: Date?

    /// The number of members.
    public let numberOfMembers: Int?

    /// The number of models.
    public let numberOfModels: Int?

    /// The number of datasets.
    public let numberOfDatasets: Int?

    /// The number of spaces.
    public let numberOfSpaces: Int?

    /// The organization's description.
    public let description: String?

    /// The organization's website.
    public let website: String?

    private enum CodingKeys: String, CodingKey {
        case name
        case fullName = "fullname"
        case avatarURL = "avatarUrl"
        case isEnterprise
        case createdAt
        case numberOfMembers = "numMembers"
        case numberOfModels = "numModels"
        case numberOfDatasets = "numDatasets"
        case numberOfSpaces = "numSpaces"
        case description
        case website
    }
}

// MARK: -

extension Organization {
    /// Information about an organization member.
    public struct Member: Codable, Sendable {
        /// The member's username.
        public let name: String

        /// The member's full name.
        public let fullName: String?

        /// The member's avatar URL.
        public let avatarURL: String?

        /// The member's role in the organization.
        public let role: String?

        private enum CodingKeys: String, CodingKey {
            case name
            case fullName = "fullname"
            case avatarURL = "avatarUrl"
            case role
        }
    }
}
