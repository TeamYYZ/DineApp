//
//  DetailProfileViewController.swift
//  Dine
//
//  Created by Senyang Zhuang on 4/21/16.
//  Copyright © 2016 YYZ. All rights reserved.
//

import UIKit

class DetailProfileViewController: UIViewController, UIScrollViewDelegate {

    
    @IBOutlet weak var scrollView: UIScrollView!
    
    
    @IBOutlet weak var imageView: UIImageView!
    
    var user: User?
    weak var imageToShow: UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        scrollView.backgroundColor = UIColor.blackColor()

        
        
        if let file = user?.pfUser!["avatar"]{
            file.getDataInBackgroundWithBlock({ (result, error) in
                if result != nil && error == nil{
                    self.imageView.image = UIImage(data: result!)
                    self.scrollView.contentSize = self.imageView.image!.size
                }
            })
        }else{
            self.imageView.image = UIImage(named: "User")
        }
        
            self.imageView.userInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DetailProfileViewController.imageViewOnTap))
            self.imageView.addGestureRecognizer(tapGesture)
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(DetailProfileViewController.longPressed))
            longPressRecognizer.minimumPressDuration = 0.5
            self.imageView.addGestureRecognizer(longPressRecognizer)
        
        // Do any additional setup after loading the view.
    }
    
    func imageViewOnTap(){
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func longPressed(){
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) {
            (action) in
        }
        let saveAction = UIAlertAction(title: "Save Photo", style: .Default) {
            (action)in
             UIImageWriteToSavedPhotosAlbum(self.imageView.image!, self, nil, nil)
        }
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
