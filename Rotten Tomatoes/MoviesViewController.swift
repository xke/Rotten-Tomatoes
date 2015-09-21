//
//  MoviesViewController.swift
//  Rotten Tomatoes
//
//  Created by Xian on 9/15/15.
//  Copyright © 2015 swifterlabs. All rights reserved.
//

import UIKit

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var movies: [NSDictionary]?
    var filteredMovies: [NSDictionary] = []
    
    @IBOutlet weak var networkErrorView: UIView!
    @IBOutlet weak var networkErrorLabel: UILabel!

    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl: UIRefreshControl!
    
    var searchActive : Bool = false


    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    func onRefresh() {
        delay(2, closure: {
            self.refreshControl.endRefreshing()
        })
    }
    
    override func viewDidLoad() {
        KVNProgress.showWithStatus("Finding Movies...")
        
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        
        // refresh control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "onRefresh", forControlEvents: UIControlEvents.ValueChanged)
        tableView.insertSubview(refreshControl, atIndex: 0)
        
        // get urls
        let urlString = "https://gist.githubusercontent.com/timothy1ee/d1778ca5b944ed974db0/raw/489d812c7ceeec0ac15ab77bf7c47849f2d1eb2b/gistfile1.json"


        let task =  NSURLSession.sharedSession().dataTaskWithRequest( // fetches in background thread
            NSURLRequest(URL: NSURL(string: urlString)!),
            completionHandler: {
                (data, response, error) -> Void in
                if let data = data {

                    // Sending the results back to main queue to update UI using the fetched data
                    dispatch_async(dispatch_get_main_queue()) {
                        do {
                            if let json = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary {
                                // extract movies from JSON here and assign it to class variable
                                self.movies = json["movies"] as? [NSDictionary]
                                //print(self.movies!)
                                //print(self.movies!.count)
                                self.view.bringSubviewToFront(self.searchBar)
                                self.tableView.reloadData()
                                KVNProgress.dismiss()
                                

                            }
                            
                        } catch {
                            print("Could not unwrap JSON. DOH!")
                        }
                    }
                    
                } else if let error = error {
                    //  error view
                    dispatch_async(dispatch_get_main_queue()) {

                        if (error.code == -1009) {
                            // network error
                            print(error.code)
                            self.networkErrorView.hidden = false
                            self.networkErrorLabel.hidden = false
                            self.view.bringSubviewToFront(self.networkErrorView)

                        } else {
                            print(error.description)
                            self.networkErrorLabel.text = "Error Found. DOH!"
                        }
                        KVNProgress.dismiss()
                    }
                    
                }
                
        })
        task.resume()
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let movies = self.movies {
            
            if (searchActive) {
                return filteredMovies.count
            } else {
                return movies.count
            }
            
        } else {
            return 0
        }
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieCell", forIndexPath: indexPath) as! MovieCell
        
        var movie : NSDictionary
        if (searchActive) {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        cell.titleLabel.text = movie["title"] as? String
        cell.synopsisLabel.text = movie["synopsis"] as? String
    
        let urlString = movie.valueForKeyPath("posters.thumbnail") as! String
        cell.posterView.setImageWithURL(NSURL(string: urlString)!)
    
        return cell
    }
    
    // search functions
    // http://shrikar.com/swift-ios-tutorial-uisearchbar-and-uisearchbardelegate/
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchActive = true;
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchActive = false;
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        filteredMovies = movies!.filter({ (movie) -> Bool in
            let tmp: NSDictionary = movie
            let range = tmp["title"]!.rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
            return range.location != NSNotFound
        })
        if (searchText.characters.count == 0) {
            searchActive = false;
        } else {
            searchActive = true;
        }
        self.tableView.reloadData()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        
        var movie : NSDictionary
        if (searchActive && filteredMovies.count > 0) {
            movie = filteredMovies[indexPath.row]
        } else {
            movie = movies![indexPath.row]
        }
        
        let movieDetailsViewController = segue.destinationViewController as! MovieDetailsViewController
        movieDetailsViewController.movie = movie
        
        KVNProgress.showWithStatus("Showing Movie...")

        
    }
    

}
