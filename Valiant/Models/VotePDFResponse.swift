//
//  VotePDFResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//


struct VotePDFResponse: Codable {
    let message: String
    let status: Int
    let success: Bool
    let data: VotePDF
}

struct VotePDF: Codable {
    let id: Int
    let title: String
    let pdfUrl: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case id, title, pdfUrl, date
    }
}
