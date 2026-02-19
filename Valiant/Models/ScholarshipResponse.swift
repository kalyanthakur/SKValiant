//
//  ScholarshipResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//

import Foundation

struct ScholarshipResponse: Codable {
    let data: [Scholarship]
    let status: Int
    let success: Bool
    let message: String
}

struct ScholarshipDetailResponse: Codable {
    let message: String
    let status: Int
    let data: Scholarship
}

struct Scholarship: Codable {
    let id: Int
    let title: String
    let coverImg: String
    let description: String
    let date: String

    enum CodingKeys: String, CodingKey {
        case id, title, coverImg, description, date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        coverImg = try container.decode(String.self, forKey: .coverImg)
        description = try container.decode(String.self, forKey: .description)
        date = try container.decode(String.self, forKey: .date)
    }
}

