//
//  NFCManager.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//


import Foundation
import CoreNFC
import Combine

final class NFCManager: NSObject, ObservableObject {

    @Published var status = "Ready to scan an NFC tag"
    @Published var tagInfo = ""

    private var session: NFCNDEFReaderSession?

    func startScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            status = "NFC reading is not available on this device"
            return
        }

        tagInfo = ""
        status = "Hold your iPhone near an NFC tag"

        let newSession = NFCNDEFReaderSession(
            delegate: self,
            queue: .main,
            invalidateAfterFirstRead: false
        )

        newSession.alertMessage = "Hold your iPhone near an NFC tag."
        session = newSession
        newSession.begin()
    }

    func stopScanning() {
        session?.invalidate()
        session = nil
        status = "NFC scanning stopped"
    }
}

extension NFCManager: NFCNDEFReaderSessionDelegate {

    func readerSession(
        _ session: NFCNDEFReaderSession,
        didInvalidateWithError error: Error
    ) {
        DispatchQueue.main.async {
            self.status = error.localizedDescription
            self.session = nil
        }
    }

    
    func readerSession(
        _ session: NFCNDEFReaderSession,
        didDetectNDEFs messages: [NFCNDEFMessage]
    ) {
        let descriptions = messages.flatMap { $0.records }.map { record -> String in

            switch record.typeNameFormat {

            case .nfcWellKnown:
                let textPayload = record.wellKnownTypeTextPayload()

                if let text = textPayload.0 {
                    return "Text: \(text)"
                }

                if let url = record.wellKnownTypeURIPayload() {
                    return "URL: \(url.absoluteString)"
                }

                return "NFC well-known record: \(record.payload.count) bytes"

            case .absoluteURI:
                if let uri = String(data: record.type, encoding: .utf8) {
                    return "URL: \(uri)"
                }

                return "URI record detected"

            case .media:
                let mediaType = String(data: record.type, encoding: .utf8)
                    ?? "Unknown media type"
                return "Media type: \(mediaType)\nPayload size: \(record.payload.count) bytes"

            case .empty:
                return "Empty NFC record"

            default:
                return """
                Record format: \(record.typeNameFormat)
                Payload size: \(record.payload.count) bytes
                """
            }
        }

        DispatchQueue.main.async {
            self.tagInfo = descriptions.isEmpty
                ? "NFC tag detected, but no NDEF records were found."
                : descriptions.joined(separator: "\n\n")

            self.status = "NFC tag read successfully"
            session.alertMessage = "NFC tag read successfully."
        }
    }
}
