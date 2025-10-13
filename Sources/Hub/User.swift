import Foundation

/// Information about the authenticated user.
public struct User: Codable, Sendable {
    /// The user's username.
    public let name: String

    /// The user's full name.
    public let fullName: String?

    /// The user's email address.
    public let email: String?

    /// Whether email is verified.
    public let isEmailVerified: Bool?

    /// The user's avatar URL.
    public let avatarURL: String?

    /// Whether the user is a PRO subscriber.
    public let isPro: Bool?

    /// The organizations the user belongs to.
    public let organizations: [Organization]?

    /// The authentication method.
    public let auth: AuthInfo?

    /// Authentication information.
    public struct AuthInfo: Codable, Sendable {
        /// The authentication type.
        public let type: String

        /// The access token information.
        public let accessToken: AccessTokenInfo?

        /// Information about an access token.
        public struct AccessTokenInfo: Codable, Sendable {
            /// The display name of the token.
            public let displayName: String?

            /// The role of the token.
            public let role: String?

            private enum CodingKeys: String, CodingKey {
                case displayName
                case role
            }
        }
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case fullName = "fullname"
        case email
        case isEmailVerified = "emailVerified"
        case avatarURL = "avatarUrl"
        case isPro
        case organizations = "orgs"
        case auth
    }
}
