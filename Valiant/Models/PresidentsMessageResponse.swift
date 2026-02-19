//
//  PresidentsMessageResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//


struct PresidentsMessageResponse: Codable {
    let status: Int
    let message: String
    let data: [PresidentsMessage]
}

struct PresidentsMessageDetailResponse: Codable {
    let message: String
    let status: Int
    let data: PresidentsMessage
}


struct PresidentsMessage: Codable, Identifiable {

    let id: Int
    let title: String
    let description: String
    let image: String?
    let date: String

    let isPinned: Bool
    let isDeleted: Bool
    var isBookmark: Bool

    let createdAt: String
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case itemId
        case title
        case description
        case image
        case date
        case isPinned
        case isDeleted
        case isBookmark
        case createdAt
        case updatedAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // id can come as id OR itemId
        if let intId = try? c.decode(Int.self, forKey: .id) {
            id = intId
        } else if let stringId = try? c.decode(String.self, forKey: .itemId),
                  let intId = Int(stringId) {
            id = intId
        } else {
            id = 0
        }

        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        description = try c.decodeIfPresent(String.self, forKey: .description) ?? ""
        image = try c.decodeIfPresent(String.self, forKey: .image)
        date = try c.decodeIfPresent(String.self, forKey: .date) ?? ""

        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt) ?? ""
        updatedAt = try c.decodeIfPresent(String.self, forKey: .updatedAt)

        // isPinned may not exist
        if let intPinned = try? c.decode(Int.self, forKey: .isPinned) {
            isPinned = intPinned == 1
        } else if let boolPinned = try? c.decode(Bool.self, forKey: .isPinned) {
            isPinned = boolPinned
        } else {
            isPinned = false
        }

        // isDeleted may be int or bool
        if let intDeleted = try? c.decode(Int.self, forKey: .isDeleted) {
            isDeleted = intDeleted == 1
        } else if let boolDeleted = try? c.decode(Bool.self, forKey: .isDeleted) {
            isDeleted = boolDeleted
        } else {
            isDeleted = false
        }

        // bookmark flexible
        if let intValue = try? c.decode(Int.self, forKey: .isBookmark) {
            isBookmark = intValue == 1
        } else if let boolValue = try? c.decode(Bool.self, forKey: .isBookmark) {
            isBookmark = boolValue
        } else {
            isBookmark = false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encode(date, forKey: .date)
        try container.encode(isPinned ? 1 : 0, forKey: .isPinned)
        try container.encode(isDeleted ? 1 : 0, forKey: .isDeleted)
        try container.encode(isBookmark ? 1 : 0, forKey: .isBookmark)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
    }
}

