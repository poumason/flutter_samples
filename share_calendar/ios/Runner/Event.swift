//
//  Event.swift
//  Runner
//
//  Created by Pou Lin on 2020/8/15.
//

import Foundation

class Event {
    var title: String?
    
    var location: String?
    
    var url: URL?
    
    var startDate: Date?
    
    var endDate: Date?
    
    init(title: String?, location: String?, url: String?, startDate: Double?, endDate: Double?) {
        self.title = title
        self.location = location
        
        if let urlStr = url, !urlStr.isEmpty, let newUrl = URL (string: urlStr) {
            self.url = newUrl
        }
        
        self.startDate = parseDate(interval: startDate)
        self.endDate = parseDate(interval: endDate)
    }
    
    func isValidated() -> Bool {
        if (startDate == nil || endDate == nil) {
            return false
        }
        
        return true
    }
    
    private func parseDate(interval: Double?) -> Date? {
        if (interval == nil || interval! < 0) {
            return nil
        }
        
        return Date.init(timeIntervalSince1970: interval!)
    }
}
