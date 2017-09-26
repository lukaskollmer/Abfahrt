//
//  SpringBoardShortcutManager.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 26.09.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import UIKit


struct SpringBoardShortcutManager {
    
    typealias ShortcutHandler = (Station) -> Void
    static var shortcutHandler: ShortcutHandler?
    
    static func add(station: Station) {
        let info = ["stationId": station.id]
        let subtitle = station.services.map { $0.description }.joined(separator: ", ")
        let newItem = UIApplicationShortcutItem(type: "station", localizedTitle: station.name, localizedSubtitle: subtitle, icon: nil, userInfo: info)
        
        var shortcuts = UIApplication.shared.shortcutItems ?? []
        // Make sure the selected station isn't already a shortcut. todo: if the selected station is already in the shortcuts, move it to the top
        guard !shortcuts.contains(where: { $0.localizedTitle == newItem.localizedTitle && $0.localizedSubtitle == newItem.localizedSubtitle }) else { return }
        
        if shortcuts.count > 3 {
            shortcuts = shortcuts.prefix(upTo: 3).map { $0 }
        }
        
        shortcuts.insert(newItem, at: 0)
        UIApplication.shared.shortcutItems = shortcuts
    }
}
