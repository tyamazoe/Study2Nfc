//
//  ViewController.swift
//  Study2Nfc
//
//  Created by Tomohisa Yamazoe on 2024/01/18.
//

import UIKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    @IBOutlet weak var TextWriteData: UITextField!
    @IBOutlet weak var lblReadData: UILabel!
    @IBOutlet weak var TextReadData: UITextField!

    var isWriting = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startRead(_ sender: Any) {
        isWriting = false
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.begin()
        print("session read start")
    }

    @IBAction func startWrite(_ sender: Any) {
        isWriting = true
        guard let messageText = TextWriteData.text else { return }
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.begin()
        print("session write start")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("error")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        // Mandatory but not called anymore by didDetect
    }
    
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // do nothing
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
            let tag = tags.first!
            session.connect(to: tag) { (error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }
                tag.queryNDEFStatus { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if status == .readOnly {
                        session.invalidate(errorMessage: "Tag is not writable.")
                    } else if status == .readWrite {
//                        self.TextReadData.text = "reading "
                        self.readTag(tag: tag, session: session)
//                        if let retval = self.readTag(tag: tag, session: session) {
//                            self.TextReadData.text = "ok data"
//                        } else {
//                            self.TextReadData.text = "not data"
//                        }
                        
                    } else {
                        session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                    }
                }
            }
    }
    
    private func readTag(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        print("start readTag")
        tag.readNDEF { [unowned self] message, error in
            session.alertMessage = "read completed"
            session.invalidate()
//            print(message)
            print("start reading 2")
            let text = message?.records.compactMap {
                switch $0.typeNameFormat {
                case .nfcWellKnown:
                    print("--- nfcWelKnown")
                    if let url = $0.wellKnownTypeURIPayload() {
                        return url.absoluteString
                    }
                    let payloadData = $0.payload
                    if let payloadString = String(data: payloadData, encoding: .utf8) {
                        print(payloadString)
                        DispatchQueue.main.async {
                            self.lblReadData.text = payloadString
                        }
                        return payloadString
                    }
                    //let payload = $0.wellKnownTypeTextPayload()
                    //print("payload", payload)
//                    if let text = String(data: payload, locale: Locale(identifier: "ja_JP")) {
                    
                
//                    if let text = String(data: payload, encoding: .utf8) {
//                        return text
//                    }

                    //if let text = payload.0, let locale = payload.1 {
                        // return "\(text)\n\(locale)"
                        //return locale.localizedString(forRegionCode: text)
                    //}
                    return nil
                default:
                    return nil
                }
            }.joined(separator: "\n") ?? "no message"
            print(text ?? "no message")
        }
    }

/*
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        print("readerSession, ", isWriting)
        if !isWriting {
            print("just reading!")
            for message in messages {
                for payload in message.records {
                    if let payloadString = String.init(data: payload.payload.advanced(by: 1), encoding: .utf8) {
                        print(payloadString)
                        DispatchQueue.main.async {
                            self.TextReadData.text = payloadString
                            self.lblReadData.text = payloadString
                        }
                    }
                }
            }
        }
        // writing
        else {
            print("writing!")
            let tag = tags.first!
            session.connect(to: tag) { (error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }
                tag.queryNDEFStatus { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if status == .readOnly {
                        session.invalidate(errorMessage: "Tag is not writable.")
                    } else if status == .readWrite {
                        let payload = NFCNDEFPayload(format: .nfcWellKnown, type: Data(), identifier: Data(), payload: self.TextWriteData.text!.data(using: .utf8)!)
                        let message = NFCNDEFMessage(records: [payload])
                        tag.writeNDEF(message) { (error: Error?) in
                            if error != nil {
                                session.invalidate(errorMessage: "Write failed. Please try again.")
                            } else {
                                session.alertMessage = "Write successful!"
                                session.invalidate()
                            }
                        }
                    } else {
                        session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                    }
                }
            }
        }
    }
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        if isWriting {
            let tag = tags.first!
            session.connect(to: tag) { (error: Error?) in
                if error != nil {
                    session.invalidate(errorMessage: "Connection error. Please try again.")
                    return
                }
                tag.queryNDEFStatus { (status: NFCNDEFStatus, capacity: Int, error: Error?) in
                    if status == .readOnly {
                        session.invalidate(errorMessage: "Tag is not writable.")
                    } else if status == .readWrite {
                        let payload = NFCNDEFPayload(format: .nfcWellKnown, type: Data(), identifier: Data(), payload: self.TextWriteData.text!.data(using: .utf8)!)
                        let message = NFCNDEFMessage(records: [payload])
                        tag.writeNDEF(message) { (error: Error?) in
                            if error != nil {
                                session.invalidate(errorMessage: "Write failed. Please try again.")
                            } else {
                                session.alertMessage = "Write successful!"
                                session.invalidate()
                            }
                        }
                    } else {
                        session.invalidate(errorMessage: "Tag is not NDEF formatted.")
                    }
                }
            }
        }
    }
*/
 
}
