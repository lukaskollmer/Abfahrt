//
//  API.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 16.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import Foundation
import CoreLocation

import Alamofire
import SwiftyJSON

struct API {
    fileprivate struct Credentials {
        fileprivate static let Key = "5af1beca494712ed38d313714d4caff6"
        fileprivate static let AuthHeader: HTTPHeaders = ["X-MVG-Authorization-Key": Credentials.Key]
    }
    
    fileprivate enum Endpoint : String {
        case queryStationById = "https://www.mvg.de/fahrinfo/api/location/query"
        case queryStationsByName = "https://www.mvg.de/fahrinfo/api/location/queryWeb"
        
        case getNearbyStations = "https://www.mvg.de/fahrinfo/api/location/nearby"
        
        case departure = "https://www.mvg.de/fahrinfo/api/departure/"
    }
    
    static let `default` = API()
    
    static var isAvailable: Bool {
        return NetworkReachabilityManager()!.isReachable
    }
    
    
    fileprivate func makeRequest(_ endpoint: Endpoint, _ parameters: Parameters, responseHandler: @escaping (Error?, JSON?) -> ()) throws {
        var url = endpoint.rawValue
        var params = parameters
        
        if endpoint == .departure {
            guard let id = params["id"] as? Int else { throw NSError() } // todo throw real error
            url += String(id)
            
            params.removeValue(forKey: "id")
        }
        
        Alamofire.request(url, parameters: params, headers: Credentials.AuthHeader).responseData { response in
            guard let data = response.data else { responseHandler(response.error, nil); return }
            
            responseHandler(response.error, JSON(data: data))
        }
    }
    
    
    
    func getAllStations(handler: @escaping (Error?, [Station]?) -> ()) {
        // Querying by name, but passing an empty string will return all stations
        
        try! makeRequest(.queryStationsByName, ["q" : ""]) { error, response in
            
            guard let locations = response?["locations"].array else {
                handler(error, nil)
                return
            }
            var stations = [Station]()
            
            for stationInfo in locations {
                if let station = Station(json: stationInfo) {
                    stations.append(station)
                    print(station.id, station.type, station.name)
                }
            }
            
            print("found \(stations.count) stations") // TODO call handler
        }
    }
    
    
    
    func getNearbyStations(atLocation location: CLLocation, _ handler: @escaping (Error?, [Station]) -> Void) {
        
        let parameters: Parameters = [
            "latitude" : location.coordinate.latitude,
            "longitude" : location.coordinate.longitude
        ]
        
        try! makeRequest(.getNearbyStations, parameters) { error, json in
            guard let json = json else { handler(error, []); return; }
            
            var stations = [Station]()
            
            for (_, location) in json["locations"] {
                if let station = Station(json: location) {
                    stations.append(station)
                }
            }
            
            handler(error, stations)
        }
    }
    
    
    func getDepartures(forStation station: Station, handler: @escaping (Error?, [Departure]?) -> ()) {
        let params: Parameters = [
            "id" : station.id,
            "footway" : 0
        ]
        
        var departures = [Departure]()
        
        try! makeRequest(.departure, params) { error, json in
            guard let departuresJSON = json?["departures"].array else {
                handler(error, nil)
                return
            }
            
            for departure in departuresJSON {
                departures.append(Departure(json: departure, station: station))
            }
            
            handler(error, departures)
        }
    }
}
