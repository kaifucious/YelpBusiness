//
//  ViewController.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/14/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import CDYelpFusionKit
import CoreLocation
import SVProgressHUD
import RealmSwift
import MapKit

class QueryViewController: EchoViewController
{
    private let locationManager = CLLocationManager()
    private var locationCoordinate: CLLocationCoordinate2D?
    
    private var isLoadingBusinesses: Bool = false
    private var isOfflineMode: Bool = false
    private var queriedBusinesses: [CDYelpBusiness] = []
    private var offlinePastQuery: DatabasePastQuery?
    private var queryText: String = ""
    private var queryOffset: Int = 0
    private let queryLimit: Int = 20
    
    private struct LayoutConstants {
        static let collectionViewCellWidth: CGFloat = 180.0
        static let collectionViewCellHeight: CGFloat = 200.0
        static let collectionViewCellSpaciing: CGFloat = 8.0
    }
    
    @IBOutlet weak var headerView: View!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        self.setUI()
        self.startObserving()
    }
    
    // MARK: -Echo Handler
    override func handle(intendedObserverNames: [String], dispatcher: Dispatchable, object: EchoObject)
    {
        guard intendedObserverNames.contains(self.name) else { return }

        switch dispatcher.name {
            case Network.name:
                guard let networkObject = object as? NetworkObject else { return }
            
                switch networkObject {
                    case .networkStatusUpdated(let networkConnected):
                        if networkConnected {
                            UIView.animate(withDuration: 0.3) {
                                self.headerView.backgroundColor = .white
                            }
                            
                            self.isOfflineMode = false
                            self.updateLocation()
                        } else {
                            UIView.animate(withDuration: 0.3) {
                                self.headerView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                            }
                            
                            self.isOfflineMode = true 
                        }
                }
            
            default: break 
        }
    }
    
    // MARK: -Set UI
    private func setUI()
    {
        for subView in self.searchBar.subviews {
            for subsubView in subView.subviews {
                if let textField = subsubView as? UITextField {
                    let font = UIFont(name: AppDelegate.Default.fontName, size: 14.0)
                    
                    let attributes: [NSAttributedStringKey: Any] = [.foregroundColor: UIColor.lightGray]
                    
                    let attributedPlaceholder = NSAttributedString(string: "Search...",
                                                                   attributes: attributes)
                    
                    textField.font = font
                    textField.attributedPlaceholder = attributedPlaceholder
                    textField.layer.cornerRadius = 8.0
                    
                    if let backgroundView = textField.subviews.first {
                        backgroundView.clipsToBounds = true
                        backgroundView.layer.cornerRadius = 20
                    }
                }
            }
        }
        
        self.navigationItem.titleView = self.searchBar
    }
    
    // MARK: -CLLocationManager Handling
    private func updateLocation()
    {
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        self.locationManager.startUpdatingLocation()
    }
    
    // MARK: -Querying
    private func query(withCoordinate coordinate: CLLocationCoordinate2D,
                       shouldReloadCollectionView: Bool = true)
    {
        guard self.isLoadingBusinesses != true else { return }

        guard let yelpClient = AppDelegate.shared.yelpClient,
              let text = self.searchBar.text,
              text.isEmpty == false else {
                self.displayAlert(on: self,
                                  title: "An Error Occured",
                                  message: "Please enter some text in the search bar",
                                  isEditable: false,
                                  editHandler: nil,
                                  completion: nil)
                
                return
        }
        
        self.queryText = text
        self.isLoadingBusinesses = true
        
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            
            if shouldReloadCollectionView {
                self.queryOffset = 0
                self.queriedBusinesses.removeAll()
                self.collectionView.reloadData()
            }
            
            SVProgressHUD.setForegroundColor(AppDelegate.Default.color)
            SVProgressHUD.show()
        }
        
        yelpClient.cancelAllPendingAPIRequests()

        yelpClient.searchBusinesses(byTerm: self.queryText,
                                    location: nil,
                                    latitude: coordinate.latitude,
                                    longitude: coordinate.longitude,
                                    radius: nil,
                                    categories: nil,
                                    locale: nil,
                                    limit: self.queryLimit,
                                    offset: self.queryOffset,
                                    sortBy: nil,
                                    priceTiers: nil,
                                    openNow: nil,
                                    openAt: nil,
                                    attributes: nil) { response in
                  
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    self.view.isUserInteractionEnabled = true
                    self.isLoadingBusinesses = false
                }
                                        
                guard let response = response,
                      let businesses = response.businesses else {
                        self.displayAlert(on: self,
                                          title: "An Error Occured",
                                          message: "An error occured while fetching the data",
                                          isEditable: false,
                                          editHandler: nil,
                                          completion: nil)
                        return
                }

                self.queriedBusinesses.append(contentsOf: businesses)
                                        
                // Emit to let the database know to save the fetched results
                // To save space, only save the first `x` businesses, where `x` is the query limit (0-20)
                if self.queryOffset == 0 {
                    let databaseObject: DatabaseObject = .databaseSaveBusinesses(self.queryText, businesses)
                    databaseObject.emit(intendedObserverNames: [Database.name], dispatcher: self)
                }
                
                self.queryOffset += self.queriedBusinesses.count
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
        }
    }
    
    // MARK: -IBActions
    @IBAction private func navigateBack(_ sender: AnyObject)
    {
        self.displayAlert(on: self, title: "Hurray!", message: "This would normally go back to the previous navigation screen.")
    }
    
    @IBAction private func filterSearchBar(_ sender: AnyObject)
    {
        guard CLLocationManager.locationServicesEnabled() else {
                
            self.displayAlert(on: self,
                              title: "An Error Occured",
                              message: "You must turn on Location Services to be able to search for nearby businesses",
                              isEditable: false,
                              editHandler: nil) {
                                
                if let urlGeneral = URL(string: UIApplicationOpenSettingsURLString) {
                    UIApplication.shared.open(urlGeneral)
                }
            }
            return
        }
        
        if self.isOfflineMode == true,
            let queryString = self.searchBar.text,
            let pastQuery = Database.fetchPastQuery(queryString: queryString) {
            
            // If we are offline, try and find/load the entered search query
            self.offlinePastQuery = pastQuery
            self.collectionView.reloadData()
        } else {
            // We are online. Yay us.
            if let coordinate = self.locationCoordinate {
                self.query(withCoordinate: coordinate)
            }
        }
    }
}

