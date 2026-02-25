# websocket-network-service
useful and simple websocket service for Swift

```swift
// start:
let websocket: Websocket.Service = Websocket.ServiceEngine()
websocket.connect(to: url)

// send:
websocket.send(data)
websocket.send(string)

// receive:
websocket.events
    .sink { [weak self] in event
        switch event {
        case .receivedBinary(let incoming): self?.parse(incoming)
        case .receivedString(let incoming): self?.parse(incoming)
        case .connected:
        case .disconnected:
    }
    .store(in: &subscriptions)

// stop:
websocket.disconnect()
```
