//
//  SocketAPI.swift
//  SlackChannelBotIntegration
//
//  Created by Sierra 2 on 30/10/17.
//  Copyright © 2017 SandsHellCreations. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON

protocol SocketDelegate: class {
    func message(_ messageDict: String)
}

class SocketAPI: NSObject {
    static let shared = SocketAPI()
    var socket: WebSocket?
    
    var delegate: SocketDelegate?
    
    var isConnected: Bool? {
        return self.socket?.isConnected ?? false
    }
    
    func connect(url: URL){
        self.socket = WebSocket(url: url)
        socket?.delegate = self
        socket?.connect()
    }
    
    func disConnect() {
        socket?.disconnect()
        socket = nil
    }
    
    func sendMessage(id: Int, type: String, channelID: String, text: String) {
        let json: JSON = [Slack.param.id : id,
                          Slack.param.type : type,
                          Slack.param.channel : channelID,
                          Slack.param.text : text]
        if let string = json.rawString() {
            self.send(message: string)
        }
    }
    
    func send(message: String) {
        if let socket = self.socket {
            if socket.isConnected {
                socket.write(string: message)
            } else {
                return
            }
        }
    }
}

extension SocketAPI: WebSocketDelegate {
    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        delegate?.message(text)
        print(text)
    }
    
    func websocketDidConnect(socket: WebSocket) {
        print("Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("Disconnected")
    }
    
    func websocketDidReceiveData(socket: WebSocket, data: Data) {
        print("Recieve Data")
    }
}

