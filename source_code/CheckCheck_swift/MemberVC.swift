
import UIKit

class MemberVC: UIViewController {
    
    // passed from the previous view
    var group: Group?
    
    // reload from server
    var group_member_list: [Member]?
    
    @IBOutlet weak var nav_title: UINavigationItem!
    @IBOutlet weak var member_table: UITableView!
    
    @IBAction func backButtonTapped(sender: UIBarButtonItem) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        nav_title.title = group?.group_name
        member_table.delegate = self
        member_table.dataSource = self
        
        // +++TODO
        // fetch the member list of this group
        // group_member_list = fetch()
        // reload table view
        
        let sentData = [
            "group_name": group!.group_name,
            "group_id": group!.group_id
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
                self.member_table.reloadData()
            })
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let dest = segue.destinationViewController as! AddMemberVC
        dest.group = self.group
        dest.group_member_list = self.group_member_list
     }
    
}


extension MemberVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if group_member_list != nil {
            return group_member_list!.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("member_cell", forIndexPath: indexPath)
        let title = cell.viewWithTag(300) as! UILabel
        title.text = group_member_list![indexPath.row].name
        
        return cell
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
