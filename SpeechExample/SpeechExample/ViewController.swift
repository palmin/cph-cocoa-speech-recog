//
//  ViewController.swift
//  SpeechExample
//
//  Created by Anders Borum on 12/09/16.
//  Copyright © 2016 Applied Phasor. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet var recordButton: UIButton!
    
    @IBOutlet var stepper: UIStepper!
    @IBOutlet var label: UILabel!
    
    @IBAction func stepperChanged(_ sender: AnyObject) {
        let index = Int(stepper.value)
        let transcription = transcriptions[index]
        let text = transcription.formattedString
        self.textView?.text = text
        
        let confidence = Int(100.0 * self.confidence(for: transcription))
        self.label.text = "\(1+index)/\(transcriptions.count) \(confidence)%"
    }
    
    var audioEngine: AVAudioEngine?
    var inputNode: AVAudioInputNode?

    var recognizer: SFSpeechRecognizer? // non-nil when recording
    var request: SFSpeechAudioBufferRecognitionRequest? // non-nil when recording
    var transcriptions: [SFTranscription] = []
    
    func confidence(for transcription: SFTranscription) -> Double {
        var confidence = 1.0
        for segment in transcription.segments {
            confidence *= Double(segment.confidence)
        }
        return confidence
    }
    
    func startRecording() {
        textView.text = ""
        label.text = ""
        
        let locale = InputLocale.init().current
        recognizer = SFSpeechRecognizer.init(locale: locale!)
        request = SFSpeechAudioBufferRecognitionRequest()
        
        self.recognizer?.recognitionTask(with: request!, resultHandler: { (result, error) in
            if(result != nil && (result?.transcriptions.count)! >= 1) {
                self.transcriptions = (result?.transcriptions)!
                let count = (result?.transcriptions.count)! as Int
                
                self.stepper.value = 0
                self.stepper.minimumValue = 0
                self.stepper.maximumValue = Double(count) - 1.0
                let confidence = Int(100.0 * self.confidence(for: (result?.bestTranscription)!))
                self.label.text = "1/\(count) \(confidence)%"
                
                let text = result?.bestTranscription.formattedString
                self.textView?.text = text
            }
            
            var isFinal = false
            if result != nil {
                
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {
                self.audioEngine?.stop()
                self.inputNode?.removeTap(onBus: 0)
            }
            
            if(error != nil) {
                self.textView?.text = "recognition failed: \(error)"
            }
        })
        
        recordButton.setTitle("🎤", for: .normal)
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setActive(true)
            try audioEngine?.start()
        } catch {
            print("Unable to start recording: \(error)")
            recordButton.setTitle("🎙", for: .normal)
        }

    }
    
    func stopRecording() {
        audioEngine?.stop()
        request?.endAudio()
        request = nil
        recognizer = nil
        
        recordButton.setTitle("🎙", for: .normal)
    }
    
    @IBAction func record(_ sender: AnyObject) {
        if(recognizer == nil) {
            
            startRecording()
            
        } else {
            stopRecording()
        }
        
    }
    
    func setupRecognizer() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            if(authStatus != SFSpeechRecognizerAuthorizationStatus.authorized) {
                return
            }
            
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(AVAudioSessionCategoryPlayAndRecord)
            } catch {
                self.textView?.text = "audioSession properties weren't set: \(error)"
                return
            }
            
            self.audioEngine = AVAudioEngine()
            guard let inputNode = self.audioEngine?.inputNode else {
                self.textView?.text = "Audio engine has no input node"
                return
            }
            
            let recordingFormat = inputNode.outputFormat(forBus: 0)
            inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
                if(self.request != nil) {
                    self.request?.append(buffer)
                }
            }
            
            self.audioEngine?.prepare()
        }
    }
    
    @IBOutlet var playButton: UIButton!
    
    @IBAction func play(_ sender: AnyObject) {
        let utterance = AVSpeechUtterance(string: textView.text)
        utterance.voice = OutputVoice.init().current
        
        let synthesizer = AVSpeechSynthesizer()
        synthesizer.speak(utterance)
    }
    
    @IBOutlet var textView: UITextView!
    
    // dismiss keyboard on enter
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        if(text.contains("\n")) {
            textView.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupRecognizer()
    }
    
}

