import Foundation

// MARK: - User API

extension Client {
    /// Gets information about the authenticated user.
    ///
    /// Requires authentication with a Bearer token.
    ///
    /// - Returns: Information about the authenticated user.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func whoami() async throws -> User {
        return try await fetch(.get, "/api/whoami-v2")
    }

    /// Gets OAuth user information.
    ///
    /// Only available through OAuth access tokens. Information varies depending on the scope
    /// of the OAuth app and what permissions the user granted to the OAuth app.
    ///
    /// - Returns: OAuth user information.
    /// - Throws: An error if the request fails or the response cannot be decoded.
    public func getOAuthUserInfo() async throws -> OAuth.UserInfo {
        return try await fetch(.get, "/oauth/userinfo")
    }
}
