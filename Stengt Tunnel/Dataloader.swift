//
//  Dataloader.swift
//  Stengt Tunnel
//
//  Created by Ole-Kenneth on 24/08/2023.
//

import Foundation

class Dataloader {
    static var shared = Dataloader()
    let jsonDecoder = JSONDecoder()
    let formatter = ISO8601DateFormatter()

    init() {
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        jsonDecoder.dateDecodingStrategy = .custom({ decoder in
            let container = try decoder.singleValueContainer()
            let dateStr = try container.decode(String.self)
            
            if let date = self.formatter.date(from: dateStr) {
                return date
            }
            
            return Date.now
        })
    }
    
    public func loadRoad(road: String, completion:@escaping (_ status: Status) -> ()) {
        loadData(url: URL(string: "https://api.stengttunnel.no/" + road + "/v2")!, type: Status.self) { status in
            completion(status)
        }
    }
    
    public func loadRoads(completion:@escaping (_ result: [String: Road]) -> ()) {
        loadData(url: URL(string: "https://api.stengttunnel.no/v2")!, type: [String: Road].self) { result in
            completion(result)
        }
    }
    
    private func loadData<T>(url: URL, type: T.Type, completion:@escaping (_ result: T) -> ()) where T : Decodable {
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, resp, error in
            
            if let data = data {
                if let response = try? self.jsonDecoder.decode(type, from: data) {
                    DispatchQueue.main.async {
                        completion(response)
                    }
                } else {
                    do {
                        let _ = try self.jsonDecoder.decode(type, from: data)
                    } catch {
                        print(error)
                    }
                    print("Unable to decode JSON")
                }
            }
        }.resume()
    }
    
}
