//
//  MemeModel.swif.swift
//  MemeMe v1.0
//
//  Created by Junior on 2/16/16.
//  Copyright © 2016 Edilson Junior. All rights reserved.
//

import UIKit



class MemeEditorModel {
    
/*########################################################
 #                                                       #
 #               MEME STRUCT & FUCTIONS                  #
 #                                                       #
 #########################################################
 */
 
    var meme: Meme!
    
    /* MERGE PICKIMAGE WITH TEXTS */
    internal func generateMemedImage() -> UIImage
    {
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return memedImage
    }
    
    /* MEME STRUCT */
    struct Meme {
        var topString: String
        var bottomString: String
        var originalImage: UIImage
        var memedImage: UIImage
    }
    
    /* SAVE MEME INTO A STRUCT */
    func save(memedImage: UIImage, topString: String, bottomString: String, originalImage: UIImage) {
        meme = Meme(topString: topString, bottomString: bottomString, originalImage: originalImage, memedImage: memedImage)
    }
}