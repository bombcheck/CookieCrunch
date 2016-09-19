//
//  Extensions.swift
//  CookieCrunch
//
//  Created by Nils Bernhardt on 17.06.16.
//  Copyright © 2016 Nils Bernhardt. All rights reserved.
//

import Foundation

// JSON-Handling
extension Dictionary {
    static func loadJSONFromBundle(filename: String) -> Dictionary <String, AnyObject>? {
        var dataOK: NSData
        var dictionaryOK: NSDictionary = NSDictionary()
        
        if let path = NSBundle.mainBundle().pathForResource(filename, ofType: "json") {
            let _: NSError?
            do {
                let data = try NSData(contentsOfFile: path, options: NSDataReadingOptions()) as NSData!
                dataOK = data
            }
            catch {
                print("Could not load file: \(filename), error: \(error)")
                return nil
            }
        
            do {
                let dictionary = try NSJSONSerialization.JSONObjectWithData(dataOK, options: NSJSONReadingOptions()) as AnyObject!
                dictionaryOK = (dictionary as! NSDictionary as? Dictionary <String, AnyObject>)!
            }
            catch {
                print("file '\(filename)' is not valid JSON: \(error)")
                return nil
            }
        }
        
        return dictionaryOK as? Dictionary <String, AnyObject>
    }
}