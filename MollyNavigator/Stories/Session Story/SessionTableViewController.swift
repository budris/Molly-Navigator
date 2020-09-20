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
  var fetchResultController: NSFetchedResultsController<NSFetchRequestResult>!
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
  var indexEditSession: IndexPath?
  var editSessionName = ""
  {
    didSet{
      if(editSessionName == ""){
        mistakeAlert("Session name would consist some value")
      }else {
        editSession(editSessionName, indexPath: self.indexEditSession!)
        tableView.reloadRows(at: [self.indexEditSession!], with: .fade)
      }
    }
    
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    refresh()
    
  }
  
  // MARK: - Core Data
  
  func addSessionToStorage(_ sessionName: String)
  {
    //        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
    //            let sessionContext = NSEntityDescription.insertNewObject(forEntityName: "Session", into: managedObjectContext) as! Session
    //            sessionContext.session_name = sessionName
    //            do {
    //                try managedObjectContext.save()
    //            } catch {
    //                print(error)
    //                return
    //            }
    //        }
  }
  
  func refresh()
  {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Session")
    let sortDescriptor = NSSortDescriptor(key: "session_name", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    //        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
    //            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    //            fetchResultController.delegate = self
    //
    //            do {
    //                try fetchResultController.performFetch()
    //                sessions = fetchResultController.fetchedObjects as! [Session]
    //            } catch {
    //                print(error)
    //            }
    //        }
    self.tableView.reloadData()
  }
  
  func editSession(_ editSessionName: String, indexPath: IndexPath)
  {
    //        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
    //            let sessionToEdit = self.fetchResultController.object(at: indexPath) as! Session
    //            sessionToEdit.setValue(editSessionName, forKey: "session_name")
    //
    //            do {
    //                try managedObjectContext.save()
    //            } catch {
    //                print(error)
    //            }
    //        }
  }
  
  func getImagesForClothe(_ indexPath: IndexPath) -> [Image]
  {
    var images: [Image] = []
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Image")
    let imageClothePredicate = NSPredicate(format: "clothe.session == %@", sessions[(indexPath as NSIndexPath).row])
    
    fetchRequest.predicate = imageClothePredicate
    let sortDescriptor = NSSortDescriptor(key: "date", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    //        if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
    //            fetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
    //            fetchResultController.delegate = self
    //
    //            do {
    //                try fetchResultController.performFetch()
    //                images = fetchResultController.fetchedObjects as! [Image]
    //
    //            } catch {
    //                print(error)
    //            }
    //        }
    return images
  }
  
  // MARK: - Alert
  
  @IBAction func newSession(_ sender: AnyObject) {
    let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .alert)
    alert.addTextField(configurationHandler: { (textField) -> Void in
      textField.text = "Pretty Molly"
    })
    
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
      let textField = alert.textFields![0] as UITextField
      self.newSessionName = textField.text!
    }))
    
    alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { (action) -> Void in
      
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  func mistakeAlert(_ mistakeText: String)
  {
    let alert = UIAlertController(title: "Mistake", message: mistakeText, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler:nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  func alertEditSession(_ defaultText: String)
  {
    let alert = UIAlertController(title: "Session Name", message: "Enter a text", preferredStyle: .alert)
    alert.addTextField(configurationHandler: { (textField) -> Void in
      textField.text = defaultText
    })
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
      let textField = alert.textFields![0] as UITextField
      self.editSessionName = textField.text!
      
    }))
    self.present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Table view data source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return sessions.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cellSession", for: indexPath) as! SessionTableViewCell
    cell.sessionName.text = self.sessions[(indexPath as NSIndexPath).row].session_name
    return cell
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showSession" {
      let upcoming: ClotheTableViewController = segue.destination as! ClotheTableViewController
      let indexPath = self.tableView.indexPathForSelectedRow!
      upcoming.session = self.sessions[(indexPath as NSIndexPath).row]
      self.tableView.deselectRow(at: indexPath, animated: true)
    }
  }
  
  override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //Share
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
      self.sessions.remove(at: (indexPath as NSIndexPath).row)
      
      //            if let managedObjectContext = (UIApplication.shared.delegate as? AppDelegate)?.managedObjectContext {
      //                let sessionToDelete = self.fetchResultController.object(at: indexPath) as! Session
      //                
      //                managedObjectContext.delete(sessionToDelete)
      //                tableView.deleteRows(at: [indexPath], with: .fade)
      //                do {
      //                    try managedObjectContext.save()
      //                } catch {
      //                    print(error)
      //                }
      //            }
    })
    
    //Edit
    let editAction = UITableViewRowAction(style : .default, title: "Edit", handler: {(actin, indexPath) -> Void in
      self.indexEditSession = indexPath
      self.alertEditSession(self.sessions[(indexPath as NSIndexPath).row].session_name)
      
    })
    
    shareAction.backgroundColor = UIColor(red: 0/255.0, green: 0/255.0, blue: 255.0/255.0, alpha: 1.0)
    deleteAction.backgroundColor = UIColor(red: 255.0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 1.0)
    editAction.backgroundColor  = UIColor(red: 0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
    
    return [deleteAction, shareAction, editAction]
  }
  
  
}
