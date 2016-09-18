//
//  ImagesTableViewController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 06.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class ImagesTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate{

    var images: [Image] = []
    var clothe: Clothe!
    var lat, long: Double?
    var manager: CLLocationManager!
    var fetchResultController: NSFetchedResultsController!
    var showAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortButton.setTitle("Date", forState: .Normal)
        title = clothe.name
        initLocationManager()
        reloadFromDB(showAll, sortBy: "price")
    }
    
    override func viewDidDisappear(animated: Bool) {
        updatePrice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func updatePrice()
    {
        
        for (var row = 0; row < tableView.numberOfRowsInSection(0); row += 1)
        {
            let indexPath = NSIndexPath(forRow: row, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: false)
            
            let cell :ImageTableViewCell = tableView.cellForRowAtIndexPath(indexPath) as! ImageTableViewCell
            if images[row].price != Int(cell.pickerPrice.text!){
                images[row].price = Int(cell.pickerPrice.text!)
                editPrice(images[row].price!, indexPath: indexPath)
            }
        }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showImageClothe" {
            let upcoming: ShowImageViewController = segue.destinationViewController as! ShowImageViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            upcoming.img = images[indexPath.row]
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    // MARK: - Core Data
    
    func addImageToStorage(image: UIImage)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let imageContext = NSEntityDescription.insertNewObjectForEntityForName("Image", inManagedObjectContext: managedObjectContext) as! Image
            
            imageContext.image = UIImageJPEGRepresentation(image, 0.0)!
            imageContext.clothe = clothe
            imageContext.longtitude = lat!
            imageContext.latitude = long!
            imageContext.date = NSDate()
            imageContext.price = 30
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
    }
    
    func reloadFromDB(showAll: Bool, sortBy: String)
    {
        let fetchRequest = NSFetchRequest(entityName: "Image")
        let imageClothePredicate: NSPredicate
        
        if showAll {
            imageClothePredicate = NSPredicate(format: "clothe.name == %@", clothe.name)
        } else {
            imageClothePredicate = NSPredicate(format: "clothe == %@", clothe)
        }
        
        fetchRequest.predicate = imageClothePredicate
        let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: true)
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
        self.tableView.reloadData()
    }
    
    
    func editPrice(price: NSNumber, indexPath: NSIndexPath)
    {
        if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.objectAtIndexPath(indexPath) as! Image
            sessionToEdit.setValue(price, forKey: "price")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
        
    }
    
    // MARK: - Table view soring data
    
    @IBOutlet weak var sortButton: UIButton!
    @IBAction func sort(sender: AnyObject) {
        if sortButton.currentTitle == "Price" {
            sortButton.setTitle("Date", forState: .Normal)
            reloadFromDB(showAll, sortBy: "price")
        }else {
            sortButton.setTitle("Price", forState: .Normal)
            reloadFromDB(showAll, sortBy: "date")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("imageCell", forIndexPath: indexPath) as! ImageTableViewCell
        cell.pickerPrice.text = String(images[indexPath.row].price!)
        cell.timeCreation.text = getDate(images[indexPath.row].date!)
        cell.photo.frame = CGRect(x: 0, y: 0, width: cell.imageConteiner.frame.width, height: cell.imageConteiner.frame.height)
        cell.photo.image = UIImage(data: images[indexPath.row].image)
        cell.sessionName.text = images[indexPath.row].clothe.session.session_name
        return cell
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .Default, title: "Share", handler: { (actin, indexPath) -> Void in
            let imageToShare = UIImage(data: self.images[indexPath.row].image)
            let activityController = UIActivityViewController(activityItems: [imageToShare!], applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .Default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.images.removeAtIndex(indexPath.row)
            
            if let managedObjectContext = (UIApplication.sharedApplication().delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.objectAtIndexPath(indexPath) as! Image
                managedObjectContext.deleteObject(sessionToDelete)
                tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        
        shareAction.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction]
    }
    
    func getDate(date: NSDate) -> String
    {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components([.Day, .Month, .Year, .Hour, .Minute], fromDate: date)
        let hour = components.hour
        let minutes = components.minute
        let day = components.day
        let month = components.month
        let year = components.year
        return "\(day).\(month).\(year) \(hour):\(minutes)"
    }
    
    // MARK: - Photo engine
    
    @IBAction func takePhoto(sender: AnyObject) {
        if( UIImagePickerController.isSourceTypeAvailable(.Camera)) {
            let picker = UIImagePickerController()
            picker.sourceType = .Camera
            picker.delegate = self
            picker.allowsEditing = false
            presentViewController(picker, animated:true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        addImageToStorage(image!)
        reloadFromDB(showAll, sortBy: "price")
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Location Manager
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
        if let location = locations.first as CLLocation? {
            long = location.coordinate.longitude
            lat = location.coordinate.latitude
        }
    }
    func initLocationManager()
    {
        if(manager == nil) {
            manager = CLLocationManager();
        }
        
        manager.delegate = self;
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = true
        NSLog("\(CLLocationManager.authorizationStatus())");
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.NotDetermined) {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation();
        manager.startUpdatingHeading();
        
    }

}

