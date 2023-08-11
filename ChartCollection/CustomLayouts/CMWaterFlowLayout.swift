//
//  CMWaterFlowLayout.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/5/29.
//

import UIKit

enum CMWaterFlowLayoutType {
    case minHeight //按照每列高度，将新的item排列在最低那一列下面
    case itemOrder //按照item的序列，从左至右依次排入不同的列
}

struct ColumnInfo {
    var columnIndex: Int
    var columnHeight: CGFloat
}

protocol CMWaterFlowLayoutDelegate: AnyObject {
    ///每个item的高度，必须实现该方法
    func heightForItem(layout: CMWaterFlowLayout, indexPath: IndexPath) -> CGFloat
    ///每个section中的列数，默认为2
    func columnNumber(layout: CMWaterFlowLayout, section: Int) -> Int
    ///每个section的header高度，默认为0
    func referenceSizeForHeader(layout: CMWaterFlowLayout, section: Int) -> CGSize
    ///每个section的footer高度，默认为0
    func referenceSizeForFooter(layout: CMWaterFlowLayout, section: Int) -> CGSize
    /// 每个section 边距（默认为0）
    func insetForSection(layout: CMWaterFlowLayout, section: Int) -> UIEdgeInsets
    /// 每个section item上下间距（默认为0）
    func lineSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat
    /// 每个section item左右间距（默认为0）
    func interItemSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat
    /// section头部header与上个section尾部footer间距（默认为0）
    func spacingWithLastSection(layout: CMWaterFlowLayout, section: Int) -> CGFloat
}

extension CMWaterFlowLayoutDelegate {
    func columnNumber(layout: CMWaterFlowLayout, section: Int) -> Int {
        return 2
    }
    func referenceSizeForHeader(layout: CMWaterFlowLayout, section: Int) -> CGSize {
        return .zero
    }
    func referenceSizeForFooter(layout: CMWaterFlowLayout, section: Int) -> CGSize {
        return .zero
    }
    func insetForSection(layout: CMWaterFlowLayout, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    func lineSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 0
    }
    func interItemSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 0
    }
    func spacingWithLastSection(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 0
    }
}

