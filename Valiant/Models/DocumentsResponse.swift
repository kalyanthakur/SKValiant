//
//  DocumentsResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 08/02/26.
//


struct DocumentsResponse: Codable {
    let success: Bool
    let status: Int
    let message: String
    let data: [DocumentItem]
}

struct DocumentsDetailResponse: Codable {
    let message: String
    let status: Int
    let data: DocumentDetail
}

struct DocumentItem: Codable, Identifiable {

    let id: Int
    let documentName: String
    let title: String
    let image: String?
    let icon: String?
    let createdAt: String?
    var isBookmark: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case itemId
        case documentName
        case title
        case image
        case icon
        case createdAt
        case isBookmark
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        // id may come as id OR itemId OR string
        if let intId = try? c.decode(Int.self, forKey: .id) {
            id = intId
        } else if let stringId = try? c.decode(String.self, forKey: .itemId),
                  let intId = Int(stringId) {
            id = intId
        } else {
            id = 0
        }

        documentName = try c.decodeIfPresent(String.self, forKey: .documentName) ?? ""
        title = try c.decodeIfPresent(String.self, forKey: .title) ?? ""
        image = try c.decodeIfPresent(String.self, forKey: .image)
        icon = try c.decodeIfPresent(String.self, forKey: .icon)
        createdAt = try c.decodeIfPresent(String.self, forKey: .createdAt) ?? ""

        // bookmark may be int or bool
        if let intVal = try? c.decode(Int.self, forKey: .isBookmark) {
            isBookmark = intVal == 1
        } else if let boolVal = try? c.decode(Bool.self, forKey: .isBookmark) {
            isBookmark = boolVal
        } else {
            isBookmark = false
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(documentName, forKey: .documentName)
        try container.encodeIfPresent(title, forKey: .title)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(isBookmark.map { $0 ? 1 : 0 }, forKey: .isBookmark)
    }
}



struct DocumentDetail: Codable, Identifiable {
    var isBookmark: Bool
    let id: Int
    let documentName: String
    let title: String
    let image: String?
    let icon: String?
    let description: String
    let createdAt: String
    let updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id, documentName, title, image, icon, createdAt, isBookmark, description, updatedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        documentName = try container.decode(String.self, forKey: .documentName)
        title = try container.decode(String.self, forKey: .title)
        image = try container.decodeIfPresent(String.self, forKey: .image)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decode(String.self, forKey: .updatedAt)
        description = try container.decode(String.self, forKey: .description)

        let bookmarkValue = try container.decode(Int.self, forKey: .isBookmark)
        isBookmark = bookmarkValue == 1
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(documentName, forKey: .documentName)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(image, forKey: .image)
        try container.encodeIfPresent(icon, forKey: .icon)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(description, forKey: .description)
        try container.encode(isBookmark ? 1 : 0, forKey: .isBookmark)
    }
}
