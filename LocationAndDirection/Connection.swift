//
//  Connection.swift
//  LocationAndDirection
//
//  Created by Atsuo Yonehara on 2017/08/21.
//  Copyright © 2017年 Atsuo Yonehara. All rights reserved.
//

import UIKit

class Connection: NSObject, StreamDelegate {
    let serverPort: UInt32 = 1100 //開放するポートを指定

    private var inputStream : InputStream!
    private var outputStream: OutputStream!

    //**
    /* @brief サーバーとの接続を確立する
     */
    func connect(address: String){
        print("connecting.....")

        var readStream : Unmanaged<CFReadStream>?
        var writeStream: Unmanaged<CFWriteStream>?
        
        let serverAddress: CFString =  NSString(string: address) //IPアドレスを指定
        CFStreamCreatePairWithSocketToHost(nil, serverAddress, self.serverPort, &readStream, &writeStream)

        self.inputStream  = readStream!.takeRetainedValue()
        self.outputStream = writeStream!.takeRetainedValue()

        self.inputStream.delegate  = self
        self.outputStream.delegate = self

        self.inputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        self.outputStream.schedule(in: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)

        self.inputStream.open()
        self.outputStream.open()

        print("connect success!!")
    }

    //**
    /* @brief inputStream/outputStreamに何かしらのイベントが起きたら起動してくれる関数
     *        今回の場合では、同期型なのでoutputStreamの時しか起動してくれない
     */
    func stream(_ stream:Stream, handle eventCode : Stream.Event){
        //print(stream)
    }

    //**
    /* @brief サーバーにコマンド文字列を送信する関数
     */
    func sendCommand(command: String){
        var ccommand = command.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        let text = ccommand.withUnsafeMutableBytes{ bytes in return String(bytesNoCopy: bytes, length: ccommand.count, encoding: String.Encoding.utf8, freeWhenDone: false)!}
        self.outputStream.write(UnsafePointer(text), maxLength: text.utf8.count)
        print("Send: \(command)")

//>> なくてもok
//        while(!inputStream.hasBytesAvailable){}
//        let bufferSize = 1024
//        var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
//        let bytesRead = inputStream.read(&buffer, maxLength: bufferSize)
//        if (bytesRead >= 0) {
//            let read = String(bytes: buffer, encoding: String.Encoding.utf8)!
//            print("Receive: \(read)")
//        }
//<< なくてもok

        //"end"を受信したら接続切断
        if (String(describing: command) == "end") {
            self.outputStream.close()
            self.outputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)

            while(!inputStream.hasBytesAvailable){}
            let bufferSize = 1024
            var buffer = Array<UInt8>(repeating: 0, count: bufferSize)
            let bytesRead = inputStream.read(&buffer, maxLength: bufferSize)
            if (bytesRead >= 0) {
                let read = String(bytes: buffer, encoding: String.Encoding.utf8)!
                print("Receive: \(read)")
            }
            self.inputStream.close()
            self.inputStream.remove(from: RunLoop.current, forMode: RunLoopMode.defaultRunLoopMode)
        }
    }

}