class CMWaterFlowLayout: UICollectionViewFlowLayout {
    private var sectionInsets: UIEdgeInsets = .zero
    private var columnCount: Int = 2
    private var lineSpacing: CGFloat = 0
    private var interItemSpacing: CGFloat = 0
    private var headerSize: CGSize = .zero
    private var footerSize: CGSize = .zero
    //每个section的header与上个section的footer距离
    private var spacingWithLastSection: CGFloat = 0
    //布局属性
    private lazy var layoutAttributes: [UICollectionViewLayoutAttributes] = []
    //存放每个section中各个列的高度,初始化一个10*10的二维数组
    private lazy var columnsHeight: [[CGFloat]] = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: 10), count: 10)
    //当前content height，包含header，sections, footer的高度
    private var contentHeight: CGFloat = 0
    //排列方式
    var flowLayoutType: CMWaterFlowLayoutType = .itemOrder
    weak var delegate: CMWaterFlowLayoutDelegate?
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: self.collectionView!.frame.size.width, height: contentHeight)
    }
    
    override func prepare() {
        super.prepare()
        sectionInsets = .zero
        columnCount = 2
        lineSpacing = 0
        interItemSpacing = 0
        headerSize = .zero
        footerSize = .zero
        spacingWithLastSection = 0
        contentHeight = 0
        layoutAttributes.removeAll()
        
        let sectionCount = collectionView!.numberOfSections
        columnsHeight = [[CGFloat]](repeating: [CGFloat](repeating: 0, count: sectionCount), count: 10)
        ///遍历section
        for section in 0..<sectionCount {
            calculateConfigForSection(section)
            columnsHeight[section] = [CGFloat](repeating: 0, count: self.columnCount)
            ///计算header
            if self.headerSize != .zero {
                headerForSection(section)
            }
            //cell数量
            let itemCount = collectionView!.numberOfItems(inSection: section)
            //计算一个新的section中的items时，需要将该section的每一列高度设置为当前最高高度
            //该高度等于上一个 section中header + column height + footer高度
            //使用contentHeight
            for column in 0..<columnCount {
                columnsHeight[section][column] = contentHeight
            }
            //计算section中每个item的layout attributes
            for i in 0..<itemCount {
                let indexPath = IndexPath(item: i, section: section)
                if let attr = layoutAttributesForItem(at: indexPath) {
                    //缓存布局属性
                    layoutAttributes.append(attr)
                }
            }
            contentHeight = columnsHeight[section].max() ?? 0 + sectionInsets.bottom
            
            ///计算footer
            if self.footerSize != .zero {
                footerForSection(section)
            }
        }
    }
    
    private func calculateConfigForSection(_ section: Int) {
        if let columnCount = self.delegate?.columnNumber(layout: self, section: section) {
            self.columnCount = columnCount
        }
        if let inset = self.delegate?.insetForSection(layout: self, section: section) {
            self.sectionInsets = inset
        }
        if let spacingLastSection = self.delegate?.spacingWithLastSection(layout: self, section: section) {
            self.spacingWithLastSection = spacingLastSection
        }
        
        if let lineSpacing = self.delegate?.lineSpacing(layout: self, section: section) {
            self.lineSpacing = lineSpacing
        }
        
        if let interitemSpacing = self.delegate?.interItemSpacing(layout: self, section: section) {
            self.interItemSpacing = interitemSpacing
        }
        
        if let footerSize = self.delegate?.referenceSizeForFooter(layout: self, section: section) {
            self.footerSize = footerSize
        }
        
        if let headerSize = self.delegate?.referenceSizeForHeader(layout: self, section: section) {
            self.headerSize = headerSize
        }
    }
    
    private func headerForSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        if let headerAttri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
            self.layoutAttributes.append(headerAttri)
        }
    }
    
    private func footerForSection(_ section: Int) {
        let indexPath = IndexPath(item: 0, section: section)
        if let footerAttri = self.layoutAttributesForSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, at: indexPath) {
            self.layoutAttributes.append(footerAttri)
        }
    }
    
    func itemWidth(section: Int) -> CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let itemWidth = (collectionView.bounds.width - self.sectionInsets.left - self.sectionInsets.right - self.interItemSpacing * CGFloat(self.columnCount - 1)) / CGFloat(self.columnCount)
        return itemWidth
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.filter({ $0.frame.intersects(rect) })
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        switch flowLayoutType {
        case .minHeight:
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            //获取动态高度
            guard let itemHeight = delegate?.heightForItem(layout: self, indexPath: indexPath) else { return nil }
           
            //找到高度最短的那一列
            guard let minHeight = columnsHeight[indexPath.section].min() else { return nil }
            guard let minHeightIndex = columnsHeight[indexPath.section].firstIndex(of: minHeight) else { return nil }
            var itemY = minHeight
            //判断是否是第一行，如果换行需要加上行间距
            if indexPath.item >= columnCount {
                itemY += lineSpacing
            }
            //计算改索引的X坐标
            let itemX = sectionInsets.left + (itemWidth(section: indexPath.section) + interItemSpacing) * CGFloat(minHeightIndex)
            //赋值新的位置信息
            attr.frame = CGRect(x: itemX, y: itemY, width: itemWidth(section: indexPath.section), height: itemHeight)
            //更新最短高度列的数据
            columnsHeight[indexPath.section][minHeightIndex] = attr.frame.maxY
            
            return attr
        case .itemOrder:
            let attr = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            //获取动态高度
            guard let itemHeight = delegate?.heightForItem(layout: self, indexPath: indexPath) else { return nil }
            //找到item应该放到那一列
            let columnIndex = indexPath.item % columnCount
            //获取这一列当前Y坐标
            guard indexPath.section < columnsHeight.count else { return nil }
            let cHeight = columnsHeight[indexPath.section]
            guard columnIndex < cHeight.count else { return nil }
            var itemY = cHeight[columnIndex]
            //判断是否是第一行，如果换行需要加上行间距
            if indexPath.item >= columnCount {
                itemY += lineSpacing
            }
            //计算改索引的X坐标
            let itemX = sectionInsets.left + (itemWidth(section: indexPath.section) + interItemSpacing) * CGFloat(columnIndex)
            //赋值新的位置信息
            attr.frame = CGRect(x: itemX, y: itemY, width: itemWidth(section: indexPath.section), height: itemHeight)
            //更新当前列的数据
            columnsHeight[indexPath.section][columnIndex] = attr.frame.maxY
            return attr
        }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attri = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, with: indexPath)
        if elementKind == UICollectionView.elementKindSectionHeader {
            self.contentHeight += self.spacingWithLastSection
            attri.frame = CGRect(x: sectionInsets.left, y: self.contentHeight, width: self.headerSize.width, height: self.headerSize.height)
            self.contentHeight += self.headerSize.height
            self.contentHeight += self.sectionInsets.top
        } else if elementKind == UICollectionView.elementKindSectionFooter {
            self.contentHeight += self.sectionInsets.bottom
            attri.frame = CGRect(x: sectionInsets.left, y: self.contentHeight, width: self.footerSize.width, height: self.footerSize.height)
            self.contentHeight += self.footerSize.height
        }
        return attri
    }
}
