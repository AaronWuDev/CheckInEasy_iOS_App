
import UIKit

class IndividualCheckVC: UIViewController {

    @IBOutlet weak var first_name: UITextField!
    @IBOutlet weak var last_name: UITextField!
    
    
    @IBAction func checkinTapped(sender: UIButton) {
        // +TODO
        // send to server this person check in!

        if checkValidName(first_name.text, last_name: last_name.text) {
            let fn = first_name.text!
            let ln = last_name.text!
            let sentData = ["first_name": fn, "last_name": ln]
            postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/check_in", data: sentData, handler: { (res) in
                dispatch_async(dispatch_get_main_queue(), {
                    if res!["success"]! as! Int == 1 {
                        self.popAlert("Check-in", message: "Successful!")
                    } else {
                        self.popAlert("Check-in", message: "Failed!")
                    }
                })
            })
        }
    }
    
    @IBAction func checkoutTapped(sender: UIButton) {
        if checkValidName(first_name.text, last_name: last_name.text) {
            // +TODO
            // send to server this person check out!
            
            if checkValidName(first_name.text, last_name: last_name.text) {
                let fn = first_name.text!
                let ln = last_name.text!
                let sentData = ["first_name": fn, "last_name": ln]
                postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/check_out", data: sentData, handler: { (res) in
                    dispatch_async(dispatch_get_main_queue(), {
                        if res!["success"]! as! Int == 1 {
                            self.popAlert("Check-out", message: "Successful!")
                        } else {
                            self.popAlert("Check-out", message: "Failed!")
                        }
                        
                    })
                })
            }

        }
    }
    
    func popAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let at = UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
            dispatch_async(dispatch_get_main_queue(), {
                self.navigationController?.popViewControllerAnimated(true)
            })
        })
        ac.addAction(at)
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func checkValidName(first_name: String?, last_name: String?) -> Bool {
        if first_name == nil || last_name == nil {
            return false
        } else {
            return true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
