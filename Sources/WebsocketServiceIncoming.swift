//
//  WebsocketServiceEvents.swift
//  WebsocketNetworkService
//
//  Created by sugarbaron on 29.04.2021.
//

import Starscream
import Foundation
import CoreToolkit

// MARK: constructor
internal extension Websocket.ServiceEngine {
    
    final class Incoming {
        
        private let downstream: PulseDownstream<Websocket.Event>
        
        internal init() {
            self.downstream = PulseDownstream()
        }
        
    }
    
}

// MARK: interface
internal extension Websocket.ServiceEngine.Incoming {
    
    var events: Downstream<Websocket.Event> {
        downstream.abstract()
    }
    
}

extension Websocket.ServiceEngine.Incoming : Starscream.WebSocketDelegate {
    
    internal func didReceive(event: Starscream.WebSocketEvent, client: Starscream.WebSocket) {
        switch event {
        case .connected(let headers):             connected(headers)
        case .disconnected(let reason, let code): disconnected("[\(Int(code))]\(reason)")
        case .cancelled:                          disconnected("cancelled")
        case .error(let error):                   react(to: error)
        case .text(let incoming):                 downstream.send(.receivedString(incoming))
        case .binary(let incoming):               downstream.send(.receivedBinary(incoming))
        case .viabilityChanged(let viability):    guard viability else { disconnected("due to viability"); return }
        case .reconnectSuggested(let suggested):  if suggested { disconnected("reconnect suggested"); return }
        default: log(warning: "[Websocket] skipping websocket event:[\(event)]")
        }
    }
    
}

// MARK: tools
private extension Websocket.ServiceEngine.Incoming {
    
    func connected(_ headers: [String : String]) {
        log("[Websocket] connected. \(headers)")
        downstream.send(.connected)
    }
    
    func react(to error: Error?) {
        if let upgradeError: Starscream.HTTPUpgradeError = error as? Starscream.HTTPUpgradeError {
            switch upgradeError {
            case .notAnUpgrade(let code): disconnected(status: code, "notAnUpgrade")
            default: disconnected("upgrade error:[\(upgradeError)]")
            }
        }
    }
    
    func disconnected(status code: Int? = nil, _ reason: String) {
        log("[Websocket] disconnected. [\(code.log)] \(reason)")
        let disconnected: Websocket.Event = unwrap(code) { .disconnected($0) } ?? .disconnected()
        downstream.send(disconnected)
    }
    
}
