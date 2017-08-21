//
//  Connection.swift
//  LocationAndDirection
//
//  Created by Atsuo Yonehara on 2017/08/21.
//  Copyright © 2017年 Atsuo Yonehara. All rights reserved.
//

import UIKit

class Connection: NSObject,StreamDelegate {
    let serverAddress: CFString = "163.221.127.50" as CFString
    let serverPort: UInt32 = 1100
    
    private var inputStream: InputStream!
    private var outputStream: OutputStream!
    
    func connect(){
        print("connecting")
        
        var readStrream: Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        CFStreamCreatePairWithSocketToHost(nil, self.serverAddress, self.serverPort, &readStrream, &writeStream)
        
        self.inputStream = readStrream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()
        
        self.inputStream.delegate = self
        self.outputStream.delegate = self
        
        self.inputStream.schedule(in:.current, forMode: .defaultRunLoopMode)
        self.outputStream.schedule(in:.current, forMode: .defaultRunLoopMode)
        
        self.inputStream.open()
        self.outputStream.open()
        
        print("connect success!!")
    }
    
    func stream(_ aStream: Stream, handle eventCode: Stream.Event) {
        //print(stream)
    }
    
    func sendCommand(command: String){
        self.outputStream.write(UnsafePointer<UInt8> ([UInt8](command.utf8)), maxLength: command.lengthOfBytes(using: String.Encoding.utf8))
        print("Send: \(command)")
        
        
        if(command == "end"){
            self.outputStream.close()
            self.outputStream.remove(from: .current, forMode: .defaultRunLoopMode)
            
            while !inputStream.hasBytesAvailable {}
            let bufferSize = 1024
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            let bytestRead = inputStream.read(&buffer, maxLength: bufferSize)
            if bytestRead >= 0 {
                buffer.removeSubrange(bytestRead...bufferSize)
                let read = String(bytes: buffer, encoding: String.Encoding.utf8)!
                print("Receive: \(read)")
                self.inputStream.close()
                self.inputStream.remove(from: .current, forMode: .defaultRunLoopMode)
            }
        }
    }
}