extension QueryViewController: CLLocationManagerDelegate
{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation])
    {
        self.locationManager.stopUpdatingLocation()
        self.locationCoordinate = locations.last?.coordinate
    }
}

extension QueryViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if self.isOfflineMode, let pastQuery = self.offlinePastQuery {
            return pastQuery.businesses.count
        } else {
            return self.queriedBusinesses.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QueryCell",
                                                for: indexPath) as? QueryCollectionViewCell ?? QueryCollectionViewCell()
        
        cell.businessLocationTapped = { name, latitude, longitude in
            let location = CLLocationCoordinate2DMake(latitude, longitude)
            let span = MKCoordinateRegionMakeWithDistance(location, 10000,  10000)
            
            let options = [
                MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: location),
                MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: span.span)
            ]
            
            let placemark = MKPlacemark(coordinate: location, addressDictionary: nil)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = name
            mapItem.openInMaps(launchOptions: options)
        }
        
        cell.businessPhoneTapped = { phoneNumber in
            guard let number = URL(string: "tel://\(phoneNumber)") else { return }
            
            UIApplication.shared.open(number, options: [:], completionHandler: nil)
        }
        
        if self.isOfflineMode {
            if let pastQuery = self.offlinePastQuery {
                let business = pastQuery.businesses[indexPath.row]
                cell.configure(business: business)
            }
        } else {
            let business = self.queriedBusinesses[indexPath.row]
            cell.configure(business: business)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        
        return CGSize(width: LayoutConstants.collectionViewCellWidth,
                      height: LayoutConstants.collectionViewCellHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard let coord = self.locationCoordinate,
              self.isLoadingBusinesses == false else { return }
        
        let scrollPoint = self.collectionView.contentSize.height - self.collectionView.frame.size.height
        
        // If the table reaches the end, load more businesses
        if self.collectionView.contentOffset.y >= scrollPoint
        {
            self.query(withCoordinate: coord, shouldReloadCollectionView: false)
        }
    }
}
