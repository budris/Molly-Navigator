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
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
    var showAll = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sortButton.setTitle("Date", for: UIControlState())
        title = clothe.name
        initLocationManager()
        reloadFromDB(showAll, sortBy: "price")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        updatePrice()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    func updatePrice()
    {
        
        for row in 0..<tableView.numberOfRows(inSection: 0) {
            let indexPath = IndexPath(row: row, section: 0)
            tableView.scrollToRow(at: indexPath, at: UITableViewScrollPosition.top, animated: false)
            
            let cell :ImageTableViewCell = tableView.cellForRow(at: indexPath) as! ImageTableViewCell
            if images[row].price?.intValue != Int(cell.pickerPrice.text!) {
                images[row].price = Int(cell.pickerPrice.text!) as NSNumber?
                editPrice(images[row].price!, indexPath: indexPath)
            }
        }
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImageClothe" {
            let upcoming: ShowImageViewController = segue.destination as! ShowImageViewController
            let indexPath = self.tableView.indexPathForSelectedRow!
            
            upcoming.img = images[(indexPath as NSIndexPath).row]
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    // MARK: - Core Data
    
    func addImageToStorage(_ image: UIImage)
    {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            let imageContext = NSEntityDescription.insertNewObject(forEntityName: "Image", into: managedObjectContext) as! Image
            
            imageContext.image = UIImageJPEGRepresentation(image, 0.0)!
            imageContext.clothe = clothe
            imageContext.longtitude = lat! as NSNumber?
            imageContext.latitude = long! as NSNumber?
            imageContext.date = Date()
            imageContext.price = 30
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
                return
            }
        }
        
    }
    
    func reloadFromDB(_ showAll: Bool, sortBy: String)
    {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let imageClothePredicate: NSPredicate
        
        if showAll {
            imageClothePredicate = NSPredicate(format: "clothe.name == %@", clothe.name)
        } else {
            imageClothePredicate = NSPredicate(format: "clothe == %@", clothe)
        }
        
        fetchRequest.predicate = imageClothePredicate
        let sortDescriptor = NSSortDescriptor(key: sortBy, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
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
    
    
    func editPrice(_ price: NSNumber, indexPath: IndexPath)
    {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.object(at: indexPath) as! Image
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
    @IBAction func sort(_ sender: AnyObject) {
        if sortButton.currentTitle == "Price" {
            sortButton.setTitle("Date", for: UIControlState())
            reloadFromDB(showAll, sortBy: "price")
        }else {
            sortButton.setTitle("Price", for: UIControlState())
            reloadFromDB(showAll, sortBy: "date")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return images.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageTableViewCell
        cell.pickerPrice.text = String(describing: images[(indexPath as NSIndexPath).row].price!)
        cell.timeCreation.text = getDate(images[(indexPath as NSIndexPath).row].date! as Date)
        cell.photo.frame = CGRect(x: 0, y: 0, width: cell.imageConteiner.frame.width, height: cell.imageConteiner.frame.height)
        cell.photo.image = UIImage(data: images[(indexPath as NSIndexPath).row].image as Data)
        cell.sessionName.text = images[(indexPath as NSIndexPath).row].clothe.session.session_name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (actin, indexPath) -> Void in
            let imageToShare = UIImage(data: self.images[(indexPath as NSIndexPath).row].image as Data)
            let activityController = UIActivityViewController(activityItems: [imageToShare!], applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.images.remove(at: (indexPath as NSIndexPath).row)
            
            if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.object(at: indexPath) as! Image
                managedObjectContext.delete(sessionToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
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
    
    func getDate(_ date: Date) -> String
    {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.day, .month, .year, .hour, .minute], from: date)
        let hour = components.hour
        let minutes = components.minute
        let day = components.day
        let month = components.month
        let year = components.year
        return "\(day ?? 0).\(month ?? 0).\(year ?? 0) \(hour ?? 0):\(minutes ?? 0)"
    }
    
    // MARK: - Photo engine
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if( UIImagePickerController.isSourceTypeAvailable(.camera)) {
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = false
            present(picker, animated:true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var image = info[UIImagePickerControllerEditedImage] as? UIImage
        if image == nil {
            image = info[UIImagePickerControllerOriginalImage] as? UIImage
        }
        addImageToStorage(image!)
        reloadFromDB(showAll, sortBy: "price")
        dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Location Manager
    
    func locationManager(_ manager:CLLocationManager, didUpdateLocations locations:[CLLocation]) {
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
        if(CLLocationManager.authorizationStatus() == CLAuthorizationStatus.notDetermined) {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation();
        manager.startUpdatingHeading();
        
    }

}

