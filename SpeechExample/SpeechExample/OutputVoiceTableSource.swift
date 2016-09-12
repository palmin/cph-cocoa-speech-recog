//
//  OutputVoiceTableSource.swift
//  SpeechExample
//
//  Created by Anders Borum on 12/09/16.
//  Copyright © 2016 Applied Phasor. All rights reserved.
//

import UIKit
import Speech

class OutputVoiceTableSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    let voices = AVSpeechSynthesisVoice.speechVoices()
    let defaultsKey = "output-voice"
    
    public var current:AVSpeechSynthesisVoice? {
        get {
            let identifier = UserDefaults.standard.string(forKey: defaultsKey)
            if(identifier != nil) {
                return AVSpeechSynthesisVoice.init(identifier: identifier!)
            } else {
                // default to voice for current languge
                let language = AVSpeechSynthesisVoice.currentLanguageCode()
                return AVSpeechSynthesisVoice.init(language: language)
            }
        }
        
        set(value) {
            if(value == nil) {
                UserDefaults.standard.removeObject(forKey: defaultsKey)
            } else {
                UserDefaults.standard.set(value?.identifier, forKey: defaultsKey)
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return voices.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "voice"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
                 ?? UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
        
        let voice = voices[indexPath.row]
        cell.textLabel?.text = voice.name
        cell.detailTextLabel?.text = "\(voice.language), \(voice.identifier)"
        
        return cell
    }
    
    // current cell gets checkmark
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isCurrent = current == voices[indexPath.row]
        cell.accessoryType = isCurrent ? UITableViewCellAccessoryType.checkmark
                                       : UITableViewCellAccessoryType.none
    }
    
    // selected cell is made current
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        current = voices[indexPath.row]
        
        // quick and dirty way to refresh checkmarks
        tableView.reloadData()
    }
    
}

