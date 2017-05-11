import UIKit

class GroupCheckVC: UIViewController {
    
    @IBOutlet weak var group_label: UILabel!
    @IBOutlet weak var group_picker: UIPickerView!
    @IBOutlet weak var group_table: UITableView!
    
    private var group_list: [Group]?
    private var group_member_list: [Member]?
    //private var group_member_dict: [String:Int]? = ["Jake":1, "Leo":2, "Arron":3, "Jimmy":2]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        group_table.dataSource = self
        group_table.delegate = self
        group_picker.dataSource = self
        group_picker.delegate = self
        
        // +TODO
        // fetch the group list from server
        getFromServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/group_list") { (fetchedGroupList) in
            self.group_list = [Group]()
            if let _ = fetchedGroupList {
                
                let gl = fetchedGroupList!["group_list"]! as! [AnyObject]
                let gc = fetchedGroupList!["groupCount"]! as! Int
                for i in 0 ..< gc {
                    let gn = gl[i]["group_name"] as! String
                    let id = gl[i]["group_id"] as! Int
                    let group = Group(group_name: gn, group_id: id)
                    
                    self.group_list?.append(group)
                }
                
                // fetch group member list using the first group
                if let _ = self.group_list?[0] {
                    let sentData = [
                        "group_name": self.group_list![0].group_name,
                        "group_id": self.group_list![0].group_id
                        ] as NSDictionary
                    postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/member_list", data: sentData) { (fetchedMemberList) in
                        self.group_member_list = [Member]()
                        for i in 0..<(fetchedMemberList!["memberCount"] as! Int) {
                            let id = fetchedMemberList!["group_member"]![i]["person_id"]! as! Int;
                            let name = fetchedMemberList!["group_member"]![i]["person_name"]! as! String;
                            let member = Member(name: name, id: id)
                            
                            self.group_member_list?.append(member)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            self.group_table.reloadData()
                            self.group_picker.reloadAllComponents()
                        })
                    }
                }
            }
        }
        
        // +TODO
        // fetch the member list from server, default it chooses the first item
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        let userCalendar = NSCalendar.currentCalendar()
        let firstSaturdayMarch2015DateComponents = NSDateComponents()
        firstSaturdayMarch2015DateComponents.year = 2015
        firstSaturdayMarch2015DateComponents.month = 3
        //the first day is Sunday, and is represented by the value 1. Monday is represented by 2, Tuesday is represented by 3, all the way to Saturday, which is represented by 7.
        firstSaturdayMarch2015DateComponents.weekday = 7
        firstSaturdayMarch2015DateComponents.weekdayOrdinal = 1
        firstSaturdayMarch2015DateComponents.hour = 11
        firstSaturdayMarch2015DateComponents.minute = 0
        firstSaturdayMarch2015DateComponents.timeZone = NSTimeZone(name: "US/Eastern")
        // On my system (US/Eastern time zone), the result for the line below is
        // "Mar 7, 2015, 11:00 AM"
        let firstSaturdayMarch2015Date = userCalendar.dateFromComponents(firstSaturdayMarch2015DateComponents)!
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

// MARK: - Picker View
extension GroupCheckVC: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if group_list != nil {
            return group_list!.count
        } else {
            return 0
        }
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if group_list != nil {
            return group_list![row].group_name
        } else {
            return nil
        }
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if group_list != nil {
            let group = group_list![row]
            group_label.text = group.group_name
            // TODO
            // fetch all the group members from server and show in table
            // group_member_dict, group_member_list = fetch(group)
            // group_member_list should be a array
            // group_member_dict should be a dictionary
            // each group_member_dict should have a status
            group_table.reloadData()
        }
    }
}


// MARK: - Table View
extension GroupCheckVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if group_member_list != nil {
            return group_member_list!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("group_member_cell", forIndexPath: indexPath)
        let label = tableView.viewWithTag(100) as! UILabel
        let button1 = tableView.viewWithTag(101) as! UIButton
        let button2 = tableView.viewWithTag(102) as! UIButton
        
        let group = group_member_list![indexPath.row]
        label.text = group
        
        switch group_member_dict![group]! {
        case 1:
            button1.setTitle("✖️", forState: UIControlState.Normal)
            button2.setTitle("✖️", forState: UIControlState.Normal)
        case 2:
            button1.setTitle("☑️", forState: UIControlState.Normal)
            button2.setTitle("✖️", forState: UIControlState.Normal)
        case 3:
            button1.setTitle("☑️", forState: UIControlState.Normal)
            button2.setTitle("☑️", forState: UIControlState.Normal)
        default:
            button1.setTitle("✖️", forState: UIControlState.Normal)
            button2.setTitle("✖️", forState: UIControlState.Normal)
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    
    
    
    
    @IBAction func check(sender: UIButton) {
        // determine which button in the table has been chosen
        let touchPoint: CGPoint = sender.convertPoint(CGPointZero, toView: group_table)
        let clickedButtonIndexPath: NSIndexPath = group_table.indexPathForRowAtPoint(touchPoint)!
        let buttonTapped = sender.tag == 101 ? 1 : 2
        let cell = group_table.cellForRowAtIndexPath(clickedButtonIndexPath)
        
        let name = (cell?.viewWithTag(100) as! UILabel).text!
        let button1 = cell!.viewWithTag(101) as! UIButton
        let button2 = cell!.viewWithTag(102) as! UIButton
        let button1Status = button1.titleLabel?.text == "✖️" // true is x
        let button2Status = button2.titleLabel?.text == "✖️" // true is x
        
        
        // case 1: x x
        if button1Status && button2Status {
            if group_member_dict![name] != 1 {
                // status not consistent
                print("status not consistent: 1")
            } else {
                if buttonTapped == 1 {
                    //TODO: update to server that this man checked in
                    group_member_dict![name] = 2 // update datasource
                    print(name + " check in!")
                } else {
                    // error
                    // you cannot check-out before check-in
                    let ac = UIAlertController(title: "Check-in/out", message: "you cannot check-out before check-in", preferredStyle: UIAlertControllerStyle.Alert)
                    let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                    ac.addAction(action)
                    self.presentViewController(ac, animated: true, completion: nil)
                }
            }
        }
        // case 2: v x
        else if !button1Status && button2Status {
            if group_member_dict![name] != 2 {
                // status not consistent
                print("status not consistent: 2")
            } else {
                if buttonTapped == 1 {
                    //TODO: update to server that this man cancel check in
                    group_member_dict![name] = 1 // update datasource
                    print(name + " cancel check-in!")
                } else {
                    //TODO: update to server that this man checked out
                    group_member_dict![name] = 3 // update datasource
                    print(name + " check out!")
                }
            }
            
        }
            // case 3: v v
        else if !button1Status && !button2Status {
            if group_member_dict![name] != 3 {
                // status not consistent
                print("status not consistent: 3")
            } else {
                // TODO: update to server that this man cancel check-in and check-out
                group_member_dict![name] = 1 // update datasource
                print(name + " cancel check in/out!")
            }
        }
        // error
        else {
            print("no such status!")
        }
        
        group_table.reloadRowsAtIndexPaths([clickedButtonIndexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
}


