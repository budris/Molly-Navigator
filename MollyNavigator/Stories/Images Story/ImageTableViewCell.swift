//
//  ImageTableViewCell.swift
//  MollyNavigator
//
//  Created by Sak Andrey on 06.05.16.
//  Copyright © 2016 Sak Andrey. All rights reserved.
//

import UIKit



class ImageTableViewCell: UITableViewCell, UIPickerViewDelegate, UITextFieldDelegate {
  
  
  @IBOutlet weak var photoLabel: UILabel!
  
  @IBOutlet weak var sessionName: UILabel!
  @IBOutlet weak var pickerPrice: UITextField!
  @IBOutlet weak var timeCreation: UILabel!
  @IBOutlet weak var imageConteiner: UIView!
  
  var photo = UIImageView()
  let picker = UIPickerView()
  var pickerPrices = ["10","15","20","25","30","35","40","45","50","55","60","65","70","75","80","85","90","95"]
  
  override func awakeFromNib() {
    super.awakeFromNib()
    imageConteiner.addSubview(photo)
    
    picker.showsSelectionIndicator = true
    picker.delegate = self
    
    let toolBar = UIToolbar()
    toolBar.barStyle = UIBarStyle.default
    toolBar.isTranslucent = true
    toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
    toolBar.sizeToFit()
    
    let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ImageTableViewCell.donePicker))
    let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
    let cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItem.Style.plain, target: self, action: #selector(ImageTableViewCell.donePicker))
    
    toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
    toolBar.isUserInteractionEnabled = true
    
    pickerPrice.inputView = picker
    pickerPrice.inputAccessoryView = toolBar
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
  // MARK: - picker 
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return pickerPrices.count
  }
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return pickerPrices[row]
  }
  
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    pickerPrice.text = pickerPrices[row]
    picker.endEditing(true)
  }
  
  func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
    picker.isHidden = false
    return false
  }
  
  @objc func donePicker() {
    pickerPrice.resignFirstResponder()
  }
}
