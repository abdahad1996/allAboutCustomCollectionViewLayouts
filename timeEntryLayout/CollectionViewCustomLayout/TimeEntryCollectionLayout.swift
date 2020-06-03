 

import UIKit
//Content Size
//MARK:UICollectionView inherits from UIScrollView. A scroll view displays content that may be larger than the applications window. Without scrolling the content is the same size as the visible area of the collection view


class TimeEntryCollectionLayout: UICollectionViewLayout {
    private var cellAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var headerAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
    private var contentSize: CGSize?
    
    private let numberOfVisibleDays = 7
    private let headerWidth = CGFloat(80)
    private let verticalDividerWidth = CGFloat(2)
    private let horizontalDividerHeight = CGFloat(2)
    //Any time the data changes the invalidateLayout method will be called. This marks the layout as invalid which will force prepareLayout to be called the next time layout information is needed.
    var days: [day] = [] {
        didSet {
            invalidateLayout()
        }
    }
     
    
    override func prepare() {
        if (collectionView == nil) {
            return
        }
        
        // 1: Clear the cache
        cellAttributes.removeAll()
        headerAttributes.removeAll()
        
        // 2: Calculate the height of a row(cotent inset account for statusbar or tabbar etc)
        let availableHeight = collectionView!.bounds.height
            - collectionView!.contentInset.top
            - collectionView!.contentInset.bottom
            - CGFloat(numberOfVisibleDays - 1) * horizontalDividerHeight
        //includes vertical spacing
        let rowHeight = availableHeight / CGFloat(numberOfVisibleDays)

        // 3: Calculate the width available for time entry cells.(item width includes spacing between cells)
        let itemsWidth = collectionView!.bounds.width
            - collectionView!.contentInset.left
            - collectionView!.contentInset.right
            - headerWidth;
        
        var rowY: CGFloat = 0
        
        // 4: For each day
        for (dayIndex, day) in days.enumerated() {
            
            // 4.1: Find the Y coordinate of the row
            rowY = CGFloat(dayIndex) * (rowHeight + horizontalDividerHeight)
            
            // 4.2: Generate and store layout attributes header cell in cache
//            IndexPath(item: 0, section: dayIndex)
            let headerIndexPath = IndexPath(item: 0, section: dayIndex)
           
            let headerCellAttributes =
                UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, with: headerIndexPath)
            
            headerAttributes[headerIndexPath] = headerCellAttributes

            headerCellAttributes.frame = CGRect(x: 0, y: rowY, width: headerWidth, height: rowHeight)
            
            // 4.3: Get the total number of hours for the day
            let hoursInDay = day.entries.reduce(0) { (h, e) in h + e.hours }
            
            // Set the initial X position for time entry cells
            var cellX = headerWidth
            
            // 4.4: For each time entry in day
            for (entryIndex, entry) in day.entries.enumerated() {
                
                // 4.4.1: Get the width of the cell
                //we find ratio between individual and total hours and multiply by item width to get dynamic width of cell. The width of the time entry cells will be proportional to the total number of hours logged for that day
                var cellWidth = CGFloat(Double(entry.hours) / Double(hoursInDay)) * itemsWidth
                
                // Leave some empty space to form the vertical divider
                cellWidth -= verticalDividerWidth
                cellX += verticalDividerWidth
                
                // 4.4.3: Generate and store layout attributes for the cell
                let cellIndexPath = IndexPath(item: entryIndex, section: dayIndex)
                let timeEntryCellAttributes =
                    UICollectionViewLayoutAttributes(forCellWith: cellIndexPath)
                //for cache 
                cellAttributes[cellIndexPath] = timeEntryCellAttributes
                
                timeEntryCellAttributes.frame = CGRect(x: cellX, y: rowY, width: cellWidth, height: rowHeight)
                
                // Update cellX to the next starting position
                cellX += cellWidth
            }
        }
        
        // 5: Store the complete content size
        let maxY = rowY + rowHeight
        contentSize = CGSize(width: collectionView!.bounds.width, height: maxY)
        
        print("collectionView size = \(NSCoder.string(for: collectionView!.bounds.size))")
        print("contentSize = \(NSCoder.string(for: contentSize!))")
    }
        override var collectionViewContentSize: CGSize {
            if contentSize != nil {
                       return contentSize!
                   }
                   return CGSize.zero
        }
//    override func collectionViewContentSize() -> CGSize {
//        if contentSize != nil {
//            return contentSize!
//        }
//        return CGSize.zero
//    }

    //The layout object supplies the collection view with layout information using instances of the UICollectViewLayoutAttribute class. At a minimum, each layout attribute object contains the index path of a cell and its size and position in the content. Instances of this class can be created now, in prepareLayout, or later on demand
    
    //In order to make our scrolling efficient we need to return only the required attributes for a particular rectangle(return the attributes of cell that are present in the particual rectangle) this rectangle is not the visible area of a collectionview it is larger . You can use any technique you wish to determine which attributes should be returned.
    
    //This method gives you a CGRect and wants you to return an array of UICollectionViewLayoutAttributes objects that correspond to the cells/views that lie (partially and wholly) within that rectangle. (Fun fact: The rectangle it gives you is not necessarily the view rectangle).
    override func layoutAttributesForElements(in rect: CGRect) ->
        [UICollectionViewLayoutAttributes]? {
        
        var attributes = [UICollectionViewLayoutAttributes]()

        for attribute in headerAttributes.values {
            if attribute.frame.intersects(rect) {
                attributes.append(attribute)
            }
        }

        for attribute in cellAttributes.values {
            if attribute.frame.intersects(rect) {
                attributes.append(attribute)
            }
        }
            //he first three line are output immediately as the collection view is displayed. Notice that the rectangle that is being requested is not actually the visible area. It actually extends above the content area using a negative height.  As I scrolled down to the bottom you can see the additional rectangles that were requested.
            print("layoutAttributesForElementsInRect rect = \(NSCoder.string(for: rect)), returned \(attributes.count) attributes")
        
        return attributes

    }

//    As if that wasn’t enough, outside of the Core Layout Process, your collection view may also ask for layout attributes at specific index paths
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
           return cellAttributes[indexPath]
       }
 
// As if that wasn’t enough, outside of the Core Layout Process, your collection view may also ask for layoutAttributesForSupplementaryView   at specific index paths
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return headerAttributes[indexPath]
    }
 
}
