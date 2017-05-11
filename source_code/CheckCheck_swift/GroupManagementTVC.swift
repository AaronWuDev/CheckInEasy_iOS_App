import UIKit

struct Group {
    var group_name: String
    var group_id: Int
}

class GroupManagementTVC: UITableViewController {
    
    //    var editStatus: Int! = 0 // 0: not editing. 1: add. 2: delete
    
    // reload from server
    var group_list: [Group]?
    
    @IBAction func addGroupButtonTapped(sender: UIButton) {
        
        let ac = UIAlertController(title: "Group Management", message: "Add Group", preferredStyle: .Alert)
        ac.addTextFieldWithConfigurationHandler { (textField) in
            textField.placeholder = "Group Name"
            textField.keyboardType = .EmailAddress
        }
        ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (alertAction) in
            if let input_name = (ac.textFields![0] as UITextField).text {
                
                // +TODO: update this group to server
                let sentData = ["group_name": input_name]
                postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/add_group", data: sentData, handler: nil)
                dispatch_async(dispatch_get_main_queue(), {
                    self.refreshGroup() // refresh Group
                })
            }
        }))
        ac.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        ac.view.setNeedsLayout()
        self.presentViewController(ac, animated: true, completion: nil)
    }
    
    func lastIndexPathInSection(section: Int) -> NSIndexPath {
        let numberOfRowsInSection = self.tableView(self.tableView, numberOfRowsInSection: section)
        return NSIndexPath(forRow: numberOfRowsInSection-1, inSection: section)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "Group Management"
        
        // +TODO
        // fetch the group_list from server
        self.refreshGroup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    
    // MARK: - Table view data source
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if group_list != nil {
                return group_list!.count
            } else {
                return 0
            }
        } else if section == 1 {
            return 1
        } else {
            return 0
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("add_member_cell", forIndexPath: indexPath)
            let title = cell.viewWithTag(200) as! UILabel
            //let detail = cell.viewWithTag(201) as! UILabel
            
            title.text = group_list![indexPath.row].group_name
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("add_group_cell", forIndexPath: indexPath)
            return cell
        }
    }
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! MemberVC
        let cell = sender as! UITableViewCell
        let ip = self.tableView.indexPathForCell(cell)!
        dest.group = group_list![ip.row]
    }
}


// MARK: - Server
extension GroupManagementTVC {
    func refreshGroup() {
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
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
                
            }
        }
    }
}






