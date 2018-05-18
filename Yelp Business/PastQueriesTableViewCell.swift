//
//  PastQueriesTableViewCell.swift
//  Yelp Business
//
//  Created by Ghost Maverick on 5/16/18.
//  Copyright © 2018 Developer. All rights reserved.
//

import UIKit

class PastQueriesTableViewCell: UITableViewCell
{
    @IBOutlet private weak var pastQueryLabel: Label!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
    }

    func configure<T: Configurable>(pastQuery: T)
    {
        guard let pastQuery = pastQuery as? DatabasePastQuery else { return }
        
        self.pastQueryLabel.text = pastQuery.queryText
    }
}
