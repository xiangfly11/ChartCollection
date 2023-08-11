//
//  WaterFlowMediumCell.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/7/18.
//

import Foundation
import UIKit

class WaterFlowMediumCell: WaterFlowBaseCell {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//extension WaterFlowMediumCell: CMCollectionViewCellDelegate {
//    func cellHeight(_ flowLayout: CMWaterFlowLayout, indexPath: IndexPath, text: String?) -> CGFloat {
//        return 90
//    }
//}
