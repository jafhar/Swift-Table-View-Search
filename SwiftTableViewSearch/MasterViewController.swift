//
//  MasterViewController.swift
//  SwiftTableViewSearch
//
//  Created by Jafharsharief B on 11/05/17.
//  Copyright © 2017 Jafharsharief B. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    private var detailViewController: DetailViewController? = nil
    private var candies = [Candy]()
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var filteredCandies = [Candy]()


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        //Creating static array, we can load data in different ways
        candies = [
            Candy(category:Constant.categoryChocolate, name:"Chocolate Bar"),
            Candy(category:Constant.categoryChocolate, name:"Chocolate Chip"),
            Candy(category:Constant.categoryChocolate, name:"Dark Chocolate"),
            Candy(category:Constant.categoryHard, name:"Lollipop"),
            Candy(category:Constant.categoryHard, name:"Candy Cane"),
            Candy(category:Constant.categoryHard, name:"Jaw Breaker"),
            Candy(category:Constant.categoryOther, name:"Caramel"),
            Candy(category:Constant.categoryOther, name:"Sour Chew"),
            Candy(category:Constant.categoryOther, name:"Gummi Bear")
        ]
        
        searchController.searchResultsUpdater = self as UISearchResultsUpdating
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchBar.scopeButtonTitles = [Constant.categoryAll, Constant.categoryChocolate, Constant.categoryHard, Constant.categoryOther]
        searchController.searchBar.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
   
    // MARK: - Table View
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredCandies.count
        }
        return candies.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let candy: Candy
        if searchController.isActive && searchController.searchBar.text != "" {
            candy = filteredCandies[indexPath.row]
        } else {
            candy = candies[indexPath.row]
        }
        cell.textLabel?.text = candy.name
        cell.detailTextLabel?.text = candy.category
        return cell
    }
    
    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let candy: Candy
                if searchController.isActive && searchController.searchBar.text != "" {
                    candy = filteredCandies[indexPath.row]
                } else {
                    candy = candies[indexPath.row]
                }
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailCandy = candy
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            candies.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    private func filterContentForSearchText(searchText: String, scope: String = "All") {
        filteredCandies = candies.filter { candy in
            let categoryMatch = (scope == "All") || (candy.category == scope)
            return  categoryMatch && candy.name.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
}

extension MasterViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchText: searchController.searchBar.text!, scope: scope)
    }
    
}

extension MasterViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchText: searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

