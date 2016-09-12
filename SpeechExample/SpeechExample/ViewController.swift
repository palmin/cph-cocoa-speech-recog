//
//  ViewController.swift
//  SpeechExample
//
//  Created by Anders Borum on 12/09/16.
//  Copyright © 2016 Applied Phasor. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    
    
    @IBAction func play(_ sender: AnyObject) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = OutputVoiceTableSource.init().current
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    @IBAction func record(_ sender: AnyObject) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

