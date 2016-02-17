//
//  ViewController.swift
//  MemeMe v1.0
//
//  Created by Junior on 9/29/15.
//  Copyright (c) 2015 Edilson Junior. All rights reserved.
//

import UIKit


class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UITextFieldDelegate{
  
/*  ########################################################                                                      #                                                      #
    #                      UI Methods                      #
    #                                                      #
    ########################################################
    */
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [UIInterfaceOrientationMask.Portrait ,UIInterfaceOrientationMask.PortraitUpsideDown,
        UIInterfaceOrientationMask.LandscapeLeft,UIInterfaceOrientationMask.LandscapeRight]
    }
    
    
/*  ########################################################
    #                                                      #
    #               @IBOutlet  &  @IBAction                #
    #                                                      #
    ########################################################
    */
    
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    
    @IBOutlet weak var actionButton: UIBarButtonItem!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topTextField: UITextField!
    
    @IBOutlet weak var bottomTextField: UITextField!
    
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBOutlet weak var topToolbar: UIToolbar!
    
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    
    @IBOutlet weak var albumButton: UIBarButtonItem!
    
    @IBOutlet weak var memeSavedLabel: UILabel!
    
    
    /* SELECT IMAGE FROM CAMERA */
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
            selectImage(UIImagePickerControllerSourceType.Camera)
    }

    /* SELECT IMAGE FROM ALBUM */
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        selectImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    /* SELECT ACTION (e.g. SAVE, SHARE) */
    
    @IBAction func activityView(sender: UIBarButtonItem) {
        
        /* HIDE TOOLBAR AND NAVBAR */
        topToolbar.hidden = true
        bottomToolbar.hidden = true
        
        /* RENDER VIEW TO AN IMAGE */
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawViewHierarchyInRect(view.frame, afterScreenUpdates: true)
        
        let mEModel = MemeEditorModel()
        let memedImage = mEModel.generateMemedImage()
        
        let activityViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        presentViewController(activityViewController, animated: true, completion: nil)
        
        activityViewController.completionWithItemsHandler = {
            (activity: String?, completed: Bool, items: [AnyObject]?, error: NSError?) -> Void in
            if completed {
                mEModel.save(memedImage,topString: self.topTextField.text!, bottomString: self.bottomTextField.text!, originalImage: self.imageView.image!)
       
                self.memeSavedLabel.alpha = 1.0
                UIView.animateWithDuration(2, delay: 0.5, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [], animations: {
                    self.memeSavedLabel.alpha = 0
                    }, completion: nil)
                
                self.reset()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
    }
    
    /* RESET EVERYTHING CASE USER PRESS CANCEL */
    @IBAction func cancel(sender: UIBarButtonItem) {
        reset()
    }
    
    @IBAction func touchTopTextField(sender: UITextField) {
    }
    
    @IBAction func touchBottomTextField(sender: UITextField) {
    }
    
/*  ########################################################
    #                                                      #
    #               IMAGE VIEW VARS & FUCTIONS             #
    #                                                      #
    ########################################################
    */
    

    /* RESET MemeMe */
    func reset() -> Void{
        topToolbar.hidden = false
        bottomToolbar.hidden = false
        actionButton.enabled = false
        imageView.image = nil
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        clearBottomTextField = true
        clearTopTextField = true
        view.endEditing(false)
        view.frame.origin.y = 0
        memeSavedLabel.alpha=0
    }
    
    /* SELECT IMAGE TO BE DISPLAYED */
    func selectImage(picker: UIImagePickerControllerSourceType ){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = picker
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    /* DISPLAY SELECTED IMAGE ON THE imageView */
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
            actionButton.enabled = true
        }
    }
    
/*  ########################################################
    #                                                      #
    #               TEXT FIELD VARS & FUCTIONS             #
    #                                                      #
    ########################################################
    */
    
    var clearTopTextField = true
    var clearBottomTextField = true
    
    /* SETUP topTextField AND bottomTextField  */
    func initialiseTextField(textField: UITextField, text: String){
        textField.delegate = self
        
        let memeTextAttributes = [
            NSStrokeWidthAttributeName : -3.0,
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "Impact", size: 40)!
        ]
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = NSTextAlignment.Center
        textField.autocapitalizationType = .AllCharacters
        textField.adjustsFontSizeToFitWidth = true
        textField.text = text
        textField.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis:UILayoutConstraintAxis.Horizontal)
    }
    
    
    /* CAPITALIZE ALL TEXT FIELDS */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
            textField.text = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string.uppercaseString)
            return false
    }
    
    /* WHAT TO DO WHEN KEYBOARD RETURN BUTTON IS PRESSED */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        unsubscribeFromKeyboardNotifications()
        view.endEditing(false)
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
    func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder(){
            view.frame.origin.y = 0
        }
    }


    
/*  ########################################################
    #                                                      #
    #               OVERRIDE FUCTIONS                      #
    #                                                      #
    ########################################################
    */

    /* HIDE THE KEYBOARD WHEN THE USER TOUCHES ANYWHERE IN THE VIEW */
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        view.frame.origin.y = 0
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
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        memeSavedLabel.alpha=0
        
        /* DISABLE actionButton */
        actionButton.enabled = false
        
        /* INITIALISE TOP AND BOTTOM TEXT FIELDS */
        initialiseTextField(topTextField, text: "TOP")
        initialiseTextField(bottomTextField, text: "BOTTOM")
        
    }
}