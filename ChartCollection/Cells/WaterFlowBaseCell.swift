//
//  WaterFlowBaseCell.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/7/18.
//

import Foundation
import UIKit
import SnapKit

//protocol CMCollectionViewCellDelegate {
//    func cellHeight(_ flowLayout: CMWaterFlowLayout, indexPath: IndexPath, text: String?) -> CGFloat
//}


class WaterFlowBaseCell: UICollectionViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        
        return view
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(containerView)
        containerView.addSubview(label)
        
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func config(color: UIColor, title: String) {
        containerView.backgroundColor = color
        label.text = title
    }
    
}
