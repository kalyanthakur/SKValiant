//
//  AlertsResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 04/02/26.
//


struct AlertsResponse: Codable {
    let data: [SpogAlert]
    let status: Int
    let message: String
}

struct AlertDetailResponse: Codable {
    let message: String
    let status: Int
    let data: SpogAlert
}

struct SpogAlert: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String?
    let date: String
    
    let isPinned: Bool
    let isDeleted: Bool
    
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case image
        case date
        case isPinned
        case isDeleted
        case createdAt
        case updatedAt
    }
}
