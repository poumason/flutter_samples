//
//  EventActivity.swift
//  Runner
//
//  Created by Pou Lin on 2020/8/15.
//

import Foundation

import SwiftUI
import EventKit
import EventKitUI

class EventActivity : UIActivity {
    override public class var activityCategory: UIActivity.Category {
        return .action
    }
    
    override public var activityType: UIActivity.ActivityType? {
        guard let bundleId = Bundle.main.bundleIdentifier else { return nil }
        return UIActivity.ActivityType(bundleId + "\(self.classForCoder)")
    }
    
    override var activityTitle: String? {
        return NSLocalizedString("SaveToCalendar", comment: "")
    }
    
    override var activityImage: UIImage? {
        if #available(iOS 13.0, *) {
            return UIImage(systemName: "calendar.badge.plus", withConfiguration: UIImage.SymbolConfiguration(scale: .large))
        } else {
            return UIImage(named: "calendarActivity")
        }
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func perform() {
        activityDidFinish(true)
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        // 利用 EKEventStore 請求操作 Calendar 的權限
        let eventStore = EKEventStore()
        eventStore.requestAccess(to: .event) { (granted, error) in
            if (granted && error == nil) {
                // 先關閉 UIActivityViewController 再開啟 EKEventEditViewController
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    
                    let event = self.genereateEvent(eventStore: eventStore, arguments: activityItems as NSArray);
                    
                    if (event == nil) {
                        return
                    }
                    
                    self.insertEvent(event: event!, eventStore: eventStore)
                }
            } else {
                self.showAccessDeinedOrRestricted()
            }
        }
    }
    
    private func genereateEvent(eventStore: EKEventStore, arguments: NSArray) -> EKEvent? {
        guard let eventArgs = arguments.first(where: { $0.self is Event }) as? Event else { return nil }

        let newEvent = EKEvent(eventStore: eventStore)
        newEvent.title = eventArgs.title
        newEvent.location = eventArgs.location
        newEvent.startDate = eventArgs.startDate
        newEvent.endDate = eventArgs.endDate
        
        if (eventArgs.url != nil)
        {
            newEvent.url = eventArgs.url
        }
        return newEvent;
    }
    
    private func insertEvent(event: EKEvent, eventStore: EKEventStore)  {
        let viewController = EKEventEditViewController()
        
        viewController.eventStore = eventStore
        viewController.event = event
        viewController.editViewDelegate = UIApplication.shared.delegate as? EKEventEditViewDelegate
        
        let root = UIApplication.shared.windows.first?.rootViewController
        root?.present(viewController, animated: true, completion: nil)
    }
    
    
    private func showAccessDeinedOrRestricted() {
        let message = String(format: NSLocalizedString("OpenCalendarPermission", comment: ""), Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as! String)
        let controller = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: ""), style: .default, handler: nil)
        controller.addAction(okAction)
        
        let root = UIApplication.shared.windows.first?.rootViewController
        root?.present(controller, animated: true, completion: nil)
    }
}
