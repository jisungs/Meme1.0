//
//  MemeEditVC.swift
//  Meme1.0
//
//  Created by The book on 2018. 1. 1..
//  Copyright © 2018년 The book. All rights reserved.
//


import UIKit

class MemeEditVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var imagePickerView: UIImageView!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var camera:UIBarButtonItem!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var navigationBar: UIToolbar!
    
    func customizeTextField(textField: UITextField, defaultText: String) {
        let memeTextAttributes:[String:Any] = [
            NSAttributedStringKey.strokeColor.rawValue: UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
            NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue: -5
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.text = defaultText
        textField.textAlignment = .center
    }
    
    func setupInitialView() {
        imagePickerView.image = nil
        camera.isEnabled = true
        
       customizeTextField(textField: topText, defaultText: "Top")
       customizeTextField(textField: bottomText, defaultText: "Bottom")
        
        shareButton.isEnabled = false
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        subscribeToKeyboardNotifications()
        
        camera.isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
        setupInitialView()
        
    }
    
    func subscribeToKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name:.UIKeyboardDidHide, object: nil)
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        if view.frame.origin.y == 0 && bottomText.isFirstResponder {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }else {
            resetFrame()
        }
     }
    
    @objc func keyboardWillHide(_ notification:Notification) {
        if view.frame.origin.y != 0{
            resetFrame()
        }
    }
    
    func resetFrame(){
        view.frame.origin.y = 0;
    }
    
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?){
        self.view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialView()
        view.backgroundColor = UIColor.gray
     }
    
    // Album button function
    @IBAction func pickAnImage(_ sender: Any) {
        callImage(source: UIImagePickerControllerSourceType.photoLibrary)
    }

    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        callImage(source: UIImagePickerControllerSourceType.camera)
    }
    
    func callImage(source:UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage]
        
        if ((image as? UIImage) != nil){
            
            imagePickerView.image = image as! UIImage?
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
         setupInitialView()
    }
    
    func saveMeme(memedImage:UIImage){
        let meme = Meme(topText: topText.text!, bottomText: bottomText.text!, image: imagePickerView.image!, memedImage: memedImage)
    }
    
    func generateMemeImage()-> UIImage {
        
        toolBar.isHidden = true
        navigationBar.isHidden = true
        
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toolBar.isHidden = false
        navigationBar.isHidden  = false
        
        return memedImage
    }
    
    //shareButton function
    @IBAction func shareImage(_ sender: Any) {
        let memedImage = generateMemeImage()
        let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activityController.completionWithItemsHandler = {
            activity, completed, items, error in
            if completed {
                self.saveMeme(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
        
        self.present(activityController, animated: true, completion: nil)
    }
    
    
}

