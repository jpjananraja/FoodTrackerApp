//
//  DetailViewController.swift
//  FoodTracker
//
//  Created by Janan Rajaratnam on 6/11/15.
//  Copyright (c) 2015 Janan Rajaratnam. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

   @IBOutlet weak var textView: UITextView!
    
    //The USDAItem that is passed from the previous viewcontrollers
    var usdaItem: USDAItem?
    
    
    //SET THE NSNOTIFICATIONCENTER IN THE INIT METHOD RATHER THAN VIEWDIDLOAD
    required init(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "usdaItemDidComplete:", name: kUSDAItemCompleted, object: nil)
        
    }
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if self.usdaItem != nil
        {
            self.textView.attributedText = self.createAttributedString(self.usdaItem!)
            
        }
    }
    
    
    
    
    
    
    
    //MARK:- to manually remove the NSNotificationCenter from memory since ARC doesn't support it (NSNotificationCenter)
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - IBAction Functions
    @IBAction func eatItBarButtonItemPressed(sender: UIBarButtonItem)
    {
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
    //MARK:- NSNotificationCenter Selector function
    func usdaItemDidComplete(notification: NSNotification)
    {
        println("usdaItemDidComplete in Detail ViewController")
        self.usdaItem = notification.object as? USDAItem
        
        //Check whether the view has been loaded and the view's window exists before proceeding forward
        if self.isViewLoaded() && self.view.window != nil
        {
            self.textView.attributedText = self.createAttributedString(self.usdaItem!)
            
        }
    }
    
    //MARK:- Helper Function
    func createAttributedString(usdaItem: USDAItem) -> NSAttributedString
    {
        
        var itemAttributedString = NSMutableAttributedString()
        
        //Set the paragraph style
        var centeredParagraphStyle = NSMutableParagraphStyle()
        centeredParagraphStyle.alignment = NSTextAlignment.Center
        centeredParagraphStyle.lineSpacing = 10.0
        
        //Set the title attributes dictionary
        var titleAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(22.0),
            NSParagraphStyleAttributeName : centeredParagraphStyle
        ]
        
        //Create and initialise the title string
        let titleString = NSAttributedString(string: "\(usdaItem.name)\n", attributes: titleAttributesDictionary)
        
        //Append the string to itemAttributedString
        itemAttributedString.appendAttributedString(titleString)
        
        
        //Create another paragraph style
        var leftAllignParagraphStyle = NSMutableParagraphStyle()
        leftAllignParagraphStyle.alignment = NSTextAlignment.Left
        leftAllignParagraphStyle.lineSpacing = 20.0
        
        //Attributes for the first word
        var styleFirstWordAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.blackColor(),
            NSFontAttributeName : UIFont.boldSystemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignParagraphStyle
        ]
        
        //Attributes for the rest of the words in the paragraph
        var styleOneAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.darkGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignParagraphStyle
        ]
        
        var styleTwoAttributesDictionary = [
            NSForegroundColorAttributeName : UIColor.lightGrayColor(),
            NSFontAttributeName : UIFont.systemFontOfSize(18.0),
            NSParagraphStyleAttributeName : leftAllignParagraphStyle
        ]
        
        //Set the attributes for the usda Fields
        //Calcium
        let calciumTitleString = NSAttributedString(string: "Calcium ", attributes: styleFirstWordAttributesDictionary)
        let calciumBodyString = NSAttributedString(string: "\(usdaItem.calcium)% \n", attributes: styleOneAttributesDictionary)
        
        //Append the respective attributed strings
        itemAttributedString.appendAttributedString(calciumTitleString)
        itemAttributedString.appendAttributedString(calciumBodyString)
        
        //Carbohydrate
        let carbohydrateTitleString = NSAttributedString(string: "Carbohydrate ", attributes: styleFirstWordAttributesDictionary)
        let carbohydrateBodyString = NSAttributedString(string: "\(usdaItem.carbohydrate)% \n", attributes: styleTwoAttributesDictionary)
        
        itemAttributedString.appendAttributedString(carbohydrateTitleString)
        itemAttributedString.appendAttributedString(carbohydrateBodyString)
        
        
        
        //Cholesterol
        let cholesterolTitleString = NSAttributedString(string: "Cholesterol ", attributes: styleFirstWordAttributesDictionary)
        let cholesterolBodyString = NSAttributedString(string: "\(usdaItem.cholesterol)% \n", attributes: styleOneAttributesDictionary)
        
        itemAttributedString.appendAttributedString(cholesterolTitleString)
        itemAttributedString.appendAttributedString(cholesterolBodyString)
        
        
        
        // Energy
        let energyTitleString = NSAttributedString(string: "Energy ", attributes: styleFirstWordAttributesDictionary)
        let energyBodyString = NSAttributedString(string: "\(usdaItem.energy)% \n", attributes: styleTwoAttributesDictionary)
        itemAttributedString.appendAttributedString(energyTitleString)
        itemAttributedString.appendAttributedString(energyBodyString)
        
        // Fat Total
        let fatTotalTitleString = NSAttributedString(string: "FatTotal ", attributes: styleFirstWordAttributesDictionary)
        let fatTotalBodyString = NSAttributedString(string: "\(usdaItem.fatTotal)% \n", attributes: styleOneAttributesDictionary)
        itemAttributedString.appendAttributedString(fatTotalTitleString)
        itemAttributedString.appendAttributedString(fatTotalBodyString)
        
        // Protein
        let proteinTitleString = NSAttributedString(string: "Protein ", attributes: styleFirstWordAttributesDictionary)
        let proteinBodyString = NSAttributedString(string: "\(usdaItem.protein)% \n", attributes: styleTwoAttributesDictionary)
        itemAttributedString.appendAttributedString(proteinTitleString)
        itemAttributedString.appendAttributedString(proteinBodyString)
        
        // Sugar
        let sugarTitleString = NSAttributedString(string: "Sugar ", attributes: styleFirstWordAttributesDictionary)
        let sugarBodyString = NSAttributedString(string: "\(usdaItem.sugar)% \n", attributes: styleOneAttributesDictionary)
        itemAttributedString.appendAttributedString(sugarTitleString)
        itemAttributedString.appendAttributedString(sugarBodyString)
        
        // Vitamin C
        let vitaminCTitleString = NSAttributedString(string: "Vitamin C ", attributes: styleFirstWordAttributesDictionary)
        let vitaminCBodyString = NSAttributedString(string: "\(usdaItem.vitaminC)% \n", attributes: styleTwoAttributesDictionary)
        itemAttributedString.appendAttributedString(vitaminCTitleString)
        itemAttributedString.appendAttributedString(vitaminCBodyString)
            
        return itemAttributedString
        
        
        
        
        
    }

}
