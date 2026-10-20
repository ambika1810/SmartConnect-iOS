//
//  USBManager.swift
//  MyApp
//
//  Created by Ambika Patil on 15/10/26.
//



import Foundation
import NearbyInteraction
import MultipeerConnectivity
import Combine

final class UWBManager: NSObject, ObservableObject {

    @Published var status = "Nearby Interaction has not started"
    @Published var distance: Float?
    @Published var direction: SIMD3<Float>?

    private let serviceType = "sc-uwb"

    private let peerID = MCPeerID(
        displayName: ProcessInfo.processInfo.hostName
    )

    private var session: NISession?
    private var peerSession: MCSession?
    private var advertiser: MCNearbyServiceAdvertiser?
    private var browser: MCNearbyServiceBrowser?

    private var isUWBSupported: Bool {
        if #available(iOS 16.0, *) {
            return NISession.deviceCapabilities
                .supportsPreciseDistanceMeasurement
        } else {
            return NISession.isSupported
        }
    }

    override init() {
        super.init()

        let connection = MCSession(
            peer: peerID,
            securityIdentity: nil,
            encryptionPreference: .required
        )
        connection.delegate = self
        peerSession = connection
    }

    // MARK: - Availability

    func checkAvailability() {
        guard isUWBSupported else {
            status = "Nearby Interaction is not supported"
            return
        }

        prepareNearbySession()
        status = session?.discoveryToken == nil
            ? "Supported. Waiting for a discovery token."
            : "Supported. Ready to connect to a peer."
    }

    private func prepareNearbySession() {
        guard session == nil else { return }

        let newSession = NISession()
        newSession.delegate = self
        session = newSession
    }

    // MARK: - Peer Discovery

    func startPeerDiscovery() {
        guard isUWBSupported else {
            status = "Nearby Interaction is not supported"
            return
        }

        prepareNearbySession()

        guard let peerSession else {
            status = "Could not create the peer connection"
            return
        }

        let newAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerID,
            discoveryInfo: nil,
            serviceType: serviceType
        )
        newAdvertiser.delegate = self
        advertiser = newAdvertiser

        let newBrowser = MCNearbyServiceBrowser(
            peer: peerID,
            serviceType: serviceType
        )
        newBrowser.delegate = self
        browser = newBrowser

        newAdvertiser.startAdvertisingPeer()
        newBrowser.startBrowsingForPeers()

        status = "Searching for a compatible peer..."
    }

    func stopPeerDiscovery() {
        advertiser?.stopAdvertisingPeer()
        browser?.stopBrowsingForPeers()

        advertiser = nil
        browser = nil

        status = "Peer discovery stopped"
    }

    private func sendDiscoveryToken() {
        guard
            let token = session?.discoveryToken,
            let peerSession,
            !peerSession.connectedPeers.isEmpty
        else {
            status = "Connected. Waiting for a discovery token."
            return
        }

        do {
            let data = try NSKeyedArchiver.archivedData(
                withRootObject: token,
                requiringSecureCoding: true
            )

            try peerSession.send(
                data,
                toPeers: peerSession.connectedPeers,
                with: .reliable
            )

            status = "Discovery token sent. Waiting for peer token..."
        } catch {
            status = "Could not send discovery token: \(error.localizedDescription)"
        }
    }

    private func receiveDiscoveryToken(_ data: Data) {
        do {
            guard let token = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: NIDiscoveryToken.self,
                from: data
            ) else {
                status = "Received an invalid discovery token"
                return
            }

            DispatchQueue.main.async {
                self.startRanging(with: token)
            }
        } catch {
            status = "Could not read peer token: \(error.localizedDescription)"
        }
    }

    // MARK: - Real UWB Ranging

    func startRanging(with peerToken: NIDiscoveryToken) {
        guard isUWBSupported else {
            status = "Nearby Interaction is not supported"
            return
        }

        prepareNearbySession()

        guard let session else { return }

        let configuration = NINearbyPeerConfiguration(
            peerToken: peerToken
        )

        distance = nil
        direction = nil
        status = "Starting real UWB ranging..."

        session.run(configuration)
    }

    func stopRanging() {
        stopPeerDiscovery()

        session?.invalidate()
        session = nil

        peerSession?.disconnect()

        distance = nil
        direction = nil
        status = "UWB ranging stopped"
    }
}

