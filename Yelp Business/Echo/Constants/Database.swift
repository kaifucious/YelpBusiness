//
//  Database.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import Foundation
import RealmSwift
import CDYelpFusionKit

class Database: Observable
{
    private var realm: Realm!
    private var model: DatabaseModel!

    init()
    {
        do {
            self.realm = try Realm()
            
            if let existingDatabaseModel = self.realm.objects(DatabaseModel.self).first {
                self.model = existingDatabaseModel
            }
            else {
                self.model = DatabaseModel()
                
                try self.realm.write {
                    self.realm.add(self.model)
                }
            }
            
            self.startObserving()
        }
        catch let error {
            Echo.log(message: "Unable to create database: \(error.localizedDescription)")
        }
    }
    
    // MARK: -Echo Handler
    func handle(intendedObserverNames: [String], dispatcher: Dispatchable, object: EchoObject)
    {
        guard intendedObserverNames.contains(self.name),
              let databaseObject = object as? DatabaseObject else { return }
        
        switch databaseObject
        {
            case .databaseSaveBusinesses(let query, let businesses):
                let error = self.saveBusinesses(query: query, businesses: businesses)
            
                if error != nil {
                    print(error!.localizedDescription)
                }
        }
    }
    
    private func saveBusinesses(query: String, businesses: [CDYelpBusiness]) -> Error?
    {
        do {
            try self.realm.write {
                let objectModel = DatabaseModel()
                objectModel.db_primary_key = query
                
                var businessJSONArray: [[String: Any]] = []
                
                for business in businesses {
                    var businessJSON: [String: Any] = [:]
                    businessJSON["name"] = business.name ?? ""
                    businessJSON["phone"] = business.phone ?? ""
                    businessJSON["rating"] = business.rating ?? 0.0
                    
                    let categories = business.categories?.flatMap { $0.alias } ?? []
                    businessJSON["categories"] = categories
                    
                    businessJSONArray.append(businessJSON)
                }
                
                if let jsonData = try? JSONSerialization.data(withJSONObject: businessJSONArray, options: []),
                    let jsonString = String(data: jsonData, encoding: .utf8) {

                    objectModel.db_business_query_results = jsonString
                }
                
                self.realm.add(objectModel, update: true)
            }
        } catch let error {
            return error
        }
        
        return nil 
    }
    
    static func fetchPastQuery(queryString: String) -> DatabasePastQuery?
    {
        guard let database = Echo.observers[Database.name] as? Database else { return nil }
        
        let databaseModel = database.realm.objects(DatabaseModel.self).filter("db_primary_key = '\(queryString)'").first
        
        if let databaseModel = databaseModel {
            if let businessData = databaseModel.db_business_query_results.data(using: .utf8),
                databaseModel.db_primary_key.isEmpty == false {
                
                var pastQuery = DatabasePastQuery()
                pastQuery.queryText = databaseModel.db_primary_key
                
                do {
                    let jsonBusiness = try JSONSerialization.jsonObject(with: businessData,
                                                                          options: []) as? [[String: Any]]
                    
                    if let jsonBusiness = jsonBusiness {
                        for business in jsonBusiness {
                            let name = business["name"] as? String ?? ""
                            let phone = business["phone"] as? String ?? ""
                            let rating = business["rating"] as? Double ?? 0.0
                            let categories = business["categories"] as? [String] ?? []
                            
                            let yelpBusiness = YelpBusiness(name: name,
                                                            phone: phone,
                                                            rating: rating,
                                                            categories: categories)
                            
                            pastQuery.businesses.append(yelpBusiness)
                        }
                    }
                    
                    return pastQuery
                } catch { }
            }
        }
        
        return nil
    }
    
    static func fetchPastQueries() -> [DatabasePastQuery]
    {
        guard let database = Echo.observers[Database.name] as? Database else { return [] }
        
        let databaseModels = database.realm.objects(DatabaseModel.self)
        var pastQueries = [DatabasePastQuery]()
    
        for dataseModel in databaseModels {
            if let businessesData = dataseModel.db_business_query_results.data(using: .utf8),
                dataseModel.db_primary_key.isEmpty == false {
                
                var pastQuery = DatabasePastQuery()
                pastQuery.queryText = dataseModel.db_primary_key
                
                do {
                    let jsonBusinesses = try JSONSerialization.jsonObject(with: businessesData,
                                                                          options: []) as? [[String: Any]]
                   
                    if let businesses = jsonBusinesses {
                        for business in businesses {
                            let name = business["name"] as? String ?? ""
                            let phone = business["phone"] as? String ?? ""
                            let rating = business["rating"] as? Double ?? 0.0
                            let categories = business["categories"] as? [String] ?? []
                            
                            let yelpBusiness = YelpBusiness(name: name,
                                                            phone: phone,
                                                            rating: rating,
                                                            categories: categories)
                            
                            pastQuery.businesses.append(yelpBusiness)
                        }
                        
                        pastQueries.append(pastQuery)
                    }
                } catch { }
            }
        }
        
        return pastQueries
    }
    
    deinit
    {
        self.realm = nil
    }
}

