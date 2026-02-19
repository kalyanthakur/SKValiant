//
//  BookmarksResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 13/02/26.
//


struct BookmarksListResponse: Codable {
    let data: BookmarksData?
    let status: Int?
    let message: String?
}

struct BookmarksData: Codable {
    let presidentMessages: [PresidentsMessage]?
    let spogDocuments: [DocumentItem]?
    let events: [SpogEvent]?

    enum CodingKeys: String, CodingKey {
        case presidentMessages = "president_messages"
        case spogDocuments = "spog_documents"
        case events
    }
}
