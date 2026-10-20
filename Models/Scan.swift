//
//  Scan.swift
//  MyApp
//
//  Created by Ambika Patil on 16/10/26.
//


import Foundation

struct Scan: Codable, Identifiable {
    let id: UUID
    let scanType: String
    let deviceName: String?
    let rssi: Int?
    let tagData: String?
    let createdAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case scanType
        case deviceName
        case rssi
        case tagData
        case createdAt
    }
}
