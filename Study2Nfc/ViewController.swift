//
//  ViewController.swift
//  Study2Nfc
//
//  Created by Tomohisa Yamazoe on 2024/01/18.
//

import UIKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("error")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for payload in message.records {
                if let payloadString = String.init(data: payload.payload.advanced(by: 1), encoding: .utf8) {
                    print(payloadString)
                    print("payloadString")
                    DispatchQueue.main.async {
                        self.TextReadData.text = payloadString
                    }
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBOutlet weak var TextReadData: UITextField!
    
    @IBAction func startRead(_ sender: Any) {
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.begin()
        print("session start")
    }
    

}

