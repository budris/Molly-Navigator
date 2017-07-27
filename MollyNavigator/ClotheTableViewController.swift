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
    var selectIndexPath: IndexPath?
    var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
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
    var indexEditClothe: IndexPath?
    var editClotheName = ""
        {
        didSet{
            if(editClotheName == ""){
                mistakeAlert("Clothe name would consist some value")
            }else {
                editClothe(editClotheName, indexPath: self.indexEditClothe!)
                tableView.reloadRows(at: [self.indexEditClothe!], with: .fade)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showImages" {
            let upcoming: ImagesTableViewController = segue.destination as! ImagesTableViewController
            let indexPath: IndexPath?
            if self.tableView.indexPathForSelectedRow == nil
            {
                indexPath = selectIndexPath
            }else{
                indexPath = self.tableView.indexPathForSelectedRow!
            }
            
            upcoming.clothe = clothes[(indexPath! as NSIndexPath).row]
            
            if showAllImagesForClothe {
                showAllImagesForClothe = false
                upcoming.showAll = true
            } else {
                upcoming.showAll = false
            }
            
            self.tableView.deselectRow(at: indexPath!, animated: true)
        }
    }
    
    @IBAction func addClothe(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Clothe Name", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = "Pretty jacket"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.newClotheName = textField.text!
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Core Data
    
    func addClotheToStorage(_ clotheName: String)
    {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            let clotheContext = NSEntityDescription.insertNewObject(forEntityName: "Clothe", into: managedObjectContext) as! Clothe
            
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
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Clothe")
        let clotheSessionPredicate = NSPredicate(format: "session == %@", session)
        fetchRequest.predicate = clotheSessionPredicate
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
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
    
    func editClothe(_ editSessionName: String, indexPath: IndexPath)
    {
        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
            let sessionToEdit = self.fetchResultController.object(at: indexPath) as! Clothe
            sessionToEdit.setValue(editClotheName, forKey: "name")
            
            do {
                try managedObjectContext.save()
            } catch {
                print(error)
            }
        }
    }
    
    func getImagesForClothe(_ indexPath: IndexPath) -> [Image]
    {
        var images: [Image] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
        let imageClothePredicate = NSPredicate(format: "clothe == %@", clothes[(indexPath as NSIndexPath).row])
        
        fetchRequest.predicate = imageClothePredicate
        let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
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
        return images
    }
    
    // MARK: - Alert
    
    func mistakeAlert(_ mistakeText: String)
    {
        let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertEditClothe(_ defaultText: String)
    {
        
        let alert = UIAlertController(title: "Clothe Name", message: "Enter a text", preferredStyle: .alert)
        alert.addTextField(configurationHandler: { (textField) -> Void in
            textField.text = defaultText
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            let textField = alert.textFields![0] as UITextField
            self.editClotheName = textField.text!
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clothes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellClothe", for: indexPath) as! ClotheTableViewCell
        cell.photo.frame = CGRect(x: 0, y: 0, width: cell.imageClothe.frame.width, height: cell.imageClothe.frame.height)
        cell.photo.image = loadPhotoByName(self.clothes[(indexPath as NSIndexPath).row].name)
        cell.clotheName.text = self.clothes[(indexPath as NSIndexPath).row].name
        return cell
    }
    
    func loadPhotoByName(_ text: String)-> UIImage
    {
        switch text {
        case "shirt": return UIImage(named: "shirt")!
        case "pants": return UIImage(named: "pants")!
        case "shoes": return UIImage(named: "shoes")!
        default:
            return UIImage(named: "undefinded")!
        }
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        //Social
        let shareAction = UITableViewRowAction(style: .default, title: "Share", handler: { (actin, indexPath) -> Void in
            let images = self.getImagesForClothe(indexPath)
            var imagesForShare: [UIImage] = []
            for image in images {
                imagesForShare.append(UIImage(data: image.image as Data)!)
            }
            let activityController = UIActivityViewController(activityItems: imagesForShare, applicationActivities: nil)
            activityController.popoverPresentationController?.sourceView = self.view
            self.present(activityController, animated: true, completion: nil)
        })
        
        //Delete
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: {(actin, indexPath) -> Void in
            self.clothes.remove(at: (indexPath as NSIndexPath).row)
            
            if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
                let sessionToDelete = self.fetchResultController.object(at: indexPath) as! Clothe
                
                managedObjectContext.delete(sessionToDelete)
                tableView.deleteRows(at: [indexPath], with: .fade)
                do {
                    try managedObjectContext.save()
                } catch {
                    print(error)
                }
            }
        })
        
        //Edit
        let editAction = UITableViewRowAction(style : .default, title: "Edit", handler: {(actin, indexPath) -> Void in
            self.indexEditClothe = indexPath
            self.alertEditClothe(self.clothes[(indexPath as NSIndexPath).row].name)
            
        })
        
        //Show
        let showAction = UITableViewRowAction(style : .default, title: "Show", handler: {(actin, indexPath) -> Void in
            self.showAllImagesForClothe = true
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableViewScrollPosition.none)
            self.selectIndexPath = indexPath
            self.performSegue(withIdentifier: "showImages", sender: nil)
        })
        
        shareAction.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.0)
        deleteAction.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
        editAction.backgroundColor  = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        showAction.backgroundColor  = UIColor(red: 0/255.0, green: 255.0/255.0, blue: 0/255.0, alpha: 1.0)
        
        return [deleteAction, shareAction, editAction,showAction]
    }
}
