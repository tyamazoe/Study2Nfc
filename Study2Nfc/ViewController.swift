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

    private var ndefMessage: NFCNDEFMessage!
    private var session: NFCNDEFReaderSession!
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
        // get write string
        let textPayload = NFCNDEFPayload.wellKnownTypeURIPayload(string: self.TextWriteData.text ?? "write string")
        ndefMessage = NFCNDEFMessage(records: [textPayload!])
        
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
        // write
        if isWriting {
            session.connect(to: tag) { error in
                tag.queryNDEFStatus() { [unowned self] status, capacity, error in
                    if status == .readWrite {
                        self.writeTag(tag: tag, session: session)
                        return
                    }
                    session.invalidate(errorMessage: "error tag")
                }
            }
        }
        // read
        else {
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
    }
   
    
    private func writeTag(tag: NFCNDEFTag, session: NFCNDEFReaderSession) {
        print("write msg: ", self.ndefMessage ?? "no ndef message")
        tag.writeNDEF(self.ndefMessage) { error in
            session.alertMessage = "write alart"
            session.invalidate()
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
                    // TODO: skip 1st byte
                    let payloadData = $0.payload.advanced(by: 1)
                    // string
                    
                    if let payloadString = String(data: payloadData, encoding: .utf8) {
                        print("payloadString: ", payloadString)
                        DispatchQueue.main.async {
                            self.lblReadData.text = payloadString
                        }
                        return payloadString
                    }
                    
                    
                    // JSON
                    /*
                    if let payloadString = String(data: payloadData, encoding: .utf8),
                        let data = payloadString.data(using: .utf8) {
                            
                         do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                                print("json:", json)
                                DispatchQueue.main.async {
                                    self.lblReadData.text = "\(json)"
                                }
                                return "\(json)"
                            }
                        } catch let error {
                            print("Failed to create JSON object: \(error)")
                        }
                        return nil
                    }
                    */
                    return nil
                default:
                    return nil
                }
            }.joined(separator: "\n") ?? "no message"
            print("tag data strings:")
            print(text )
        }
    }


 
}
