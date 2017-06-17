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
        
        timer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
            self.updateLabels()
        }
        
        updateLabels()
    }
    
    func updateLabels() {
        textLabel?.text = "\(departure.label) - \(departure.destination)"
        detailTextLabel?.text = "\(Int(departure.departureTime.timeIntervalSinceNow / 60)) min"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
    }
}
