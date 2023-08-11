//
//  WaterFlowFooterView.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/7/20.
//

import Foundation
import UIKit

class WaterFlowFooterView: UICollectionReusableView {
    lazy var label: UILabel = {
        let label = UILabel()
        
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .yellow
        addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
