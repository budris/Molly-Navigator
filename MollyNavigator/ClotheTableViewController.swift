//
//  ClotheTableViewController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 01.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit
import CoreData

class ClotheTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var clothes: [Clothe] = []
    var session: Session!
    var showAllImagesForClothe = false
    var selectIndexPath: NSIndexPath?
    var fetchResultController: NSFetchedResultsController!
    var newClotheName = ""
        {
        didSet {
            if( newClotheName == "" )
            {
                mistakeAlert("Clothe name would consist some value")
                
            }else {
                addClotheToStorage(newClotheName)
                refresh()
                
            }
        }
    }
    var indexEditClothe: NSIndexPath?
    var editClotheName = ""
        {
        didSet{
            if(editClotheName == ""){
                mistakeAlert("Clothe name would consist some value")
            }else {
                editClothe(editClotheName, indexPath: self.indexEditClothe!)
                tableView.reloadRowsAtIndexPaths([self.indexEditClothe!], withRowAnimation: .Fade)
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if( session != nil){
            refresh()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImages" {
            let upcoming: ImagesTableViewController = segue.destinationViewController as! ImagesTableViewController
            let indexPath: NSIndexPath?
            if self.tableView.indexPathForSelectedRow == nil
            {
                indexPath = selectIndexPath
            }else{
                indexPath = self.tableView.indexPathForSelectedRow!
            }
            
            upcoming.clothe = clothes[indexPath!.row]
            
            if showAllImagesForClothe {
                showAllImagesForClothe = false
                upcoming.showAll = true
            } else {
                upcoming.showAll = false
            }
            
            self.tableView.deselectRowAtIndexPath(indexPath!, animated: true)
        }
    }
    
    @IBAction func addClothe(sender: AnyObject) {
        let alert = UIAlertController(title: "Clothe Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Pretty jacket"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newClotheName = textField.text!
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    
    func addClotheToStorage(clotheName: String)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let clotheContext = NSEntityDescription.insertNewObjectForEntityForName("Clothe", inManagedObjectContext: managedObjectContext) as! Clothe
            
            clotheContext.name = clotheName
            clotheContext.session = session
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
    }
    
    func refresh()
    {
        let fetchRequest = NSFetchRequest(entityName: "Clothe")
        let clotheSessionPredicate = NSPredicate(format: "session == %@", session)
        fetchRequest.predicate = clotheSessionPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                clothes = fetchResultController.fetchedObjects as! [Clothe]
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
    func editClothe(editSessionName: String, indexPath: NSIndexPath)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! Clothe
            sessionToEdit.setValue(editClotheName, forKey: "name")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func getImagesForClothe(indexPath: NSIndexPath) -> [Image]
    {
        var images: [Image] = []
        let fetchRequest = NSFetchRequest(entityName: "Image")
        let imageClothePredicate = NSPredicate(format: "clothe == %@", clothes[indexPath.row])
        
        fetchRequest.predicate = imageClothePredicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                images = fetchResultController.fetchedObjects as! [Image]
                
            } catch {
                print(error)
            }
        }
        return images
    }
    
    // MARK: - Alert
    
    func mistakeAlert(mistakeText: String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    func alertEditClothe(defaultText: String)
    {
        
        let alert = UIAlertController(title: "Clothe Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = defaultText
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editClotheName = textField.text!
            
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clothes.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellClothe", forIndexPath: indexPath) as! ClotheTableViewCell
        cell.photo.frame = CGRect(x: 0, y: 0, width: cell.imageClothe.frame.width, height: cell.imageClothe.frame.height)
        cell.photo.image = loadPhotoByName(self.clothes[indexPath.row].name)
        cell.clotheName.text = self.clothes[indexPath.row].name
        return cell
    }
    
    func loadPhotoByName(text: String)-> UIImage
    {
        switch text {
            case "shirt": return UIImage(named: "shirt")!
            case "pants": return UIImage(named: "pants")!
            case "shoes": return UIImage(named: "shoes")!
            default:
                return UIImage(named: "undefinded")!
            }
    }
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let images = self.getImagesForClothe(indexPath)
            var imagesForShare: [UIImage] = []
            for image in images {
                imagesForShare.append(UIImage(data: image.image)!)
            }
            let activityController = UIActivityViewController(activityItems: imagesForShare, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.clothes.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Clothe
                
                managedObjectContext.deleteObject(sessionToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        
        //Edit
        let editAction = UITableViewRowAction(style : .Default, title: "Edit", handler: {(actin, indexPath) -> Void in
            self.indexEditClothe = indexPath
            self.alertEditClothe(self.clothes[indexPath.row].name)
            
        })
        
        //Show
        let showAction = UITableViewRowAction(style : .Default, title: "Show", handler: {(actin, indexPath) -> Void in
            self.showAllImagesForClothe = true
            self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.None)
            self.selectIndexPath = indexPath
            self.performSegueWithIdentifier("showImages", sender: nil)
        })
        
        shareAction.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        editAction.backgroundColor  = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        showAction.backgroundColor  = UIColor(red: 0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction, editAction,showAction]
    }
}
