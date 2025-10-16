import Testing
import Foundation
@testable import Hub

@Suite("Discussion Tests")
struct DiscussionTests {
    @Test("Discussion.Status encoding and decoding")
    func testDiscussionStatusCodable() throws {
        let openStatus = Discussion.Status.open
        let closedStatus = Discussion.Status.closed

        let encoder = JSONEncoder()
        let openData = try encoder.encode(openStatus)
        let closedData = try encoder.encode(closedStatus)

        let openString = String(data: openData, encoding: .utf8)!
        let closedString = String(data: closedData, encoding: .utf8)!

        #expect(openString == "\"open\"")
        #expect(closedString == "\"closed\"")

        let decoder = JSONDecoder()
        let decodedOpen = try decoder.decode(Discussion.Status.self, from: openData)
        let decodedClosed = try decoder.decode(Discussion.Status.self, from: closedData)

        #expect(decodedOpen == .open)
        #expect(decodedClosed == .closed)
    }

    @Test("Discussion.Author decoding")
    func testDiscussionAuthorDecoding() throws {
        let json = """
            {
                "name": "username",
                "avatarURL": "https://avatars.example.com/username",
                "isHfTeam": true,
                "isMod": false
            }
            """

        let data = json.data(using: .utf8)!
        let author = try JSONDecoder().decode(Discussion.Author.self, from: data)

        #expect(author.name == "username")
        #expect(author.avatarURL == "https://avatars.example.com/username")
        #expect(author.isHfTeam == true)
        #expect(author.isMod == false)
    }

    @Test("Discussion.Comment decoding")
    func testCommentDecoding() throws {
        let json = """
            {
                "id": "comment123",
                "author": {
                    "name": "commenter",
                    "avatarURL": "https://avatars.example.com/commenter",
                    "isHfTeam": false,
                    "isMod": false
                },
                "content": "This is a comment",
                "createdAt": "2023-05-10T12:00:00.000Z",
                "isHidden": false,
                "numberOfEdits": 2,
                "replyTo": null
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let data = json.data(using: .utf8)!
        let comment = try decoder.decode(Hub.Discussion.Comment.self, from: data)

        #expect(comment.id == "comment123")
        #expect(comment.author.name == "commenter")
        #expect(comment.content == "This is a comment")
        #expect(comment.isHidden == false)
        #expect(comment.numberOfEdits == 2)
        #expect(comment.replyTo == nil)
    }

    @Test("Discussion.Preview decoding")
    func testDiscussionPreviewDecoding() throws {
        let json = """
            {
                "number": 42,
                "title": "Feature Request",
                "status": "open",
                "author": {
                    "name": "requester",
                    "avatarURL": null,
                    "isHfTeam": null,
                    "isMod": null
                },
                "repo": "org/repo",
                "pinned": true,
                "isPullRequest": false,
                "createdAt": "2023-04-20T09:15:30.000Z",
                "numberOfComments": 5,
                "numberOfReactionUsers": 3,
                "topReactions": [],
                "repoOwner": {
                    "name": "org",
                    "type": "organization",
                    "isParticipating": false,
                    "isDiscussionAuthor": false
                }
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let data = json.data(using: .utf8)!
        let preview = try decoder.decode(Discussion.Preview.self, from: data)

        #expect(preview.number == 42)
        #expect(preview.title == "Feature Request")
        #expect(preview.status == .open)
        #expect(preview.author.name == "requester")
        #expect(preview.pinned == true)
        #expect(preview.isPullRequest == false)
        #expect(preview.repo == "org/repo")
        #expect(preview.numberOfComments == 5)
        #expect(preview.numberOfReactionUsers == 3)
        #expect(preview.repoOwner.name == "org")
    }

    @Test("Discussion full decoding")
    func testDiscussionDecoding() throws {
        let json = """
            {
                "num": 42,
                "title": "Bug Report",
                "status": "closed",
                "author": {
                    "name": "reporter",
                    "avatarURL": "https://avatars.example.com/reporter",
                    "isHfTeam": false,
                    "isMod": true
                },
                "isPinned": false,
                "isPullRequest": false,
                "createdAt": "2023-03-15T08:30:00.000Z",
                "endpoint": "/api/datasets/org/dataset/discussions/42",
                "comments": [
                    {
                        "id": "comment1",
                        "author": {
                            "name": "responder",
                            "avatarURL": null,
                            "isHfTeam": null,
                            "isMod": null
                        },
                        "content": "Thanks for reporting!",
                        "createdAt": "2023-03-15T09:00:00.000Z",
                        "isHidden": false,
                        "numberOfEdits": 0,
                        "replyTo": null
                    }
                ],
                "numComments": 1,
                "repoType": "dataset",
                "repoId": "org/dataset"
            }
            """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601WithFractionalSeconds

        let data = json.data(using: .utf8)!
        let discussion = try decoder.decode(Discussion.self, from: data)

        #expect(discussion.number == 42)
        #expect(discussion.title == "Bug Report")
        #expect(discussion.status == .closed)
        #expect(discussion.author.name == "reporter")
        #expect(discussion.author.isMod == true)
        #expect(discussion.isPinned == false)
        #expect(discussion.isPullRequest == false)
        #expect(discussion.comments?.count == 1)
        #expect(discussion.comments?[0].content == "Thanks for reporting!")
        #expect(discussion.numberOfComments == 1)
        #expect(discussion.repoKind == .dataset)
        #expect(discussion.repoID == "org/dataset")
    }
}
