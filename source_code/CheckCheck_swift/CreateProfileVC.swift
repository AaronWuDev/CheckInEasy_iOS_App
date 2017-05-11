// sudo fuser -k 80/tcp

import UIKit

class CreateProfileVC: UIViewController {
    
    @IBOutlet weak var first_name: UITextField!
    @IBOutlet weak var last_name: UITextField!
    @IBOutlet weak var phone_num: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var address: UITextField!
    @IBOutlet weak var institution: UITextField!
    @IBOutlet weak var group: UITextField!
    
    @IBAction func confirmTapped(sender: UIButton) {
        // TODO
        // check the valid of each text field first!
        
        let first_name_str = first_name.text!
        let last_name_str = last_name.text!
        let phone_num_str = phone_num.text!
        let email_str = email.text!
        let address_str = address.text!
        let institution_str = institution.text!
        let group_str = group.text!
        
        // +TODO:
        let profile = [
            "first_name": first_name_str,
            "last_name": last_name_str,
            "phone_num": phone_num_str,
            "email": email_str,
            "address": address_str,
            "institution": institution_str,
            "group": group_str
            ] as NSDictionary
        
        // send data to server
        postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/update_profile", data: profile) { (_) in
            dispatch_async(dispatch_get_main_queue(), { 
                let ac = UIAlertController(title: "Create profile", message: "Successful", preferredStyle: .Alert)
                let at = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
                    dispatch_async(dispatch_get_main_queue(), {
                        self.navigationController?.popViewControllerAnimated(true)
                    })
                })
                ac.addAction(at)
                self.presentViewController(ac, animated: true, completion: nil)
            })
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}







