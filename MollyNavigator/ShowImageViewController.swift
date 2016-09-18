//
//  ShowImageViewController.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 14.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit


class ShowImageViewController: UIViewController {
    
    var img: Image?
    
    @IBAction func showLocation(sender: AnyObject) { }
    @IBOutlet weak var image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        image.image = UIImage(data: (img?.image)!)
        self.title = img?.clothe.name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showLocation" {
            let upcoming: GGCompassNavigatorController = segue.destinationViewController as! GGCompassNavigatorController
            upcoming.image = img
        }
    }
}
