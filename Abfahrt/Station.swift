//
//  Station.swift
//  Abfahrt
//
//  Created by Lukas Kollmer on 17.06.17.
//  Copyright © 2017 Lukas Kollmer. All rights reserved.
//

import Foundation
import SwiftyJSON

public enum Line {
    case bus(Int)
    case nachtbus(Int)
    
    case tram(Int)
    case nachttram(Int)
    
    case ubahn(Int)
    case sbahn(Int)
    
    case other(Int)
}

public enum Service: CustomStringConvertible {
    case bus, tram, ubahn, sbahn, fähre, other
    
    private static let mapping: [String: Service] = [
        "Bus": .bus,
        "U-Bahn": .ubahn,
        "S-Bahn": .sbahn,
        "Tram": .tram,
        "Fähre": .fähre,
        "z": .other
    ]
    
    private static var apiMapping: [String: Service] = {
        return Dictionary(uniqueKeysWithValues: Service.mapping.map { ($0.replacingOccurrences(of: "-", with: "").uppercased(), $1) })
        
    }()
    
    init(_ string: String) {
        self = Service.apiMapping[string]!
    }
    
    public var description: String {
        guard self != .other else { return "Other" }
        return Service.mapping.key(forValue: self)!
    }
}


// TODO make decodable

public struct Station: Hashable {
    public var hashValue: Int { return self.id }
    
    
    public let name: String
    public let id: Int
    
    public let type: String
    
    public let place: String
    
    public let hasZoomData: Bool
    public let hasLiveData: Bool
    
    public let latitude: Float
    public let longitude: Float
    
    public let lines: [Line]
    
    public let services: [Service]
    
    public let json: JSON
    
    /// Distance from the search location
    public let distance: Int?
    
    
    init?(json: JSON) {
        guard
            let name = json["name"].string,
            let id   = json["id"].int,
            let type   = json["type"].string,
            let hasLiveData = json["hasLiveData"].bool,
            let hasZoomData = json["hasZoomData"].bool,
            let latitude = json["latitude"].float,
            let longitude = json["longitude"].float,
            let place = json["place"].string,
            let lines = json["lines"].dictionary,
            let products = json["products"].array
            else { return nil }
        
        self.json = json
        
        self.name = name
        self.id = id
        self.type = type
        self.hasLiveData = hasLiveData
        self.hasZoomData = hasZoomData
        self.latitude = latitude
        self.longitude = longitude
        self.place = place
        self.services = products.map { Service($0.stringValue) }.filter { $0 != .other }
        
        self.distance = json["distance"].int
        
        
        
        var parsedLines = [Line]()
        
        
        for (key, value) in lines {
            let lineNumbers = value.arrayValue.map { $0.intValue }
            
            for lineNumber in lineNumbers {
                let newLine = { () -> Line? in
                    switch key {
                    case "bus":
                        return .bus(lineNumber)
                    case "nachtbus":
                        return .nachtbus(lineNumber)
                        
                    case "tram":
                        return .tram(lineNumber)
                    case "nachttram":
                        return .nachttram(lineNumber)
                        
                    case "ubahn":
                        return .ubahn(lineNumber)
                    case "sbahn":
                        return .sbahn(lineNumber)
                        
                    case "otherlines":
                        return .other(lineNumber)
                    default: return nil
                    }
                }()
                
                if let newLine = newLine {
                    parsedLines.append(newLine)
                }
            }
            
            
        }
        
        self.lines = parsedLines
    }
}

public func ==(lhs: Station, rhs: Station) -> Bool {
    return lhs.id == rhs.id
}
