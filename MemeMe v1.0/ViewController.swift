//
//  ViewController.swift
//  MemeMe v1.0
//
//  Created by Junior on 9/29/15.
//  Copyright (c) 2015 Edilson Junior. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{

/*  ########################################################
    #                                                      #
    #               @IBOutlet  &  @IBAction                #
    #                                                      #
    ########################################################
    */
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    /* SELECT IMAGE FROM CAMERA */
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    /* SELECT IMAGE FROM ALBUM */
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /* SELECT ACTION (e.g. SAVE, SHARE) */
    @IBAction func activityView(sender: UIBarButtonItem) {
        let memedImage = self.generateMemedImage()
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {
            (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                self.save(memedImage)
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    /* RESET EVERYTHING CASE USER PRESS CANCEL */
    @IBAction func resetMeme(sender: UIBarButtonItem) {
        actionButton.enabled = false
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        clearBottomTextField = true
        clearTopTextField = true
        self.view.endEditing(false)
        self.view.frame.origin.y = 0
    }
    
    @IBAction func touchTopTextField(sender: UITextField) {
    }
    
    @IBAction func touchBottomTextField(sender: UITextField) {
    }
    
    var clearTopTextField = true
    var clearBottomTextField = true
    
/*  ########################################################
    #                                                      #
    #               IMAGE VIEW FUNCTIONS                   #
    #                                                      #
    ########################################################
    */
    
    /* DISPLAY SELECTED IMAGE ON THE imageView */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            self.dismissViewControllerAnimated(true, completion: nil)
            actionButton.enabled = true
        }
    }
    
/*  ########################################################
    #                                                      #
    #               TEXT FIELD FUNCTIONS                   #
    #                                                      #
    ########################################################
    */
    
    /* WHAT TO DO WHEN KEYBOARD RETURN BUTTON IS PRESSED */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.unsubscribeFromKeyboardNotifications()
        self.view.endEditing(false)
        return false
    }
   
    /* WHAT TO DO WHEN STARTED EDITING A TEXT FIELD */
    func textFieldDidBeginEditing(textField: UITextField) {
        if bottomTextField.isFirstResponder() && clearBottomTextField{
            bottomTextField.text=""
            clearBottomTextField = false
        }
        if topTextField.isFirstResponder() && clearTopTextField{
            topTextField.text=""
            clearTopTextField = false
        }
    }
    
    /* GET KEYBOARD HEIGHT FROM THE NOTIFICATION'S USERINFO DICTIONARY */
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect (as replaced by as!)
        return keyboardSize.CGRectValue().height
    }
    
    /* SUBSCRIBE NOTIFICATIONS */
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }
    
    /* UNSUBSCRIBE NOTIFICATIONS */
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    /* SHIFT THE VIEW UP ONLY IF THE bottomTextField IS THE FIRST RESPONDER */
    func keyboardWillShow(notification: NSNotification) -> Void{
        if bottomTextField.isFirstResponder(){
            /* GOT THIS SOLUTION HERE: https://discussions.udacity.com/t/better-way-to-shift-the-view-for-keyboardwillshow-and-keyboardwillhide/36558 */
            self.view.frame.origin.y = getKeyboardHeight(notification) * -1
        }
    }
    
    /* HIDE THE KEYBOARD NO MATTER WHO IS THE FIRST RESPONDER */
    /* note: IF CHECKING FIRST RESPONDER IS ACTIVATED AND THE USER HITS bottomTextField -> topTextField -> Return THE VIEW DOES NOT MOVE BACK SINCE THE topTextField IS NOW FIRST RESPONDER */
    func keyboardWillHide(notification: NSNotification) {
            self.view.frame.origin.y = 0
    }

/*  ########################################################
    #                                                      #
    #               MEME FUCTIONS                          #
    #                                                      #
    ########################################################
    */
    
    /* MEME STRUCT */
    struct Meme {
        var topString: String
        var bottomString: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    /* SAVE MEME INTO A STRUCT */
    func save(memedImage: UIImage) {
        let meme = Meme(topString: topTextField.text, bottomString: bottomTextField.text, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    /* MERGE PICKIMAGE WITH TEXTS */
    func generateMemedImage() -> UIImage
    {
        
        /* HIDE TOOLBAR AND NAVBAR */
        self.topToolbar.hidden = true
        self.bottomToolbar.hidden = true
        UIApplication.sharedApplication().statusBarHidden = true
        
        /* RENDER VIEW TO AN IMAGE */
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        /* UNHIDE TOOLBAR AND NAVBAR */
        self.topToolbar.hidden = false
        self.bottomToolbar.hidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        
        return memedImage
    }
    
/*  ########################################################
    #                                                      #
    #               OVERRIDE FUCTIONS                      #
    #                                                      #
    ########################################################
    */

    /* HIDE THE KEYBOARD WHEN THE USER TOUCHES ANYWHERE IN THE VIEW */
    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        self.view.frame.origin.y = 0
        if bottomTextField.isFirstResponder(){
            textFieldShouldReturn(bottomTextField)
        }
        else {
            textFieldShouldReturn(topTextField)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        /* DISABLE cameraButton IF THE DEVICE DOES NOT HAVE CAMERA */
       cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        super.viewWillAppear(animated)
        
        self.subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* DISABLE actionButton */
        actionButton.enabled = false
        
        /* SETUP topTextField AND bottomTextField  */
        let memeTextAttributes = [
            NSStrokeWidthAttributeName : -3.0,
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!
        ]
        
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        topTextField.defaultTextAttributes = memeTextAttributes
        topTextField.text = "TOP"
        topTextField.textAlignment = NSTextAlignment.Center
        
        bottomTextField.defaultTextAttributes = memeTextAttributes
        bottomTextField.text = "BOTTOM"
        bottomTextField.textAlignment = NSTextAlignment.Center
    }
}