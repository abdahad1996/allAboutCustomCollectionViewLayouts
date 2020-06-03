 

import UIKit

class TimeEntryTableViewController : UITableViewController {
      func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
     
      func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleData.count;
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
               let data = sampleData[indexPath.item]
               cell.textLabel?.text = data.0
               cell.detailTextLabel?.text = "\(data.1) (\(data.2))"
               return cell;
    }
//      func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        let data = sampleData[indexPath.item]
//        cell.textLabel?.text = data.0
//        cell.detailTextLabel?.text = "\(data.1) (\(data.2))"
//        return cell;
//    }
}
