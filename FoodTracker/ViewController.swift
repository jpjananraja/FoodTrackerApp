//
//  ViewController.swift
//  FoodTracker
//
//  Created by Janan Rajaratnam on 6/11/15.
//  Copyright (c) 2015 Janan Rajaratnam. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating
{
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //API app id and key
    let kAppId = "4da24213"
    let kAppKey = "92071fe34aa40f139405d96f16dc3aaa"
    
    var searchController: UISearchController!
    
    //food arrays
    var suggestedSearchFoods:[String] = []
    var filteredSuggestedSearchFoods:[String] = []
    
    var apiSearchForFoods:[(name:String, idValue:String)] = []
    
    //array to populate the 2nd scope index "Saved"
    var favoritedUSDAItems:[USDAItem] = []
    
    var filteredFavoritedUSDAItems:[USDAItem] = []

    
    //Scope button
    var scopeButtonTitles = ["Recommended", "Search Results", "Saved"]
    
    //Store the obtained JSON response in a property
    var jsonResponse:NSDictionary!
    
    //DataController instance 
    var dataController = DataController()
    
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        self.searchController = UISearchController(searchResultsController: nil)
        
        self.searchController.searchResultsUpdater = self
        
        self.searchController.dimsBackgroundDuringPresentation = false
        
        self.searchController.hidesNavigationBarDuringPresentation = false
        
        
        //Set the search bar's frame
        self.searchController.searchBar.frame = CGRectMake(self.searchController.searchBar.frame.origin.x, self.searchController.searchBar.frame.origin.y, self.searchController.searchBar.frame.size.width, 44.0)
        
        
        self.tableView.tableHeaderView = self.searchController.searchBar
        
        self.searchController.searchBar.scopeButtonTitles = self.scopeButtonTitles
        
        self.searchController.searchBar.delegate = self
        
        self.definesPresentationContext = true
        
        //intialising the suggestedSearchFoods array
        self.suggestedSearchFoods = ["apple", "bagel", "banana", "beer", "bread", "carrots", "cheddar cheese", "chicken breast", "chili with beans", "chocolate chip cookie", "coffee", "cola", "corn", "egg", "graham cracker", "granola bar", "green beans", "ground beef patty", "hot dog", "ice cream", "jelly doughnut", "ketchup", "milk", "mixed nuts", "mustard", "oatmeal", "orange juice", "peanut butter", "pizza", "pork chop", "potato", "potato chips", "pretzels", "raisins", "ranch salad dressing", "red wine", "rice", "salsa", "shrimp", "spaghetti", "spaghetti sauce", "tuna", "white wine", "yellow cake"]
        
        //Listen for the NSNotificationCenter broadcasts from DataController.swift
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
        
    }
    
    
    
    //MARK:- to manually remove the NSNotificationCenter from memory since ARC doesn't support it (NSNotificationCenter)
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toDetailVCSegue"
        {
            if sender != nil
            {
                var detaiVC = segue.destinationViewController as DetailViewController
                detaiVC.usdaItem = sender as? USDAItem
                
            }
        }
    }
    
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK:- UITableViewDataSource Functions
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
       let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var foodName:String
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0
        {
            if self.searchController.active
            {
                foodName = self.filteredSuggestedSearchFoods[indexPath.row]
                
            }
            else
            {
                foodName = self.suggestedSearchFoods[indexPath.row]
            }
        }
        else if selectedScopeButtonIndex == 1
        {
            //Access the tuple from the array
            foodName = self.apiSearchForFoods[indexPath.row].name
        }
        else // selectedScopeButtonIndex == 2
        {
            
            if self.searchController.active            {
                foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
            }
            else
            {
                //Access the USDAItem stored in the array and use the name property
                foodName = self.favoritedUSDAItems[indexPath.row].name

            }
            
        }
        
        cell.textLabel?.text = foodName
        
        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        
        return cell
    }
    
    
    
