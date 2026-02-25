//
//  WebsocketService.swift
//  WebsocketNetworkService
//
//  Created by sugarbaron on 29.04.2021.
//

import Foundation
import CoreToolkit

public protocol WebsocketService {
    
    func connect(to url: URL)
    
    func disconnect()
    
    func send(_ binary: Data)
    
    func send(_ string: String)
    
    var events: Downstream<Websocket.Event> { get }

    var status: Websocket.Status { get }
    
}

public extension Websocket {
    
    enum Event {
        case connected
        case disconnected(_ code: Int = -1)
        case receivedBinary(Data)
        case receivedString(String)
    }
    
    enum Status {
        case disconnected
        case connecting
        case connected
        case disconnecting
    }
    
}
