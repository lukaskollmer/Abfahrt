//
//  DeparturesViewController.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 17.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import UIKit

class DeparturesViewController : UITableViewController {
    let station: Station
    
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
        
        title = station.name
        
        tableView.register(DepartureTableViewCell.self, forCellReuseIdentifier: DepartureTableViewCell.Identifier)
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        refresh()
    }
    
    func refresh() {
        API.default.getDepartures(forStation: station) { error, departures in
            if let error = error {
                self.showError("Error", error.localizedDescription)
                return;
            }
            self.departures = departures
            self.tableView.refreshControl?.endRefreshing()
        }
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
}
