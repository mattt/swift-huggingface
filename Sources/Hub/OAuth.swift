import Foundation

public enum OAuth {
    /// OAuth user information response.
    public struct UserInfo: Codable, Sendable {
        /// ID of the user.
        public let userID: String

        /// Full name of the user.
        public let name: String?

        /// Username of the user.
        public let username: String?

        /// Profile URL of the user.
        public let profileURL: String?

        /// Avatar URL of the user.
        public let avatarURL: String?

        /// Website of the user.
        public let website: String?

        /// Email of the user.
        public let email: String?

        /// Whether the email is verified.
        public let isEmailVerified: Bool?

        /// Whether the user is a Pro user.
        public let isPro: Bool

        /// Whether the user has access to billing.
        public let canPay: Bool?

        /// Organizations the user belongs to.
        public let organizations: [OAuth.Organization]

        private enum CodingKeys: String, CodingKey {
            case userID = "sub"
            case name
            case username = "preferred_username"
            case profileURL = "profile"
            case avatarURL = "picture"
            case website
            case email
            case isEmailVerified = "email_verified"
            case isPro
            case canPay
            case organizations = "orgs"
        }
    }

    /// OAuth organization information.
    public struct Organization: Codable, Sendable {
        /// ID of the organization.
        public let organizationID: String

        /// Name of the organization.
        public let name: String

        /// Avatar URL of the organization.
        public let avatarURL: String

        /// Username of the organization.
        public let username: String

        /// Whether the organization is an enterprise (deprecated).
        public let isEnterprise: Bool

        /// The organization's plan.
        public let plan: String?

        /// Whether the organization can pay.
        public let canPay: Bool?

        /// User's role in the organization.
        public let organizationRole: String?

        /// Whether SSO is pending (deprecated).
        public let isPendingSSO: Bool?

        /// Whether MFA is missing (deprecated).
        public let isMissingMFA: Bool?

        /// Current security restrictions.
        public let securityRestrictions: [String]?

        /// Resource groups the user has access to.
        public let resourceGroups: [OAuth.ResourceGroup]?

        private enum CodingKeys: String, CodingKey {
            case organizationID = "sub"
            case name
            case avatarURL = "picture"
            case username = "preferred_username"
            case isEnterprise
            case plan
            case canPay
            case organizationRole = "roleInOrg"
            case isPendingSSO = "pendingSSO"
            case isMissingMFA = "missingMFA"
            case securityRestrictions
            case resourceGroups
        }
    }

    /// OAuth resource group information.
    public struct ResourceGroup: Codable, Sendable {
        /// ID of the resource group.
        public let resourceGroupID: String

        /// Name of the resource group.
        public let name: String

        /// User's role in the resource group.
        public let role: String
    }
}
