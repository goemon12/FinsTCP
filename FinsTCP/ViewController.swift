//
//  ViewController.swift
//  FinsTCP
//
//  Created by goemon12 on 2018/12/24.
//  Copyright © 2018 goemon12. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var txt1: UITextField!
    @IBOutlet weak var txt2: UITextField!
    @IBOutlet weak var txt3: UITextField!
    @IBOutlet weak var txt4: UITextField!
    @IBOutlet weak var txt5: UITextField!
    @IBOutlet weak var txtV: UITextView!
    
    let tool = UIToolbar()
    var buff = [UInt8](repeating: 0x00, count: 1000)
    var inst: InputStream?
    var otst: OutputStream?
    var node1: UInt8?
    var node2: UInt8?

    override func viewDidLoad() {
        super.viewDidLoad()

        tool.barStyle = .default
        tool.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil),
            UIBarButtonItem(title: "キーを閉じる", style: .done, target: self, action: #selector(closeKey))]
        tool.sizeToFit()
        
        txt1.inputAccessoryView = tool
        txt2.inputAccessoryView = tool
        txt3.inputAccessoryView = tool
        txt4.inputAccessoryView = tool
        txt5.inputAccessoryView = tool
    }
    
    @objc func closeKey() {
        txt1.resignFirstResponder()
        txt2.resignFirstResponder()
        txt3.resignFirstResponder()
        txt4.resignFirstResponder()
        txt5.resignFirstResponder()
    }
    
    func finsOpen() -> Int {
        let addr = txt1.text
        let port = Int(txt2.text!)
        
        Stream.getStreamsToHost(withName: addr!, port: port!, inputStream: &inst, outputStream: &otst)
        inst?.open()
        otst?.open()
        
        return 0
    }
    
    func finsInfo() -> Int {
        let snum = 20
        var rnum = 0
        var smsg = "SEND:"
        var rmsg = "RECV:"
        var rval = 0
        
        buff[ 0] = 0x46//F
        buff[ 1] = 0x49//I
        buff[ 2] = 0x4e//N
        buff[ 3] = 0x53//S
        
        buff[ 4] = 0x00
        buff[ 5] = 0x00
        buff[ 6] = 0x00
        buff[ 7] = 0x0C
        
        buff[ 8] = 0x00
        buff[ 9] = 0x00
        buff[10] = 0x00
        buff[11] = 0x00
        
        buff[12] = 0x00
        buff[13] = 0x00
        buff[14] = 0x00
        buff[15] = 0x00
        
        buff[16] = 0x00
        buff[17] = 0x00
        buff[18] = 0x00
        buff[19] = 0x00
        
        for i in 0 ..< snum {
           smsg += String(format: " %02x", buff[i])
        }
        smsg += "\n"
        txtV.text.append(contentsOf: smsg)
        otst?.write(buff, maxLength: snum)
        
        rnum = (inst?.read(&buff, maxLength: 1000))!
        if (rnum == 24) {
            //0123 FINS
            //4567 LENG
            //8901 CMND
            //2345 ERR
            //6789 NODE CLIENT
            //0123 NODE SERVER
            
            for i in 0 ..< rnum {
                rmsg += String(format: " %02x", buff[i])
            }
            rmsg += "\n"
            
            node1 = buff[19]
            node2 = buff[23]
            rmsg += String(format: "CLIENT NODE: %3d\n", node1!)
            rmsg += String(format: "SERVER NODE: %3d\n", node2!)
            rmsg += "\n"

            rval =  0
        }
        else {
            rmsg += "\n\n"
            rval = -1
        }
        txtV.text.append(contentsOf: rmsg)
        return rval
    }
    
    func finsRead() -> Int {
        let snum = 34
        var rnum = 0
        var smsg = "SEND:"
        var rmsg = "RECV:"
        var rval = 0
        
        buff[ 0] = 0x46//F
        buff[ 1] = 0x49//I
        buff[ 2] = 0x4e//N
        buff[ 3] = 0x53//S
        
        buff[ 4] = 0x00//LENG 8+FINS
        buff[ 5] = 0x00
        buff[ 6] = 0x00
        buff[ 7] = 26
        
        buff[ 8] = 0x00//CMMD
        buff[ 9] = 0x00
        buff[10] = 0x00
        buff[11] = 0x02
        
        buff[12] = 0x00//ERR
        buff[13] = 0x00
        buff[14] = 0x00
        buff[15] = 0x00
        
        buff[16] = 0x80//ICF
        buff[17] = 0x00//RSV
        buff[18] = 0x02//GCT

        buff[19] = 0x00//DNA
        buff[20] = node2!//DA1
        buff[21] = 0x00//DA2

        buff[22] = 0x00//SNA
        buff[23] = node1!//SA1
        buff[24] = 0x00//SA2
        
        buff[25] = 0x00//SID
        buff[26] = 0x01//MRC
        buff[27] = 0x01//SRC

        buff[28] = 0x82
        buff[29] = 0x00
        buff[30] = 0x64
        buff[31] = 0x00
        buff[32] = 0x00
        buff[33] = 0x10
        
        for i in 0 ..< snum {
            smsg += String(format: " %02x", buff[i])
        }
        smsg += "\n"
        txtV.text.append(contentsOf: smsg)
        otst?.write(buff, maxLength: snum)
        
        rnum = (inst?.read(&buff, maxLength: 1000))!
        
        for i in 0 ..< rnum {
            rmsg += String(format: " %02x", buff[i])
        }
        rmsg += "\n"
        rmsg += String(format: "FINS終了コード: %02x%02x\n", buff[28], buff[29])
        rmsg += String(format: "読出チャネル+00CH: %02x%02x\n", buff[30], buff[31])
        rmsg += String(format: "読出チャネル+01CH: %02x%02x\n", buff[32], buff[33])

        
        
        txtV.text.append(contentsOf: rmsg)
        rval = 0
        
        return rval
    }

    @IBAction func actSend(_ sender: Any) {
        txtV.text = ""
        if (finsOpen() > -1) {
            if (finsInfo() > -1) {
                if (finsRead() > -1) {
                }
            }
        }
    }
}

