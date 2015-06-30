//
//  DataController.swift
//  FoodTracker
//
//  Created by Janan Rajaratnam on 6/19/15.
//  Copyright (c) 2015 Janan Rajaratnam. All rights reserved.
//

import Foundation
import UIKit
import CoreData

//For other classes to get access to the following constant, declare it before the class declaration
let kUSDAItemCompleted = "USADAItemInstanceComplete"

class DataController
{
//Returns an array of tuples
class func jsonAsUSDAIdAndNameSearchResults(json: NSDictionary) -> [(name:String, idValue:String)]
{
    //The array holding tuples
    var usdaItemsSearchResults: [(name:String, idValue:String)] = []

    //Create the tuple object
    var searchResult: (name:String, idValue:String)
    
    if json["hits"] != nil
    {
        let results:[AnyObject] = json["hits"]! as [AnyObject]
        
        //Iterate through the array and obtain every dictionary in it
        for itemDictionary in results
        {
            
            if itemDictionary["_id"] != nil
            {
                if itemDictionary["fields"] != nil
                {
                    let fieldsDictionary = itemDictionary["fields"] as NSDictionary
                    
                    if fieldsDictionary["item_name"] != nil
                    {
                        let idValue:String = itemDictionary["_id"]! as String
                        let name:String = fieldsDictionary["item_name"]! as String
                        
                        //Add the values to the tuple
                        searchResult = (name: name, idValue: idValue)
                        
                        //Add the tuple to the array
                        usdaItemsSearchResults += [searchResult]
                        
                    }
                }
            }
            
            
            
        }
    }
    
