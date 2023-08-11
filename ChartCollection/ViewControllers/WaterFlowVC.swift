//
//  WaterFlowVC.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/7/13.
//

import Foundation
import UIKit


enum CellType {
    case large
    case medium
    case small
}

struct CellData {
    var title: String
    var type: CellType
}

class WaterFlowVC: UIViewController {
    private var cellItems: [[CellData]] = [[CellData]]()
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: waterflowLayout)
        collectionView.register(WaterFlowLargeCell.self, forCellWithReuseIdentifier: "WaterFlowLargeCell")
        collectionView.register(WaterFlowMediumCell.self, forCellWithReuseIdentifier: "WaterFlowMediumCell")
        collectionView.register(WaterFlowSmallCell.self, forCellWithReuseIdentifier: "WaterFlowSmallCell")
        collectionView.register(WaterFlowHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader , withReuseIdentifier: "WaterFlowHeaderView")
        collectionView.register(WaterFlowFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter , withReuseIdentifier: "WaterFlowFooterView")

        return collectionView
    }()
    
    private var waterflowLayout: CMWaterFlowLayout = {
        let layout = CMWaterFlowLayout()
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        layout.flowLayoutType = .itemOrder
        
        return layout
    }()
    
    var listType: CMWaterFlowLayoutType = .minHeight {
        didSet {
            waterflowLayout.flowLayoutType = listType
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildView()
        setupLayout()
        configData()
    }
    
    func buildView() {
        switch listType {
        case .minHeight:
            self.title = "按高度排列"
        case .itemOrder:
            self.title = "按顺序排列"
        }
        self.view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        waterflowLayout.delegate = self
    }
    
    func setupLayout() {
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func configData() {
        for _ in 0..<4 {
            var items = [CellData]()
            for i in 0..<10 {
                if i % 2 == 0 {
                    items.append(CellData.init(title: "\(i)", type: .large))
                } else if i % 3 == 0 {
                    items.append(CellData.init(title: "\(i)", type: .medium))
                } else {
                    items.append(CellData.init(title: "\(i)", type: .small))
                }
            }
            cellItems.append(items)
        }
    }
}

extension WaterFlowVC: UICollectionViewDelegate {
    
}

extension WaterFlowVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellItems[section].count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return cellItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = cellItems[indexPath.section][indexPath.item]
        switch item.type {
        case .small:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterFlowSmallCell", for: indexPath) as? WaterFlowSmallCell else { return UICollectionViewCell() }
            cell.config(color: UIColor.red, title: item.title)
            return cell
        case .medium:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterFlowMediumCell", for: indexPath) as? WaterFlowMediumCell else { return UICollectionViewCell() }
            cell.config(color: UIColor.purple, title: item.title)
            return cell
        case .large:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WaterFlowLargeCell", for: indexPath) as? WaterFlowLargeCell else { return UICollectionViewCell() }
            cell.config(color: UIColor.green, title: item.title)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WaterFlowHeaderView", for: indexPath) as? WaterFlowHeaderView else { return UICollectionReusableView() }
            header.label.text = "Header\(indexPath.section)"
            return header
        } else if kind == UICollectionView.elementKindSectionFooter {
            guard let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "WaterFlowFooterView", for: indexPath) as? WaterFlowFooterView else { return UICollectionReusableView() }
            footer.label.text = "Footer\(indexPath.section)"
            return footer
        }
        
        return UICollectionReusableView()
    }
    
}

extension WaterFlowVC: CMWaterFlowLayoutDelegate {
    func heightForItem(layout: CMWaterFlowLayout, indexPath: IndexPath) -> CGFloat {
        let item = cellItems[indexPath.section][indexPath.item]
        switch item.type {
        case .small:
           return 60
        case .medium:
           return 90
        case .large:
           return 120
        }
    }
    
    func insetForSection(layout: CMWaterFlowLayout, section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }
    
    func referenceSizeForHeader(layout: CMWaterFlowLayout, section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 70)
        } else if section == 1 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 40)
        } else if section == 2 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 90)
        } else {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 20)
        }
    }
    
    func referenceSizeForFooter(layout: CMWaterFlowLayout, section: Int) -> CGSize {
        if section == 0 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 70)
        } else if section == 1 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 40)
        } else if section == 2 {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 90)
        } else {
            return CGSize(width: self.view.frame.width - 15 * 2, height: 20)
        }
    }
    
    func lineSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 12
    }
    
    func interItemSpacing(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 10
    }
    
    func spacingWithLastSection(layout: CMWaterFlowLayout, section: Int) -> CGFloat {
        return 15
    }
    
    func columnNumber(layout: CMWaterFlowLayout, section: Int) -> Int {
        if section == 0 {
            return 1
        } else if section == 1 {
            return 2
        } else if section == 2 {
            return 3
        } else {
            return 4
        }
    }
}
