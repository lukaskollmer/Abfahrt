//
//  DepartureTableViewCell.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 17.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import Foundation
import UIKit

class DepartureTableViewCell : UITableViewCell {
    static let Identifier = "DepartureTableViewCell"
    
    let departure: Departure
    private var timer: Timer?
    
    init(departure: Departure) {
        self.departure = departure
        super.init(style: .value1, reuseIdentifier: nil)
        
        selectionStyle = .none
        
        timer = Timer.scheduledTimer(withTimeInterval:1, repeats: true) { [weak self] _ in
            self?.updateTimeRemaining()
        }
        
        textLabel?.text = departure.nicelyFormattedDescription()
        textLabel?.textColor = UIColor(hexString: departure.lineBackgroundColor)
        
        
        updateTimeRemaining()
    }
    
    func updateTimeRemaining() {
        let secondsLeft = departure.departureTime.timeIntervalSinceNow
        
        let timeLeft: String
        
        if abs(secondsLeft) < 60 {
            timeLeft = "\(Int(secondsLeft)) sec"
        } else {
            timeLeft = "\(Int(secondsLeft / 60)) min"
        }
        
        detailTextLabel?.text = timeLeft
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
}
