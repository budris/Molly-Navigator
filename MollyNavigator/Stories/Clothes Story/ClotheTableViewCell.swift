//
//  ClotheTableViewCell.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 01.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit

class ClotheTableViewCell: UITableViewCell {
  
  var photo = UIImageView()
  
  @IBOutlet weak var clotheName: UILabel!
  @IBOutlet weak var imageClothe: UIView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageClothe.addSubview(photo)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}
