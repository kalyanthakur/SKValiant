//
//  HomeResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 06/02/26.
//


struct HomeResponse: Codable {
    let status: Int
    let success: Bool
    let message: String
    let data: HomeData
}

struct HomeData: Codable {
    let alertsData: [SpogAlert]
    let eventData: [SpogEvent]
    let presidentMsg: [PresidentsMessage]

    enum CodingKeys: String, CodingKey {
        case alertsData = "AlertsData"
        case eventData = "EventData"
        case presidentMsg = "PresidentMsg"
    }
}
