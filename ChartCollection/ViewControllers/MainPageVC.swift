//
//  MainPageVC.swift
//  ChartCollection
//
//  Created by Jiaxiang Li on 2023/7/13.
//

import Foundation
import UIKit
import SnapKit
import RxSwift
import RxDataSources


struct ListDataSection {
    var sectionName: String
    var items: [String]
}

extension ListDataSection: SectionModelType {
    init(original: ListDataSection, items: [String]) {
        self = original
        self.items = items
    }
}

class MainPageVC: UIViewController {
    
    private var listDataArr: [ListDataSection] = {
        var listDataArr = [ListDataSection]()
        let listData = ListDataSection.init(sectionName: "瀑布流", items:["按顺序排列", "按高度排列"])
        listDataArr.append(listData)
        
        return listDataArr
    }()
    
    private var dataSource: RxTableViewSectionedReloadDataSource<ListDataSection>?
    
    private lazy var listView: UITableView = {
        let listView = UITableView.init(frame: .zero, style: .plain)
        listView.estimatedRowHeight = 50
        listView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        return listView
    }()
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        buildView()
        setupLayout()
        configData()
    }
    
    func buildView() {
        self.title = "ChartCollection"
        self.view.backgroundColor = .white
        view.addSubview(listView)
    }
    
    func setupLayout() {
        listView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.bottom.leading.trailing.equalToSuperview()
        }
    }
    
    func configData() {
        let dataSource1 = RxTableViewSectionedReloadDataSource<ListDataSection>(configureCell: {(ds, tv, indexPath, item) -> UITableViewCell in
            let cell = tv.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
            cell.textLabel?.text = item
            cell.selectionStyle = .none
            return cell
        }, titleForHeaderInSection: { (ds, index) -> String in
            return ds.sectionModels[index].sectionName
        }
        )
        
        Observable.just(listDataArr)
            .bind(to: listView.rx.items(dataSource: dataSource1))
            .disposed(by: disposeBag)
        
        self.dataSource = dataSource1
        
        listView.rx.itemSelected
            .subscribe(onNext: { indexPath in 
                if indexPath.section == 0 {
                    if indexPath.row == 0 {
                        let vc = WaterFlowVC()
                        vc.listType = .itemOrder
                        self.navigationController?.pushViewController(vc, animated: true)
                    } else if indexPath.row == 1 {
                        let vc = WaterFlowVC()
                        vc.listType = .minHeight
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            }).disposed(by: disposeBag)
    }
    
}
