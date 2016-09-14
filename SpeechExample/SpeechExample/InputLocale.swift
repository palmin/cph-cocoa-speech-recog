//
//  InputLocale.swift
//  SpeechExample
//
//  Created by Anders Borum on 14/09/16.
//  Copyright © 2016 Applied Phasor. All rights reserved.
//

import UIKit
import Speech

class InputLocale: NSObject, UITableViewDataSource, UITableViewDelegate {
    let locales: [Locale] =  Array(SFSpeechRecognizer.supportedLocales()).sorted(by: {
        let title0 = $0.localizedString(forLanguageCode: $0.identifier)!
        let title1 = $1.localizedString(forLanguageCode: $1.identifier)!

        return title0.lowercased() < title1.lowercased()
    })
    let defaultsKey = "input-locale"

    public var current:Locale? {
        get {
            // default to en_US
            let identifier = UserDefaults.standard.string(forKey: defaultsKey) ?? "en_US"
            return Locale.init(identifier: identifier)
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
        return locales.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "locale"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier)
            ?? UITableViewCell.init(style: UITableViewCellStyle.subtitle, reuseIdentifier: identifier)
        
        let locale: Locale = locales[indexPath.row]
        let localName = Locale.current.localizedString(forLanguageCode: locale.identifier) ?? ""
        cell.textLabel?.text = locale.localizedString(forLanguageCode: locale.identifier)
        cell.detailTextLabel?.text = "\(locale.identifier), \(localName)"
        
        return cell
    }
    
    // current cell gets checkmark
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isCurrent = current == locales[indexPath.row]
        cell.accessoryType = isCurrent ? UITableViewCellAccessoryType.checkmark
                                       : UITableViewCellAccessoryType.none
    }
    
    // selected cell is made current
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        current = locales[indexPath.row]
        
        // quick and dirty way to refresh checkmarks
        tableView.reloadData()
    }

}
