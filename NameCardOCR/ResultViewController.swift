//
//  ResultViewController.swift
//  NameCardOCR
//
//  Created by Nguyễn Quang Đức on 3/30/19.
//  Copyright © 2019 Nguyễn Quang Đức. All rights reserved.
//

import UIKit
import Contacts

class ResultViewController: UIViewController,  UIPickerViewDataSource, UIPickerViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    private var image:UIImage = UIImage()
    private var activeField:UITextField = UITextField()
    private var lastOffset:CGPoint = CGPoint()
    private var currentPickerData: String = ""
    private var currentPickerField: String = ""
    var textFieldLP: [String: UILongPressGestureRecognizer] = [String: UILongPressGestureRecognizer]()
    
    @IBOutlet weak var nameCardView: UIImageView!
    
    @IBOutlet weak var contentView: UIScrollView!
    
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var prefix: UITextField!
    @IBOutlet weak var company: UITextField!
    @IBOutlet weak var jobTitle: UITextField!
    @IBOutlet weak var phonenumber: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var website: UITextField!
    

    @IBOutlet weak var picker: UIPickerView!
    @IBOutlet weak var pickerToolbar: UIToolbar!
    
    @IBOutlet weak var doneEditting: UIButton!
    
    @IBAction func doneEdittingButton(_ sender: Any) {
        view.endEditing(true)
        self.doneEditting.isHidden = true
    }
    
    @IBAction func cancelPicker(_ sender: Any) {
        self.currentPickerData = ""
        self.picker.isHidden = true
        self.pickerToolbar.isHidden = true
        self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @IBAction func donePicker(_ sender: Any) {
        // Store data into Text Field
        switch self.currentPickerField {
        case "fullName":
            self.fullName.text = self.currentPickerData
        case "prefix":
            self.prefix.text = self.currentPickerData
        case "company":
            self.company.text = self.currentPickerData
        case "jobTitle":
            self.jobTitle.text = self.currentPickerData
        case "phonenumber":
            self.phonenumber.text = self.currentPickerData
        case "address":
            self.address.text = self.currentPickerData
        case "email":
            self.email.text = self.currentPickerData
        case "website":
            self.website.text = self.currentPickerData
        default:
            return
        }
        self.currentPickerData = ""
        self.currentPickerField = ""
        self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.picker.isHidden = true
        self.pickerToolbar.isHidden = true
    }
    
    @IBAction func backButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        showCameraView()
    }
    
    @IBAction func saveImage(_ sender: Any) {
        saveImage(image: self.image)
    }
    
    @IBAction func saveContact(_ sender: Any) {
        
        if (self.fullName.text == "") {
            alertDisplay(title: "Oh no, it is missing somethings", message: "You haven't chosen any name for saving!")
            return
        }
        
        startIndicator()
        let contact = CNMutableContact()
        let name = Name(fullName: self.fullName.text!)
        
        contact.givenName = name.last
        contact.familyName = name.first
        contact.namePrefix = self.prefix.text!
        contact.jobTitle = self.jobTitle.text!
        contact.organizationName = self.company.text!
        contact.urlAddresses = [CNLabeledValue(label:CNLabelWork, value: (self.website.text as NSString?)!)]
        
        contact.emailAddresses = [CNLabeledValue(label: CNLabelWork, value: (self.email.text as NSString?)!)]
        
        contact.phoneNumbers = [CNLabeledValue(label:CNLabelPhoneNumberiPhone, value:CNPhoneNumber(stringValue:self.phonenumber.text!))]
        
        let homeAddress = CNMutablePostalAddress()
        var address = self.address.text?.components(separatedBy: ",")
        if (address?.count ?? 0 > 3) {
            homeAddress.country = address?[(address?.count ?? 1)-1] ?? ""
            address?.removeLast()
        }
        if (address?.count ?? 0 > 2) {
            homeAddress.state = address?[(address?.count ?? 1)-1] ?? ""
            address?.removeLast()
        }
        if (address?.count ?? 0 > 1) {
            homeAddress.city = address?[(address?.count ?? 1)-1] ?? ""
            address?.removeLast()
        }
        if (address?.count ?? 0 != 0) {
            homeAddress.street = address?.joined(separator: ", ") ?? ""
        } else {
            homeAddress.street = ""
        }
        contact.postalAddresses = [CNLabeledValue(label:CNLabelWork, value:homeAddress)]
        
        // Saving the newly created contact
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier:nil)
        try! store.execute(saveRequest)
        stopIndicator()
        alertDisplay(title: "Success", message: "We have successfully saved this name card into Contact!")
        
    }
    
    private var pickerData: [String] = [String]()
    private var contactPicker: [String: [String]] = [String: [String]]()
    private let contactKey: [String] = ["fullName", "prefix", "company", "jobTitle", "phonenumber", "address", "email", "website"]
    private let pattern: [String: String] = ["fullName": "(\\b[A-Z]{1}[a-z\\.]+)( )([A-Z]{1}[a-z\\.]+\\b)",
                                             "prefix": "(\\b[A-Z]{1}[a-z\\.]{1,8})( )([A-Z]{1}[a-z]{1,8}\\b)",
                                             "company": "[A-Za-z&\\s]{20,128}",
                                             "jobTitle": "(\\b[A-Z]{1}[a-z\\.]{1,8})( )([A-Z]{1}[a-z]{1,8}\\b)",
                                             "phonenumber": "([0-9\\(\\)\\+\\s]{3,8}+[0-9-\\.,\\s]{7,12})|(0{1}+[0-9]{9})",
                                             "address": "(\\b[A-Za-z0-9\\.\\/\\|]{0,64})(, )([A-Za-z0-9\\.\\/\\|]{0,64}\\b)",
                                             "email": "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}",
                                             "website": "http?://([-\\w\\.]+)+(:\\d+)?(/([\\w/_\\.]*(\\?\\S+)?)?)?"]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
       return self.pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        self.currentPickerData = self.pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var label = UILabel()
        if let v = view {
            label = v as! UILabel
        }
        label.font = UIFont (name: "Helvetica Neue", size: 15)
        label.text = self.pickerData[row]
        label.textAlignment = .center
        return label
    }
    
    func handle(predictText: [String], nameCard: UIImage?) {
        guard let image = nameCard else {
            print("Image is Null")
            return
        }
        self.image = image
        self.nameCardView.image = image
        self.contactPicker = predictValue(inputString: predictText, pattern: self.pattern)
        
        self.fullName.text = self.contactPicker["fullName"]?[0]
        if (self.contactPicker["prefix"]!.count > 1) {
            self.prefix.text = self.contactPicker["prefix"]?[1]
        }
        self.company.text = self.contactPicker["company"]?[0]
        if (self.contactPicker["prefix"]!.count > 3) {
            self.jobTitle.text = self.contactPicker["jobTitle"]?[2]
        } else if (self.contactPicker["prefix"]!.count > 1) {
            self.jobTitle.text = self.contactPicker["jobTitle"]?[self.contactPicker["prefix"]!.count-2]
        } else {
            self.jobTitle.text = self.contactPicker["jobTitle"]?[0]
        }
        self.phonenumber.text = self.contactPicker["phonenumber"]?[0]
        if (self.contactPicker["address"]!.count > 1) {
            self.address.text = self.contactPicker["address"]?[self.contactPicker["address"]!.count-2]
        } else {
            self.address.text = self.contactPicker["address"]?[0]
        }
        self.email.text = self.contactPicker["email"]?[0]
        self.website.text = self.contactPicker["website"]?[0]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        contentView?.delegate = self
        
        self.picker.backgroundColor = UIColor.white
        self.picker.isHidden = true
        self.pickerToolbar.isHidden = true
        self.doneEditting.isHidden = true
        
        self.picker.delegate = self
        self.picker.dataSource = self
        self.view.bringSubviewToFront(self.picker)
        
        self.fullName.delegate = self
        self.prefix.delegate = self
        self.company.delegate = self
        self.jobTitle.delegate = self
        self.phonenumber.delegate = self
        self.address.delegate = self
        self.email.delegate = self
        self.website.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissAll))
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        for key in self.contactKey {
            self.textFieldLP[key] = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
            self.textFieldLP[key]?.minimumPressDuration = 0.25
            self.textFieldLP[key]?.delaysTouchesBegan = true
            self.textFieldLP[key]?.delegate = self
        }

        self.fullName.addGestureRecognizer(self.textFieldLP["fullName"]!)
        self.prefix.addGestureRecognizer(self.textFieldLP["prefix"]!)
        self.company.addGestureRecognizer(self.textFieldLP["company"]!)
        self.jobTitle.addGestureRecognizer(self.textFieldLP["jobTitle"]!)
        self.phonenumber.addGestureRecognizer(self.textFieldLP["phonenumber"]!)
        self.address.addGestureRecognizer(self.textFieldLP["address"]!)
        self.email.addGestureRecognizer(self.textFieldLP["email"]!)
        self.website.addGestureRecognizer(self.textFieldLP["website"]!)
    }

    @objc func keyboardWillShow(_ notification:Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            self.doneEditting.isHidden = false
            self.currentPickerData = ""
            self.picker.isHidden = true
            self.pickerToolbar.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    @objc func dismissAll() {
        self.currentPickerData = ""
        self.picker.isHidden = true
        self.pickerToolbar.isHidden = true
        self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.doneEditting.isHidden = true
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.doneEditting.isHidden = true
        return false
    }
    
    @objc func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state != UIGestureRecognizer.State.ended {
            //When lognpress is start or running
        }
        else {
            switch gestureReconizer {
                case self.textFieldLP["fullName"]:
                    self.pickerData = self.contactPicker["fullName"]!
                    self.currentPickerField = "fullName"
                case self.textFieldLP["prefix"]:
                    self.pickerData = self.contactPicker["prefix"]!
                    self.currentPickerField = "prefix"
                case self.textFieldLP["company"]:
                    self.pickerData = self.contactPicker["company"]!
                    self.currentPickerField = "company"
                case self.textFieldLP["jobTitle"]:
                    self.pickerData = self.contactPicker["jobTitle"]!
                    self.currentPickerField = "jobTitle"
                case self.textFieldLP["phonenumber"]:
                    self.pickerData = self.contactPicker["phonenumber"]!
                    self.currentPickerField = "phonenumber"
                case self.textFieldLP["address"]:
                    self.pickerData = self.contactPicker["address"]!
                    self.currentPickerField = "address"
                case self.textFieldLP["email"]:
                    self.pickerData = self.contactPicker["email"]!
                    self.currentPickerField = "email"
                case self.textFieldLP["website"]:
                    self.pickerData = self.contactPicker["website"]!
                    self.currentPickerField = "website"
                default:
                    return
            }
            self.picker.reloadAllComponents()
            self.picker.isHidden = false
            self.pickerToolbar.isHidden = false
            self.contentView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: self.picker.frame.height, right: 0)
            self.doneEditting.isHidden = true
            view.endEditing(true)
        }
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
//    }
 

}
