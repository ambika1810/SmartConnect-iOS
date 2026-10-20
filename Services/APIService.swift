//
//  APIService.swift
//  MyApp
//
//  Created by Ambika Patil on 16/10/26.
//

import Foundation
import Combine

struct APIService {
    static let shared = APIService()

    private let baseURL = URL(
        string: "https://smartconnectapi.onrender.com"
    )!

    private init() {}

    // Fetch saved scans from the live API
    func fetchScans() async throws -> [Scan] {
        let url = baseURL.appendingPathComponent("api/scans")

        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        return try decoder.decode([Scan].self, from: data)
    }
    
    
    func uploadBLEScan(
        deviceName: String,
        rssi: Int,
        tagData: String
    ) async throws {
        let url = baseURL.appendingPathComponent("api/scans")

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )

        let body: [String: Any] = [
            "scanType": "BLE",
            "deviceName": deviceName,
            "rssi": rssi,
            "tagData": tagData
        ]

        request.httpBody = try JSONSerialization.data(
            withJSONObject: body
        )

        let (_, response) = try await URLSession.shared.data(
            for: request
        )

        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw APIError.invalidResponse
        }
    }

}

enum APIError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        "The server returned an invalid response."
    }
}