//    //MARK:- UITableViewDataSource Functions
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
//    {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
//        
//        var foodName:String
//        
//        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
//        
//        if selectedScopeButtonIndex == 0
//        {
//            if self.searchController.active
//            {
//                if self.searchController.searchBar.text.isEmpty
//                {
//                    foodName = self.suggestedSearchFoods[indexPath.row]
//
//                }
//                else
//                {
//                    foodName = self.filteredSuggestedSearchFoods[indexPath.row]
//                }
//                
//            }
//            else
//            {
//                foodName = self.suggestedSearchFoods[indexPath.row]
//            }
//        }
//        else if selectedScopeButtonIndex == 1
//        {
//            //Access the tuple from the array
//            foodName = self.apiSearchForFoods[indexPath.row].name
//        }
//        else // selectedScopeButtonIndex == 2
//        {
//            
//            if self.searchController.active
//            {
//                if self.searchController.searchBar.text.isEmpty
//                {
//                    foodName = self.favoritedUSDAItems[indexPath.row].name
//                }
//                else
//                {
//                    foodName = self.filteredFavoritedUSDAItems[indexPath.row].name
//                }
//                
//            }
//            else
//            {
//                //Access the USDAItem stored in the array and use the name property
//                foodName = self.favoritedUSDAItems[indexPath.row].name
//                
//            }
//            
//        }
//        
//        cell.textLabel?.text = foodName
//        
//        cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
//        
//        
//        return cell
//    }

    
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0
        {
            if self.searchController.active
            {
                if self.searchController.searchBar.text.isEmpty
                {
                    return self.suggestedSearchFoods.count
                }
                else
                {
                 return self.filteredSuggestedSearchFoods.count
                }
                
            }
            else
            {
                //SearchController is not active
                return self.suggestedSearchFoods.count
                
            }
        }
        else if selectedScopeButtonIndex == 1
        {
            return self.apiSearchForFoods.count
        }
        else // selectedScopeButtonIndex == 2
        {
            if self.searchController.active
            {
                if self.searchController.searchBar.text.isEmpty
                {
                    return self.favoritedUSDAItems.count
                }
                else
                {
                    return self.filteredFavoritedUSDAItems.count
                }
                
            }
            else
            {
                return self.favoritedUSDAItems.count
                
            }
            
        }
        
    }
    
    //MARK:- UITableViewDelegate functions
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeButtonIndex == 0
        {
            var searchFoodName :String
            
            if self.searchController.active
            {
                searchFoodName = self.filteredSuggestedSearchFoods[indexPath.row]
            }
            else
            {
                searchFoodName = self.suggestedSearchFoods[indexPath.row]
            }
            
            //Now change the selectedScopeButtonIndex to 1 so that further food info will be displayed for the selected food item
            self.searchController.searchBar.selectedScopeButtonIndex = 1
            
            //Do the HTTP Post Request for the selected food item
            self.makeRequest(searchFoodName)
        }
        else if selectedScopeButtonIndex == 1
        {
            self.performSegueWithIdentifier("toDetailVCSegue", sender: nil)
            
            
            //get idValue of the food item that is selected
            let idValue = apiSearchForFoods[indexPath.row].idValue
            
            //Save the selected food item into coredata
            self.dataController.saveUSDAItemForId(idValue, json: self.jsonResponse)
            
            
        }
        else if selectedScopeButtonIndex == 2
        {
            if self.searchController.active
            {
                let usdaItem = self.filteredFavoritedUSDAItems[indexPath.row]
                
                //Do a segue and pass the usdaItem selected as a parameter
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
            }
            else
            {
                let usdaItem = self.favoritedUSDAItems[indexPath.row]
                
                //To a segue and pass the usdaItem selected as a parameter
                self.performSegueWithIdentifier("toDetailVCSegue", sender: usdaItem)
                
            }
        }
        
        
    }
    
    
