//
//  ListViewController.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 12/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MapKit
import Moya
class ListViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    let disposeBag = DisposeBag()
    var issueTrackerModel: IssueTrackerModel!
    var provider: MoyaProvider<GitHub>!
    var latestRepositoryName: Observable<String> {
        return searchBar
            .rx.text
            .orEmpty
            .debounce(0.5, scheduler: MainScheduler.instance)
            .distinctUntilChanged()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupRx()
//        for i in 0..<100{
//            geofences.append(GeofenceViewModel(geofence: Geofence(id: "\(i)", coordinate: CLLocationCoordinate2D(latitude: 3.122224, longitude: 101.674965), radius: 1, title:"Item \(i)")))
//        }
//           var geofences = [GeofenceViewModel]()
//
//        let items = BehaviorRelay(value:geofences)
//
//        items.asObservable()
//            .bind(to: tableView
//                .rx
//                .items(cellIdentifier:  GeofenCell.Identifier,
//                       cellType: GeofenCell.self)){ row, chocolate, cell in
//                        cell.configureWithChocolate(vm: chocolate)
//                        print(chocolate.geofence.title)
//            }.disposed(by: disposeBag)
//
//        tableView.rx
//            .itemSelected
//            .subscribe(onNext:  { path in
//                print("go to next \(path)")
//            })
//            .disposed(by: disposeBag)
//
//        tableView.rx
//            .modelDeleted(GeofenceViewModel.self)
//            .subscribe(onNext:  { value in
//                geofences.remove(at: 0)
//                items.accept(geofences)
//            })
//            .disposed(by: disposeBag)
        
    }
    
    func setupRx() {
        // First part of the puzzle, create our Provider
        provider = MoyaProvider()
        // Now we will setup our model
        issueTrackerModel = IssueTrackerModel(provider: provider, repositoryName: latestRepositoryName)
        
        // And bind issues to table view
        // Here is where the magic happens, with only one binding
        // we have filled up about 3 table view data source methods
        issueTrackerModel
            .trackIssues()
            .bind(to: tableView.rx.items) { tableView, row, item in
                let cell = tableView.dequeueReusableCell(withIdentifier: GeofenCell.Identifier, for: IndexPath(row: row, section: 0)) as! GeofenCell
                cell.label.text = item.title
                
                return cell
            }
            .disposed(by: disposeBag)
    
        
        // Here we tell table view that if user clicks on a cell,
        // and the keyboard is still visible, hide it
        tableView
            .rx.itemSelected
            .subscribe(onNext: { indexPath in
                if self.searchBar.isFirstResponder == true {
                    self.view.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
    }
   
}
