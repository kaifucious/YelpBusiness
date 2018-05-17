//
//  PastQueriesTableViewController.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit
import RealmSwift

class PastQueriesTableViewController: UITableViewController
{
    private var pastQueries: [DatabasePastQuery] = []
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        self.pastQueries = Database.fetchPastQueries()
    }

    // MARK: - UITableViewDelegate/DataSource
    override func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.pastQueries.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PastQueryCell",
                                                 for: indexPath) as? PastQueriesTableViewCell ?? PastQueriesTableViewCell()

        let pastQuery = self.pastQueries[indexPath.row]
        
        cell.configure(pastQuery: pastQuery)

        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 80.0
    }
}