// MARK: - Nearby Interaction

extension UWBManager: NISessionDelegate {

    func session(
        _ session: NISession,
        didUpdate nearbyObjects: [NINearbyObject]
    ) {
        guard let object = nearbyObjects.first else { return }

        DispatchQueue.main.async {
            self.distance = object.distance
            self.direction = object.direction
            self.status = "Receiving real Nearby Interaction updates"
        }
    }

    func session(
        _ session: NISession,
        didRemove nearbyObjects: [NINearbyObject],
        reason: NINearbyObject.RemovalReason
    ) {
        DispatchQueue.main.async {
            self.distance = nil
            self.direction = nil
            self.status = "Peer removed. Reason: \(reason)"
        }
    }

    func sessionWasSuspended(_ session: NISession) {
        DispatchQueue.main.async {
            self.status = "UWB session suspended"
        }
    }

    func sessionSuspensionEnded(_ session: NISession) {
        DispatchQueue.main.async {
            self.status = "Session resumed. Reconnect if needed."
        }
    }

    func session(
        _ session: NISession,
        didInvalidateWith error: Error
    ) {
        DispatchQueue.main.async {
            self.status = "UWB session ended: \(error.localizedDescription)"
            self.distance = nil
            self.direction = nil
        }
    }
}

// MARK: - Multipeer Connectivity

extension UWBManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(
        _ advertiser: MCNearbyServiceAdvertiser,
        didReceiveInvitationFromPeer peerID: MCPeerID,
        withContext context: Data?,
        invitationHandler: @escaping (Bool, MCSession?) -> Void
    ) {
        guard let peerSession else {
            invitationHandler(false, nil)
            return
        }

        invitationHandler(true, peerSession)
    }
}

extension UWBManager: MCNearbyServiceBrowserDelegate {

    func browser(
        _ browser: MCNearbyServiceBrowser,
        foundPeer peerID: MCPeerID,
        withDiscoveryInfo info: [String: String]?
    ) {
        guard let peerSession,
              !peerSession.connectedPeers.contains(peerID) else {
            return
        }

        browser.invitePeer(
            peerID,
            to: peerSession,
            withContext: nil,
            timeout: 30
        )

        DispatchQueue.main.async {
            self.status = "Found peer: \(peerID.displayName). Connecting..."
        }
    }

    func browser(
        _ browser: MCNearbyServiceBrowser,
        lostPeer peerID: MCPeerID
    ) {
        DispatchQueue.main.async {
            self.status = "Peer no longer visible: \(peerID.displayName)"
        }
    }
}

extension UWBManager: MCSessionDelegate {

    func session(
        _ session: MCSession,
        peer peerID: MCPeerID,
        didChange state: MCSessionState
    ) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                self.status = "Connected to \(peerID.displayName). Exchanging tokens..."
                self.sendDiscoveryToken()

            case .connecting:
                self.status = "Connecting to \(peerID.displayName)..."

            case .notConnected:
                self.status = "Peer disconnected: \(peerID.displayName)"

            @unknown default:
                self.status = "Unknown peer connection state"
            }
        }
    }

    func session(
        _ session: MCSession,
        didReceive data: Data,
        fromPeer peerID: MCPeerID
    ) {
        receiveDiscoveryToken(data)
    }

    func session(
        _ session: MCSession,
        didReceive stream: InputStream,
        withName streamName: String,
        fromPeer peerID: MCPeerID
    ) {}

    func session(
        _ session: MCSession,
        didStartReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        with progress: Progress
    ) {}

    func session(
        _ session: MCSession,
        didFinishReceivingResourceWithName resourceName: String,
        fromPeer peerID: MCPeerID,
        at localURL: URL?,
        withError error: Error?
    ) {}
}
