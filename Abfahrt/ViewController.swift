//
//  ViewController.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 17.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UITableViewController, CLLocationManagerDelegate, UIViewControllerPreviewingDelegate {
    
    // Location stuff
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        didSet {
            if let location = currentLocation {
                updateDeparturesForLocation(location)
            }
        }
    }
    
    // Public transport stuff
    let mvgClient = API()
    
    var nearestStations = [Station]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func loadView() {
        super.loadView()
        
        title = "Nearby Stations"
        
        // todo: enabling large titles has some nasty side effects when refreshing the table (everything jumps around and it just looks weird)
        //navigationController?.navigationBar.prefersLargeTitles = true
        
        locationManager.delegate = self
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        locationManager.requestWhenInUseAuthorization()
        
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        // todo: maybe in the future
        //navigationItem.leftBarButtonItem = UIBarButtonItem(title: "🚧", style: .plain, target: self, action: #selector(showInterruptions))
        
        setup3dTouch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        SpringBoardShortcutManager.shortcutHandler = { station in
            self.showDepartures(for: station, animated: false)
        }
        
        // Always start location updates when the app is opened
        refresh()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: 3D-Touch
    func setup3dTouch() {
        guard traitCollection.forceTouchCapability == .available else { return }
        
        self.registerForPreviewing(with: self, sourceView: self.view)
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        let indexPath = self.tableView.indexPathForRow(at: location)!
        let station = nearestStations[indexPath.row]
        
        return UINavigationController(rootViewController: DeparturesViewController(station: station))
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        guard let departuresViewController = (viewControllerToCommit as! UINavigationController).visibleViewController else { return }
        
        navigationController?.pushViewController(departuresViewController, animated: true)
    }
    
    
    // MARK: stations stuff
    
    @objc func refresh() {
        self.locationManager.startUpdatingLocation()
    }
    
    func updateDeparturesForLocation(_ location: CLLocation) {
        mvgClient.getNearbyStations(atLocation: location) { error, stations in
            if let error = error {
                self.showError("Error", error.localizedDescription)
                return;
            }
            
            guard !stations.isEmpty else {
                let alert = UIAlertController(title: "No stations found", message: "We were unable to find any nearby stations. Please keep in mind that this app only works in Munich", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default) { _ in
                    self.refresh()
                })
                self.present(alert, animated: true)
                return
            }
            
            self.nearestStations = stations.sorted { $0.distance ?? 0 < $1.distance ?? 0 }
            self.tableView.refreshControl?.endRefreshing()
        }
    }
    
    func showDepartures(for station: Station, animated: Bool = true) {
        SpringBoardShortcutManager.add(station: station)
        
        let vc = DeparturesViewController(station: station)
        navigationController?.pushViewController(vc, animated: animated)
    }
    
    // MARK: Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearestStations.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let station = nearestStations[indexPath.row]
        
        cell.textLabel?.text = station.name
        if let distance = station.distance {
            cell.detailTextLabel?.text = "\(distance) m"
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDepartures(for: nearestStations[indexPath.row])
    }
    
    
    // MARK: Location Manager Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        currentLocation = location
        
        manager.stopUpdatingLocation()
    }
}

