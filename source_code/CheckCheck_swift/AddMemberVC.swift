import UIKit

struct Member: Equatable {
    var name: String
    var id: Int
}
func ==(lhs: Member, rhs: Member) -> Bool {
    return (lhs.name == rhs.name) && (lhs.id == rhs.id)
}

class AddMemberVC: UIViewController {
    
    var group_member_list: [Member]? // passed from the previous view
    var all_member_list: [Member]?
    
    var group: Group?
    @IBOutlet weak var nav_title: UINavigationItem!
    @IBOutlet weak var all_member_table: UITableView!
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        // +TODO:
        // update the group_member_list to server
        
        var sentData = [AnyObject]()
        var list = [[String: String]]()
        for i in 0..<group_member_list!.count {
            let item: [String: String] = ["person_id": String(group_member_list![i].id), "person_name": group_member_list![i].name]
            list.append(item)
        }
        let groupId = ["group_id": String(group!.group_id)]
        sentData.append(groupId)
        sentData.append(list)
        
        postToServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/update_group_list", data: sentData, handler: nil)
        
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nav_title.title = "Add members to " + group!.group_name
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        all_member_table.delegate = self
        all_member_table.dataSource = self
        
        if group_member_list == nil {
            group_member_list = [Member]()
        }
        if all_member_list == nil {
            all_member_list = [Member]()
        }
        
        
        // +TODO: fetch all member from server
        getFromServer("http://ec2-54-174-148-149.compute-1.amazonaws.com/all_member_list") { (fetchedMemberList) in
            self.all_member_list = [Member]()
            if let _ = fetchedMemberList {
                let member_list = fetchedMemberList!["all_member_list"]! as! [AnyObject]
                let memberCount = fetchedMemberList!["memberCount"]! as! Int
                for i in 0 ..< memberCount {
                    let fn = member_list[i]["first_name"] as! String
                    let ln = member_list[i]["last_name"] as! String
                    let id = member_list[i]["person_id"] as! Int
                    let person = Member(name: fn + " " + ln, id: id)
                    
                    self.all_member_list?.append(person)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.all_member_table.reloadData()
                })
            }
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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



extension AddMemberVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if all_member_list != nil {
            return all_member_list!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("add_member_cell", forIndexPath: indexPath)
        let title = cell.viewWithTag(400) as! UILabel
        let member = all_member_list![indexPath.row]
        title.text = member.name
        
        // those already in this list should be marked in the first place
        if (group_member_list!.contains(member)) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // see if this man is in the group_member_list
        // if it is, remove it from the group.
        // if not, add it into this group
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let ip = all_member_table.indexPathForCell(cell)!
        let member = all_member_list![ip.row]
        
        if cell.accessoryType == .Checkmark {
            if let index = group_member_list!.indexOf(member) { // if he is already in the list, should be removed
                group_member_list!.removeAtIndex(index)
                cell.accessoryType = .None
            }
        } else {
            group_member_list!.append(member) //should be removed
            cell.accessoryType = .Checkmark
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
}




