//
//  NotificationsResponse.swift
//  Valiant
//
//  Created by Kalyan Thakur on 11/02/26.
//


struct NotificationsResponse: Codable {
    let data: [NotificationItem]?
    let status: Int?
    let message: String?
}


struct NotificationItem: Codable, Identifiable {
    let id: Int?
    var isRead: Bool?
    let scheduledTime: String?
    let scheduledAt: String?
    let title: String?
    let message: String?
    let scheduledDate: String?

    enum CodingKeys: String, CodingKey {
        case id, isRead, scheduledTime, scheduledAt, title, message, scheduledDate
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id = try c.decodeIfPresent(Int.self, forKey: .id)
        scheduledTime = try c.decodeIfPresent(String.self, forKey: .scheduledTime)
        scheduledAt = try c.decodeIfPresent(String.self, forKey: .scheduledAt)
        title = try c.decodeIfPresent(String.self, forKey: .title)
        message = try c.decodeIfPresent(String.self, forKey: .message)
        scheduledDate = try c.decodeIfPresent(String.self, forKey: .scheduledDate)

        if let intVal = try c.decodeIfPresent(Int.self, forKey: .isRead) {
            isRead = intVal == 1
        } else if let boolVal = try c.decodeIfPresent(Bool.self, forKey: .isRead) {
            isRead = boolVal
        } else {
            isRead = false
        }
    }
}
