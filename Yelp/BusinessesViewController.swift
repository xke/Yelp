//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {

    var businesses: [Business]!
    var searchBar: UISearchBar!

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension // based on autolayout
        tableView.estimatedRowHeight = 120 // for scroll bar
        
        showDefaultBusinessList()
        
        // add search bar to navigation bar
        searchBar = UISearchBar()
        searchBar.delegate = self
        
        searchBar.sizeToFit()
        navigationItem.titleView = searchBar
        
        searchBar.placeholder = "Restaurants"
    }
    
    private func showDefaultBusinessList() {
        // default is to search everything!
        
        Business.searchWithTerm("", sort: nil, categories: nil, deals: nil, radius: nil) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()

        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if businesses != nil {
            return businesses!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BusinessCell", forIndexPath: indexPath) as! BusinessCell
        
        let business = businesses[indexPath.row]
        /*
        print(business.name!)
        print(business.address!)
        print(business.imageURL!)
        print("----")
        */
        cell.business = business

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let navigationController = segue.destinationViewController as! UINavigationController
        let filtersViewController = navigationController.topViewController as! FiltersViewController
        filtersViewController.delegate = self
        
    }
    
    func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        
        let categories = filters["categories"] as? [String]
        let deals = filters["deals"] as? Bool
        let sort = filters["sort"] as? Int
        let radius = filters["radius"] as? Int
        
        print("BusinessesViewController filtersViewController sort=\(sort)")

        Business.searchWithTerm("Restaurants", sort: sort, categories: categories, deals: deals, radius: radius) { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            self.tableView.reloadData()
        }
    }
    
    
}

extension BusinessesViewController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true;
    }
    
    func searchBarShouldEndEditing(searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(false, animated: true)
        return true;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        showDefaultBusinessList()
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        // search and reload table
        
        print("Search: " + searchBar.text!)
        
        Business.searchWithTerm(searchBar.text!) { (businesses: [Business]!, error: NSError!) -> Void in

            self.businesses = businesses
            self.tableView.reloadData()
            
            for business in businesses {
                print(business.name!)
            }
        }
    
    }

}
