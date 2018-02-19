//
//  DeparturesViewController.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 17.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import UIKit

class DeparturesViewController : UITableViewController {
    private(set) var station: Station!
    
    var departures: [Departure]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    
    init(station: Station) {
        self.station = station
        
        super.init(style: .plain)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        super.loadView()
        
        tableView.register(DepartureTableViewCell.self, forCellReuseIdentifier: DepartureTableViewCell.Identifier)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "🗺️", style: .plain, target: self, action: #selector(openInMaps))
        
        refresh()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SpringBoardShortcutManager.shortcutHandler = { [weak self] station in
            self?.station = station
            self?.refresh()
        }
    }
    
    @objc func refresh() {
        title = station.name
        
        API.default.getDepartures(forStation: station) { error, departures in
            if let error = error {
                self.showError("Error", error.localizedDescription)
                return;
            }
            self.departures = departures
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func openInMaps() {
        // TODO add a pin to the map
        
        // https://developer.apple.com/library/content/featuredarticles/iPhoneURLScheme_Reference/MapLinks/MapLinks.html
        // https://developers.google.com/maps/documentation/urls/ios-urlscheme
        // https://developers.google.com/maps/documentation/ios-sdk/urlscheme
        
        let appleMapsUrl  = URL(string: "https://maps.apple.com/?sll=\(station.latitude),\(station.longitude)")!
        
        // zoom: int between 0 and 21 
        let googleMapsUrl = URL(string: "comgooglemaps://?center=\(station.latitude),\(station.longitude)&zoom=17&views=transit")!
        
        let googleMapsInstalled = UIApplication.shared.canOpenURL(googleMapsUrl)
        
        UIApplication.shared.open(googleMapsInstalled ? googleMapsUrl : appleMapsUrl)
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return departures?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = DepartureTableViewCell(departure: departures![indexPath.row])
        
        return cell
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let departure = departures![indexPath.row]
        
        let makeRemindMeAction = { (minutes: TimeInterval, color: UIColor) -> UITableViewRowAction in
            let action = UITableViewRowAction(style: .default, title: "t - \(Int(minutes)) min") { action, indexPath in
                
                NotificationManager.default.addNotification(for: departure, timeInterval: minutes * 60)
            }
            
            action.backgroundColor = color
            
            return action
        }
        
        let mappings: [TimeInterval: UIColor] = [
            10: .gray,
             5: .blue,
             2: .red
        ]
        return mappings.map(makeRemindMeAction)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
}
