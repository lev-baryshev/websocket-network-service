//
//  WebsocketServiceEngine.swift
//  WebsocketNetworkService
//
//  Created by sugarbaron on 29.04.2021.
//

import Foundation
import Combine
import Starscream
import CoreToolkit

// MARK: constructor
public extension Websocket {
    
    final class ServiceEngine {
        
        private var websocket: Starscream.WebSocket?
        private var server: URL?
        private var connection: Status
        private let incoming: Incoming
        private let mutex: NSRecursiveLock
        private var subscriptions: [AnyCancellable]
        
        init() {
            self.websocket = nil
            self.server = nil
            self.connection = .disconnected
            self.incoming = Incoming()
            self.mutex = NSRecursiveLock()
            self.subscriptions = [ ]
            self.start()
        }
        
    }
    
}

private extension Websocket.ServiceEngine {
    
    func start() {
        incoming.events
            .subscribe { [weak self] in self?.react(to: $0) }
            .store { subscriptions += $0 }
    }
    
}

// MARK: interface
extension Websocket.ServiceEngine : Websocket.Service {
    
    public func connect(to url: URL) {
        mutex.isolated {
            server = url
            connection = .connecting
            websocket = Starscream.WebSocket(request: URLRequest(url: url))
            websocket?.delegate = incoming
            websocket?.connect()
        }
    }
    
    public func disconnect() {
        mutex.isolated {
            connection = .disconnecting
            websocket?.disconnect()
        }
    }
    
    public func send(_ binary: Data) {
        mutex.isolated {
            websocket?.write(data: binary)
        }
    }
    
    public func send(_ string: String) {
        mutex.isolated {
            websocket?.write(string: string)
        }
    }
    
    public var events: Downstream<Websocket.Event> {
        incoming.events
    }
    
    public var status: Websocket.Status {
        mutex.isolated {
            connection
        }
    }
    
}

// MARK: tools
private extension Websocket.ServiceEngine {
    
    func react(to event: Websocket.Event) {
        mutex.isolated {
            switch event {
            case .connected:    connection = .connected
            case .disconnected: connection = .disconnected
            default: break
            }
        }
    }
    
}