//    MARK:- UISearchResultsUpdating functions
    func updateSearchResultsForSearchController(searchController: UISearchController)
    {
        
        let searchString = self.searchController.searchBar.text
        
        let selectedScopeButtonIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        //If the search bar is empty show, the original table view even if the searchbar is active
        if searchString == ""
        {
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods
        }
        else
        {
            self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        }
        
    
        
        
//        self.filterContentForSearch(searchString, scope: selectedScopeButtonIndex)
        
        self.tableView.reloadData()
        
    }
    
    
    
    
    //MARK:-  UISearchBarDelegate functions
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar)
    {
        //update the selected scope button index
        self.searchController.searchBar.selectedScopeButtonIndex = 1
        
        //Make the request when button is search button is entered/clicked
        self.makeRequest(searchBar.text)
        
        
    }
    
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int)
    {
        
        if selectedScope == 2
        {
            //If the selectedscope index is 2 then populate the array using the below function
            self.requestFavoritedUSDAItems()
        }
        
        //Reload the tableview with the corresponding data attributed with the scope index that is selected
        self.tableView.reloadData()
        
    }
    
    //MARK:-  Helper Functions
    
    func filterContentForSearch(searchText: String, scope: Int)
    {
        if scope == 0
        {
            self.filteredSuggestedSearchFoods = self.suggestedSearchFoods.filter({ (food:String) -> Bool in
                
            var foodMatch = food.rangeOfString(searchText.lowercaseString)
                
            return foodMatch != nil
                
                
            })
        }
        else if scope == 2
        {
          
            self.filteredFavoritedUSDAItems = self.favoritedUSDAItems.filter({ (item:USDAItem) -> Bool in
                
                var filteredFoodMatch = item.name.rangeOfString(searchText.lowercaseString)
                
                return filteredFoodMatch != nil

            })
            
        }
        
        
        
    }
    

    func makeRequest(searchString: String)
    {
        //    How to make a HTTP GET Request
//        let url = NSURL(string: "https://api.nutritionix.com/v1_1/search/\(searchString)?results=0%3A20&cal_min=0&cal_max=50000&fields=item_name%2Cbrand_name%2Citem_id%2Cbrand_id&appId=\(kAppId)&appKey=\(kAppKey)")
//        
//       let task =  NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data , response, error) -> Void in
//      
//            var stringData = NSString(data: data , encoding: NSUTF8StringEncoding)
//
//            
//            
//            
//            println(stringData)
//            println(response)
//            
//            
//            
//            
//        })
//        task.resume()
        
        
        //How to make a HTTP POST Request
        var request = NSMutableURLRequest(URL: NSURL(string: "https://api.nutritionix.com/v1_1/search/")!)
        
        let session = NSURLSession.sharedSession()
        
        request.HTTPMethod = "POST"
        
        //Create the dictionary of parameters
        var params = [
            "appId" : kAppId,
            "appKey" : kAppKey,
            "fields" : ["item_name", "brand_name", "keywords", "usda_fields"],
            "limit" :"50",
            "query" : searchString,
            "filters" : ["exists" : ["usda_fields" : true]]
        ]
        
        
        var error:NSError?
        
        //convert the params a foundation object into JSON data using dataWithJSONObject
        request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: nil, error: &error)
        
        //Add the HTTP Header file values for the POST Request
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        
        
        //Define the task object and what the handler should do once the request is completed
        //The completion handler executes in the background only after the POST Request was successfull
        var task = session.dataTaskWithRequest(request, completionHandler: { (data, response, err) -> Void in
           
//            println(data)
            
//            var stringData = NSString(data: data , encoding: NSUTF8StringEncoding)
            
            
           
//            println(stringData)
            
            var conversionError:NSError?
            
            //Convert the obtained JSON "data" into the respective NSDictionary object
            var jsonDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableLeaves, error: &conversionError) as? NSDictionary
            
//            println("\n\n\n \(jsonDictionary)")
            
            //Do Error Handling if conversionError has a value
            if conversionError != nil
            {
                println("\n\n\n There is a conversion error => \(conversionError!.localizedDescription)")
                let errorString = NSString(data: data , encoding: NSUTF8StringEncoding)
                
                println("Error in parsing \(errorString!)")
            }
            else
            {
                //If there is no error ... conversionError == nil then...
                
                // jsonDictionary has values, then...
                if jsonDictionary != nil //If there is a value then..
                {
                    self.jsonResponse = jsonDictionary!
                    self.apiSearchForFoods = DataController.jsonAsUSDAIdAndNameSearchResults(jsonDictionary!)
                    
                    
                    //Reload table data in the background thread...Takes time
                    //self.tableView.reloadData()
                    
                    //Instead Reload table data in the main thread to see visible improvements
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        
                        self.tableView.reloadData()
                    })
                    
                }
                else // jsonDictionary == nil. Has no values/empty
                {
                    let errorString = NSString(data: data , encoding: NSUTF8StringEncoding)
                    println("Error!! Could not parse JSON \(errorString)")
                }
            }
            
        }) //end of completion handler
        
        task.resume()
        
    }
    
    //MARK:- Setup CoreData for retrieving saved entities
    func requestFavoritedUSDAItems()
    {
        let fetchRequest = NSFetchRequest(entityName: "USDAItem")
        let appDelegate = (UIApplication.sharedApplication().delegate as AppDelegate)
        let managedObjectContext = appDelegate.managedObjectContext
        
        //Retrieve the saved info and populate the array
        self.favoritedUSDAItems = managedObjectContext?.executeFetchRequest(fetchRequest, error: nil) as [USDAItem]
    }
    
    //MARK:- NSNotificationCenter "selector" function
    func usdaItemDidComplete(notification:NSNotification)
    {
        println("usdaItemDidComplete in ViewController")
        self.requestFavoritedUSDAItems()
        let selectedScopeIndex = self.searchController.searchBar.selectedScopeButtonIndex
        
        if selectedScopeIndex == 2
        {
            self.tableView.reloadData()
        }
    }

}

