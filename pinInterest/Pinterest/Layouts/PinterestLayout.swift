 

import UIKit

protocol PinterestLayoutDelegate: AnyObject {
  func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath) -> CGFloat
}

//Collection view layouts are subclasses of the abstract class UICollectionViewLayout. They define the visual attributes of every item in your collection view.
//by default we use the layout given to us but we can customize it to fit our needs


//The individual attributes are instances of UICollectionViewLayoutAttributes. These contain the properties of each item in your collection view, such as the item’s frame or transform.


//Core Layout Process
//Think about the collection view layout process. It’s a collaboration between the collection view and the layout object. When the collection view needs some layout information, it asks your layout object to provide it by calling certain methods in a specific order:
 
 
// collectionViewContentSize: This method returns the width and height of the collection view’s contents. You must implement it to return the height and width of the entire collection view’s content, not just the visible content. The collection view uses this information internally to configure its scroll view’s content size.

// prepare(): Whenever a layout operation is about to take place, UIKit calls this method. It’s your opportunity to prepare and perform any calculations required to determine the collection view’s size and the positions of the items.

// layoutAttributesForElements(in:): In this method, you return the layout attributes for all items inside the given rectangle. You return the attributes to the collection view as an array of UICollectionViewLayoutAttributes.
 
// layoutAttributesForItem(at:): This method provides on demand layout information to the collection view. You need to override it and return the layout attributes for the item at the requested indexPath.
 
 //inshort collectionview asks collectionviewlayout to prepare and return the size of collectionview and the array of layout attributes of the items for  the given rect
class PinterestLayout: UICollectionViewLayout {
  // 1
//  Calculating Layout Attributes
//For this layout specifically , you need to dynamically calculate the height of every item since you don’t know the photo’s height in advance. You’ll declare a protocol that’ll provide this information when PinterestLayout needs it.
  weak var delegate: PinterestLayoutDelegate?

  // 2
  private let numberOfColumns = 2
  private let cellPadding: CGFloat = 6

  // 3
  //This is an array to cache the calculated attributes. When you call prepare(), you’ll calculate the attributes for all items and add them to the cache. When the collection view later requests the layout attributes, you can efficiently query the cache instead of recalculating them every time.
  private var cache: [UICollectionViewLayoutAttributes] = []

  // 4
  //You increment contentHeight as you add photos and calculate contentWidth based on the collection view width and its content inset.
  private var contentHeight: CGFloat = 0

  private var contentWidth: CGFloat {
    guard let collectionView = collectionView else {
      return 0
    }
    let insets = collectionView.contentInset
    return collectionView.bounds.width - (insets.left + insets.right)
  }

  // 5
  //collectionViewContentSize returns the size of the collection view’s contents. You use both contentWidth and contentHeight from previous steps to calculate the size.
  override var collectionViewContentSize: CGSize {
    return CGSize(width: contentWidth, height: contentHeight)
  }
// Your primary objective is to calculate an instance of UICollectionViewLayoutAttributes for every item in the layout.
  override func prepare() {
    // 1 : You only calculate the layout attributes if cache is empty and the collection view exists
    guard
      cache.isEmpty == true,
      let collectionView = collectionView
      else {
        return
    }
    // 2 Declare and fill the xOffset array with the x-coordinate for every column based on the column widths. The yOffset array tracks the y-position for every column. You initialize each value in yOffset to 0, since this is the offset of the first item in each column.
    let columnWidth = contentWidth / CGFloat(numberOfColumns)
    var xOffset: [CGFloat] = []
    for column in 0..<numberOfColumns {
      xOffset.append(CGFloat(column) * columnWidth)
    }
    var column = 0
    var yOffset: [CGFloat] = .init(repeating: 0, count: numberOfColumns)
      
    // 3 Loop through all the items in the first section since this particular layout has only one section
    for item in 0..<collectionView.numberOfItems(inSection: 0) {
      let indexPath = IndexPath(item: item, section: 0)
        
      // 4 Perform the frame calculation. width is the previously calculated cellWidth with the padding between cells removed. Ask the delegate for the height of the photo, then calculate the frame height based on this height and the predefined cellPadding for the top and bottom
      let photoHeight = delegate?.collectionView(
        collectionView,
        heightForPhotoAtIndexPath: indexPath) ?? 180
      let height = cellPadding * 2 + photoHeight
      let frame = CGRect(x: xOffset[column],
                         y: yOffset[column],
                         width: columnWidth,
                         height: height)
      //You then combine this with the x and y offsets of the current column to create insetFrame used by the attribute.
      let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
        
      // 5 Create an instance of UICollectionViewLayoutAttributes, set its frame using insetFrame and append the attributes to cache.
      let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
      attributes.frame = insetFrame
      cache.append(attributes)
        
      // 6 Expand contentHeight to account for the frame of the newly calculated item. Then, advance the yOffset for the current column based on the frame. Finally, advance the column so the next item will be placed in the next column.
      contentHeight = max(contentHeight, frame.maxY)
      yOffset[column] = yOffset[column] + height
        
      column = column < (numberOfColumns - 1) ? (column + 1) : 0
    }
  }
  //Now you need to override layoutAttributesForElements(in:). The collection view calls it after prepare() to determine which items are visible in the given rectangle.
  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
    
    // Loop through the cache and look for items in the rect
//    Here, you iterate through the attributes in cache and check if their frames intersect with rect the collection view provides.
//    You add any attributes with frames that intersect with that rect to visibleLayoutAttributes, which is eventually returned to the collection view.

    for attributes in cache {
      if attributes.frame.intersects(rect) {
        visibleLayoutAttributes.append(attributes)
      }
    }
    return visibleLayoutAttributes
  }
  //Here, you retrieve and return from cache the layout attributes which correspond to the requested indexPath.
  override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
    return cache[indexPath.item]
  }
}
