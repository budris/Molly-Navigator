//
//  SessionTableViewController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 01.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

class SessionTableViewController: UITableViewController, NSFetchedResultsControllerDelegate {
    
    var sessions: [Session] = []
    var fetchResultController: NSFetchedResultsController!
    var newSessionName = ""
        {
        didSet {
            if( newSessionName == "" )
            {
                mistakeAlert("Session name would consist some value")
                
            }else {
                addSessionToStorage(newSessionName)
                refresh()
                
            }
        }
    }
    var indexEditSession: NSIndexPath?
    var editSessionName = ""
        {
        didSet{
            if(editSessionName == ""){
                mistakeAlert("Session name would consist some value")
            }else {
                editSession(editSessionName, indexPath: self.indexEditSession!)
                tableView.reloadRowsAtIndexPaths([self.indexEditSession!], withRowAnimation: .Fade)
            }
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Core Data
    
    func addSessionToStorage(sessionName: String)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionContext = NSEntityDescription.insertNewObjectForEntityForName("Session", inManagedObjectContext: managedObjectContext) as! Session
            sessionContext.session_name = sessionName
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
        let fetchRequest = NSFetchRequest(entityName: "Session")
        let sortDescriptor = NSSortDescriptor(key: "session_name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchResultController.delegate = self
            
            do {
                try fetchResultController.performFetch()
                sessions = fetchResultController.fetchedObjects as! [Session]
            } catch {
                print(error)
            }
        }
        self.tableView.reloadData()
    }
    
    func editSession(editSessionName: String, indexPath: NSIndexPath)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! Session
            sessionToEdit.setValue(editSessionName, forKey: "session_name")
            
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
        let imageClothePredicate = NSPredicate(format: "clothe.session == %@", sessions[indexPath.row])
        
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
    
    @IBAction func newSession(sender: AnyObject) {
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = "Pretty Molly"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newSessionName = textField.text!
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: { (action) -> Void in
           
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func mistakeAlert(mistakeText: String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler:nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func alertEditSession(defaultText: String)
    {
        
        let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler({ (textField) -> Void in
            textField.text = defaultText
        })
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editSessionName = textField.text!
    
        }))
        self.presentViewController(alert, animated: true, completion: nil)
    
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessions.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cellSession", forIndexPath: indexPath) as! SessionTableViewCell
        cell.sessionName.text = self.sessions[indexPath.row].session_name
        return cell
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSession" {
            let upcoming: ClotheTableViewController = segue.destinationViewController as! ClotheTableViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            upcoming.session = self.sessions[indexPath.row]
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }

    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Share
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let images = self.getImagesForClothe(indexPath)
            var imagesForShare: [UIImage] = []
            for image in images {
                imagesForShare.append(UIImage(data: image.image)!)
            }
            print("\(imagesForShare.count)")
            let activityController = UIActivityViewController(activityItems: imagesForShare, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.sessions.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Session
        
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
            self.indexEditSession = indexPath
            self.alertEditSession(self.sessions[indexPath.row].session_name)
            
        })
        
        shareAction.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        editAction.backgroundColor  = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction, editAction]
    }


}