    return usdaItemsSearchResults
}
    

//MARK :- Helper functions
func saveUSDAItemForId(idValue: String, json:NSDictionary)
{
    // Check whether the "value" for the key "hits" in the dictionary "json" is not empty/nil
    if json["hits"] != nil
    {
        //If not nil, then extract the array of dictionaries for the key "hits" in the dictionary "json" in the form of [AnyObject]
        let results:[AnyObject] = json["hits"]! as [AnyObject]
        
        
        //for every dictionary object found in the array "results" do fast enumeration
        for itemDictionary in results
        {
         
            //Check whether the dictionary value for itemDictionary["_id"] exists and that the value in itemDictionary["_id"] is equal to the parameter "idValue" sent to this method
            if itemDictionary["_id"] != nil && itemDictionary["_id"] as String == idValue
            {
                let managedObjectContext = (UIApplication.sharedApplication().delegate as AppDelegate).managedObjectContext
                
                //Create a fetch request for the entity "USDAItem"
                var requestForUSDAItem = NSFetchRequest(entityName: "USDAItem")
                
                //Obtain the value for the key "_id" in the dictionary itemDictionary
                let itemDictionaryId:String = itemDictionary["_id"]! as String
                
                
                //Check whether the entity USDAItem with same itemDictionaryId is stored in core data
                
                
                //Create a predicate that searches for items that match the value of itemDictionaryId
                let predicate = NSPredicate(format: "idValue == %@", itemDictionaryId)
                
                //Set the predicate property for  fetch request "requestForUSDAItem" with the above constant
                requestForUSDAItem.predicate = predicate
                
                var error : NSError?
                
                //Fetch the array of items that are "USDAItem" entities and meet the requirements indicated in the NSPredicate conditions
                var items = managedObjectContext?.executeFetchRequest(requestForUSDAItem, error: &error)
                
                
                
                //Check whether the item is already saved in core data
                if items?.count != 0
                {
                    //The item is already saved into core data...do not resave the item again
                    println("The item was already saved to CoreData")
                    
                    //Without the following two lines of code, when a user selects an item that was already saved into core data, the DetailVC textview will display gibberishs
                    let usdaItem:USDAItem = items?[0] as USDAItem;
                    NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
                    
                    
                    return
                }
                else
                {
                    //The item is not saved into core data
                    println("Lets save this to core data")
                    
                    //create the entityDescription
                    let entityDescription = NSEntityDescription.entityForName("USDAItem", inManagedObjectContext: managedObjectContext!)
                    
                    //Create the USDAItem
                    let usdaItem = USDAItem(entity:entityDescription!, insertIntoManagedObjectContext: managedObjectContext!)
                    
                    
                    //Set the idValue of the USDAItem
                    usdaItem.idValue = itemDictionary["_id"]! as String
                    
                    //Set the date it was added
                    usdaItem.dateAdded = NSDate()
                    
                    //To set the name attribute in a USDAItem instance
                    if itemDictionary["fields"] != nil
                    {
                        let fieldsDictionary = itemDictionary["fields"]! as NSDictionary
                        if fieldsDictionary["item_name"] != nil
                        {
                            usdaItem.name = fieldsDictionary["item_name"]! as String
                            
                            
                        }
                        //set the calcium attribute
                        if fieldsDictionary["usda_fields"] != nil
                        {
                            let usdaFieldsDictionary = fieldsDictionary["usda_fields"]! as NSDictionary
                            
                            if usdaFieldsDictionary["CA"] != nil
                            {
                                let calciumDictionary = usdaFieldsDictionary["CA"]! as NSDictionary
                                
                                let calciumValue:AnyObject = calciumDictionary["value"]!
                                
                                usdaItem.calcium = "\(calciumValue)"
                            }
                            else
                            {
                                // usdaFieldsDictionary["CA"] == nil
                                usdaItem.calcium = "0"
                            }
                            
                            //Adding Carbohydrate attribute
                            
                            if usdaFieldsDictionary["CHOCDF"] != nil
                            {
                                let carbohydrateDictionary = usdaFieldsDictionary["CHOCDF"]! as NSDictionary
                                
                                if carbohydrateDictionary["value"] != nil
                                {
                                    let carbohydrateValue:AnyObject = carbohydrateDictionary["value"]!
                                    
                                    usdaItem.carbohydrate = "\(carbohydrateValue)"
                                }
                            }
                            else
                            {
                                    //usdaFieldsDictionary["CHOCDF"] == nil
                                    usdaItem.carbohydrate = "0"
                            }
                            
                            //Adding the fat total value to the fat attribute
                            if usdaFieldsDictionary["FAT"] != nil
                            {
                                let fatTotalDictionary = usdaFieldsDictionary["FAT"]! as NSDictionary
                                    
                                if fatTotalDictionary["value"] != nil
                                {
                                    let fatTotalValue:AnyObject = fatTotalDictionary["value"]!
                                        
                                    usdaItem.fatTotal = "\(fatTotalValue)"
                                }
                            }
                            else
                            {
                                    //usdaFieldsDictionary["FAT"] == nil
                                    usdaItem.fatTotal = "0"
                            }
                                    
                            //Adding the cholesterol attribute
                            if usdaFieldsDictionary["CHOLE"] != nil
                            {
                                let cholesterolDictionary = usdaFieldsDictionary["CHOLE"]!  as NSDictionary
                                        
                                if cholesterolDictionary["value"] != nil
                                {
                                    let cholesterolValue:AnyObject = cholesterolDictionary["value"]!
                                            
                                    usdaItem.cholesterol = "\(cholesterolValue)"
                                }
                            }
                            else
                            {
                                    //usdaFieldsDictionary["CHOLE"] == nil
                                    usdaItem.cholesterol = "0"
                            }
                            
                            if usdaFieldsDictionary["PROCNT"] != nil
                            {
                                let proteinDictionary = usdaFieldsDictionary["PROCNT"]! as NSDictionary
                                
                                if proteinDictionary["value"] != nil
                                {
                                    let proteinValue:AnyObject = proteinDictionary["value"]!
                                    
                                    usdaItem.protein = "\(proteinValue)"
                                }
                            }
                            else
                            {
                                usdaItem.protein = "0"
                            }
                            
                            if usdaFieldsDictionary["SUGAR"] != nil
                            {
                                let sugarDictionary = usdaFieldsDictionary["SUGAR"]! as NSDictionary
                                
                                if sugarDictionary["value"] != nil
                                {
                                    let sugarValue:AnyObject = sugarDictionary["value"]!
                                    
                                    usdaItem.sugar = "\(sugarValue)"
                                }
                            }
                            else
                            {
                                //usdaFieldsDictionary["SUGAR"] == nil
                                usdaItem.sugar = "0"
                                        
                            }
                            
                            if usdaFieldsDictionary["VITC"] != nil
                            {
                                let vitaminCDictionary = usdaFieldsDictionary["VITC"]! as NSDictionary
                                if vitaminCDictionary["value"] != nil
                                {
                                    let vitaminCValue: AnyObject = vitaminCDictionary["value"]!
                                    usdaItem.vitaminC = "\(vitaminCValue)"
                                }
                            }
                            else
                            {
                                //usdaFieldsDictionary["VITC"] == nil
                                usdaItem.vitaminC = "0"
                            }
                            
                            if usdaFieldsDictionary["ENERC_KCAL"] != nil
                            {
                                let energyDictionary = usdaFieldsDictionary["ENERC_KCAL"]! as NSDictionary
                                if energyDictionary["value"] != nil
                                {
                                    let energyValue: AnyObject = energyDictionary["value"]!
                                    usdaItem.energy = "\(energyValue)"
                                }
                            }
                            else
                            {
                                //usdaFieldsDictionary["ENERC_KCAL"] == nil
                                usdaItem.energy = "0"
                            }
                            
                            //Save the usdaItem into core data
                            (UIApplication.sharedApplication().delegate as AppDelegate).saveContext()
                            
                            //Do the NSNotification processes after the usdaItem is saved into CoreData
                            NSNotificationCenter.defaultCenter().postNotificationName(kUSDAItemCompleted, object: usdaItem)
                        }
                    }
                }
            }
        }
    }
}

}


