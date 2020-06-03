 

import UIKit

class TimeEntryCollectionViewController: UICollectionViewController {
    override func viewDidLoad() {
        let layout = TimeEntryCollectionLayout()
        layout.days = sampleDataByDay
        collectionView?.collectionViewLayout = layout
    }
    override func viewWillAppear(_ animated: Bool) {
        collectionView!.reloadData()
    }
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sampleDataByDay.count
    }
       
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sampleDataByDay[section].entries.count
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell =  collectionView.dequeueReusableCell(withReuseIdentifier: "timeEntryCell", for: indexPath)
               
               let timeEntry = sampleDataByDay[indexPath.section].entries[indexPath.item]
               let label = cell.viewWithTag(1) as! UILabel
               label.text = "\(timeEntry.client) (\(timeEntry.hours))"
               
               return cell
    }
 
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
       let cell =  collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "dayHeaderCell", for: indexPath)
         
                
               let day = sampleDataByDay[indexPath.section];
               let totalHours = day.entries.reduce(0) {(total, entry) in total + entry.hours}
               
               let dateLabel = cell.viewWithTag(1) as! UILabel
               let hoursLabel = cell.viewWithTag(2) as! UILabel
               dateLabel.text =     day.date.replacingOccurrences(of: " ", with: "\n").uppercased()
        
               hoursLabel.text = String(totalHours)
               
               let hours = String(totalHours)
               let bold = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16)]
               let text = NSMutableAttributedString(string: "\(hours)\nHOURS")
               text.setAttributes(bold, range: NSMakeRange(0, hours.count))
               hoursLabel.attributedText = text
               
               return cell
    }
 
}
