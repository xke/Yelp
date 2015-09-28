//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Xian on 9/26/15.
//  Copyright © 2015. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    optional func filtersViewController(filtersViewController: FiltersViewController, didUpdateFilters filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {

    @IBOutlet weak var tableView: UITableView!
    weak var delegate: FiltersViewControllerDelegate?

    
    let SwitchCellIdentifier = "SwitchCell"
    let HeaderViewIdentifier = "FiltersHeaderCell"
    let DropDownCellIdentifier = "DropDownCell"

    // Filter Sections and Configurations
    
    let FiltersSectionHeaders = ["", "Distance", "Sort By", "Category"]
    
    let SectionDeals = 0
    let DealSwitchText = "Offering a Deal"
    var dealSwitchState = false
    
    let SectionDistance = 1
    let distanceOptions = [["Best Match", 0], ["1 block (0.2 km)", 200], ["10 blocks (2 km)", 2000],
                           ["3.1 miles (5 km)", 5000], ["6.2 miles (10 km)", 10000]]  // value is in meters
    var selectedDistanceRow = 0
    var distanceDropDownExpanded = true // drop down dynamic expansion not implemented; always expanded
    
    let SectionSortBy = 2
    var sortByOptions = ["Best Match", "Distance", "Highest Rated"]
    var selectedSortByRow = 0 // matches with what Yelp API expects for "sort"
    var sortByDropDownExpanded = true // drop down dynamic expansion not implemented; always expanded

    
    let SectionCategory = 3
    var categories: [[String:String]]! // filled in later
    var categorySwitchStates = [Int:Bool]()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        categories = yelpCategories()
        
        tableView.delegate = self
        tableView.dataSource = self

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func onCancelButton(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // clicked search button in Filters vie
    @IBAction func onSearchButton(sender: AnyObject) {

        var filters = [String : AnyObject]()
        
        filters["deals"] = dealSwitchState
        filters["sort"] = selectedSortByRow 
        filters["radius"] = distanceOptions[selectedDistanceRow][1] // meters!
        
        var selectedCategories = [String]()
        
        for (row, isSelected) in categorySwitchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
                
            }
        }
        
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories
        }
        
        print("Filters set up: deals=\(dealSwitchState), sort=\(selectedSortByRow), categories=\(selectedCategories), radius=\(distanceOptions[selectedDistanceRow][1])")
        
        delegate?.filtersViewController?(self, didUpdateFilters: filters)

        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // table set up
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return FiltersSectionHeaders.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case SectionDeals:
                return 1
            case SectionDistance:
                return distanceDropDownExpanded ? distanceOptions.count : 1
            case SectionSortBy:
                return sortByDropDownExpanded ? sortByOptions.count : 1
            case SectionCategory:
                return categories.count
            default:
                NSLog("DOH! Unexpected indexPath.section \(section) in tableView numberOfRowsInSection. :(")
                return 1
        }

    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            
            case SectionDeals:
                let cell = tableView.dequeueReusableCellWithIdentifier(SwitchCellIdentifier, forIndexPath: indexPath) as! SwitchCell
                cell.switchLabel.text = DealSwitchText
                cell.delegate = self
                cell.onSwitch.on = dealSwitchState
                return cell
            
            case SectionDistance:
                let cell = tableView.dequeueReusableCellWithIdentifier(DropDownCellIdentifier, forIndexPath: indexPath) as! DropDownCell
                cell.optionLabel.text = distanceOptions[indexPath.row][0] as? String
                if indexPath.row == selectedDistanceRow {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
                return cell
            
            
            case SectionSortBy:
                let cell = tableView.dequeueReusableCellWithIdentifier(DropDownCellIdentifier, forIndexPath: indexPath) as! DropDownCell
                cell.optionLabel.text = sortByOptions[indexPath.row]
                if indexPath.row == selectedSortByRow {
                    cell.accessoryType = .Checkmark
                } else {
                    cell.accessoryType = .None
                }
                return cell

            
            case SectionCategory:
                let cell = tableView.dequeueReusableCellWithIdentifier(SwitchCellIdentifier, forIndexPath: indexPath) as! SwitchCell
                cell.switchLabel.text = categories[indexPath.row]["name"]
                cell.delegate = self
                cell.onSwitch.on = categorySwitchStates[indexPath.row] ?? false // shortcut
                /*if categorySwitchStates[indexPath.row] != nil {
                cell.onSwitch.on = categorySwitchStates[indexPath.row]!
                } else {
                cell.onSwitch.on = false
                }*/
                return cell
            

            default:
                NSLog("DOH! Unexpected indexPath.section \(indexPath.section) in tableView cellForRowAtIndexPath. :(")
                return UITableViewCell()
            
        }
        
        
    }

    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCellWithIdentifier(HeaderViewIdentifier) as! FiltersHeaderCell
        header.titleLabel.text = FiltersSectionHeaders[section]
        return header
        
        
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
            
            case SectionDistance:
                selectedDistanceRow = indexPath.row
                print("selectedDistanceRow to \(selectedDistanceRow)")
                tableView.reloadData()
            
            case SectionSortBy:
                selectedSortByRow = indexPath.row
                print("selectedSortByRow to \(selectedSortByRow)")
                tableView.reloadData()
            
            default:
                return
            
        }
        
    }

    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPathForCell(switchCell)!
        
        switch(indexPath.section) {
            
            case SectionDeals:
                dealSwitchState = value
                print("FiltersViewController switchCell: dealSwitchState changed to \(dealSwitchState)")
            
            case SectionCategory:
                categorySwitchStates[indexPath.row] = value
                print("FiltersViewController switchCell: category row \(indexPath.row) changed to \(value)")

            default:
                return
        }

        
    }
    
    func yelpCategories() -> [[String:String]] {

        return [["name" : "Afghan", "code": "afghani"],
            ["name" : "African", "code": "african"],
            ["name" : "American, New", "code": "newamerican"],
            ["name" : "American, Traditional", "code": "tradamerican"],
            ["name" : "Arabian", "code": "arabian"],
            ["name" : "Argentine", "code": "argentine"],
            ["name" : "Armenian", "code": "armenian"],
            ["name" : "Asian Fusion", "code": "asianfusion"],
            ["name" : "Asturian", "code": "asturian"],
            ["name" : "Australian", "code": "australian"],
            ["name" : "Austrian", "code": "austrian"],
            ["name" : "Baguettes", "code": "baguettes"],
            ["name" : "Bangladeshi", "code": "bangladeshi"],
            ["name" : "Barbeque", "code": "bbq"],
            ["name" : "Basque", "code": "basque"],
            ["name" : "Bavarian", "code": "bavarian"],
            ["name" : "Beer Garden", "code": "beergarden"],
            ["name" : "Beer Hall", "code": "beerhall"],
            ["name" : "Beisl", "code": "beisl"],
            ["name" : "Belgian", "code": "belgian"],
            ["name" : "Bistros", "code": "bistros"],
            ["name" : "Black Sea", "code": "blacksea"],
            ["name" : "Brasseries", "code": "brasseries"],
            ["name" : "Brazilian", "code": "brazilian"],
            ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
            ["name" : "British", "code": "british"],
            ["name" : "Buffets", "code": "buffets"],
            ["name" : "Bulgarian", "code": "bulgarian"],
            ["name" : "Burgers", "code": "burgers"],
            ["name" : "Burmese", "code": "burmese"],
            ["name" : "Cafes", "code": "cafes"],
            ["name" : "Cafeteria", "code": "cafeteria"],
            ["name" : "Cajun/Creole", "code": "cajun"],
            ["name" : "Cambodian", "code": "cambodian"],
            ["name" : "Canadian", "code": "New)"],
            ["name" : "Canteen", "code": "canteen"],
            ["name" : "Caribbean", "code": "caribbean"],
            ["name" : "Catalan", "code": "catalan"],
            ["name" : "Chech", "code": "chech"],
            ["name" : "Cheesesteaks", "code": "cheesesteaks"],
            ["name" : "Chicken Shop", "code": "chickenshop"],
            ["name" : "Chicken Wings", "code": "chicken_wings"],
            ["name" : "Chilean", "code": "chilean"],
            ["name" : "Chinese", "code": "chinese"],
            ["name" : "Comfort Food", "code": "comfortfood"],
            ["name" : "Corsican", "code": "corsican"],
            ["name" : "Creperies", "code": "creperies"],
            ["name" : "Cuban", "code": "cuban"],
            ["name" : "Curry Sausage", "code": "currysausage"],
            ["name" : "Cypriot", "code": "cypriot"],
            ["name" : "Czech", "code": "czech"],
            ["name" : "Czech/Slovakian", "code": "czechslovakian"],
            ["name" : "Danish", "code": "danish"],
            ["name" : "Delis", "code": "delis"],
            ["name" : "Diners", "code": "diners"],
            ["name" : "Dumplings", "code": "dumplings"],
            ["name" : "Eastern European", "code": "eastern_european"],
            ["name" : "Ethiopian", "code": "ethiopian"],
            ["name" : "Fast Food", "code": "hotdogs"],
            ["name" : "Filipino", "code": "filipino"],
            ["name" : "Fish & Chips", "code": "fishnchips"],
            ["name" : "Fondue", "code": "fondue"],
            ["name" : "Food Court", "code": "food_court"],
            ["name" : "Food Stands", "code": "foodstands"],
            ["name" : "French", "code": "french"],
            ["name" : "French Southwest", "code": "sud_ouest"],
            ["name" : "Galician", "code": "galician"],
            ["name" : "Gastropubs", "code": "gastropubs"],
            ["name" : "Georgian", "code": "georgian"],
            ["name" : "German", "code": "german"],
            ["name" : "Giblets", "code": "giblets"],
            ["name" : "Gluten-Free", "code": "gluten_free"],
            ["name" : "Greek", "code": "greek"],
            ["name" : "Halal", "code": "halal"],
            ["name" : "Hawaiian", "code": "hawaiian"],
            ["name" : "Heuriger", "code": "heuriger"],
            ["name" : "Himalayan/Nepalese", "code": "himalayan"],
            ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
            ["name" : "Hot Dogs", "code": "hotdog"],
            ["name" : "Hot Pot", "code": "hotpot"],
            ["name" : "Hungarian", "code": "hungarian"],
            ["name" : "Iberian", "code": "iberian"],
            ["name" : "Indian", "code": "indpak"],
            ["name" : "Indonesian", "code": "indonesian"],
            ["name" : "International", "code": "international"],
            ["name" : "Irish", "code": "irish"],
            ["name" : "Island Pub", "code": "island_pub"],
            ["name" : "Israeli", "code": "israeli"],
            ["name" : "Italian", "code": "italian"],
            ["name" : "Japanese", "code": "japanese"],
            ["name" : "Jewish", "code": "jewish"],
            ["name" : "Kebab", "code": "kebab"],
            ["name" : "Korean", "code": "korean"],
            ["name" : "Kosher", "code": "kosher"],
            ["name" : "Kurdish", "code": "kurdish"],
            ["name" : "Laos", "code": "laos"],
            ["name" : "Laotian", "code": "laotian"],
            ["name" : "Latin American", "code": "latin"],
            ["name" : "Live/Raw Food", "code": "raw_food"],
            ["name" : "Lyonnais", "code": "lyonnais"],
            ["name" : "Malaysian", "code": "malaysian"],
            ["name" : "Meatballs", "code": "meatballs"],
            ["name" : "Mediterranean", "code": "mediterranean"],
            ["name" : "Mexican", "code": "mexican"],
            ["name" : "Middle Eastern", "code": "mideastern"],
            ["name" : "Milk Bars", "code": "milkbars"],
            ["name" : "Modern Australian", "code": "modern_australian"],
            ["name" : "Modern European", "code": "modern_european"],
            ["name" : "Mongolian", "code": "mongolian"],
            ["name" : "Moroccan", "code": "moroccan"],
            ["name" : "New Zealand", "code": "newzealand"],
            ["name" : "Night Food", "code": "nightfood"],
            ["name" : "Norcinerie", "code": "norcinerie"],
            ["name" : "Open Sandwiches", "code": "opensandwiches"],
            ["name" : "Oriental", "code": "oriental"],
            ["name" : "Pakistani", "code": "pakistani"],
            ["name" : "Parent Cafes", "code": "eltern_cafes"],
            ["name" : "Parma", "code": "parma"],
            ["name" : "Persian/Iranian", "code": "persian"],
            ["name" : "Peruvian", "code": "peruvian"],
            ["name" : "Pita", "code": "pita"],
            ["name" : "Pizza", "code": "pizza"],
            ["name" : "Polish", "code": "polish"],
            ["name" : "Portuguese", "code": "portuguese"],
            ["name" : "Potatoes", "code": "potatoes"],
            ["name" : "Poutineries", "code": "poutineries"],
            ["name" : "Pub Food", "code": "pubfood"],
            ["name" : "Rice", "code": "riceshop"],
            ["name" : "Romanian", "code": "romanian"],
            ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
            ["name" : "Rumanian", "code": "rumanian"],
            ["name" : "Russian", "code": "russian"],
            ["name" : "Salad", "code": "salad"],
            ["name" : "Sandwiches", "code": "sandwiches"],
            ["name" : "Scandinavian", "code": "scandinavian"],
            ["name" : "Scottish", "code": "scottish"],
            ["name" : "Seafood", "code": "seafood"],
            ["name" : "Serbo Croatian", "code": "serbocroatian"],
            ["name" : "Signature Cuisine", "code": "signature_cuisine"],
            ["name" : "Singaporean", "code": "singaporean"],
            ["name" : "Slovakian", "code": "slovakian"],
            ["name" : "Soul Food", "code": "soulfood"],
            ["name" : "Soup", "code": "soup"],
            ["name" : "Southern", "code": "southern"],
            ["name" : "Spanish", "code": "spanish"],
            ["name" : "Steakhouses", "code": "steak"],
            ["name" : "Sushi Bars", "code": "sushi"],
            ["name" : "Swabian", "code": "swabian"],
            ["name" : "Swedish", "code": "swedish"],
            ["name" : "Swiss Food", "code": "swissfood"],
            ["name" : "Tabernas", "code": "tabernas"],
            ["name" : "Taiwanese", "code": "taiwanese"],
            ["name" : "Tapas Bars", "code": "tapas"],
            ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
            ["name" : "Tex-Mex", "code": "tex-mex"],
            ["name" : "Thai", "code": "thai"],
            ["name" : "Traditional Norwegian", "code": "norwegian"],
            ["name" : "Traditional Swedish", "code": "traditional_swedish"],
            ["name" : "Trattorie", "code": "trattorie"],
            ["name" : "Turkish", "code": "turkish"],
            ["name" : "Ukrainian", "code": "ukrainian"],
            ["name" : "Uzbek", "code": "uzbek"],
            ["name" : "Vegan", "code": "vegan"],
            ["name" : "Vegetarian", "code": "vegetarian"],
            ["name" : "Venison", "code": "venison"],
            ["name" : "Vietnamese", "code": "vietnamese"],
            ["name" : "Wok", "code": "wok"],
            ["name" : "Wraps", "code": "wraps"],
            ["name" : "Yugoslav", "code": "yugoslav"]]
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
