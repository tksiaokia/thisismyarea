//
//  IssueTrackerModel.swift
//  ThisIsMyArea
//
//  Created by Sean Tee on 16/07/2019.
//  Copyright © 2019 Sean. All rights reserved.
//


import Foundation
import Moya
import Mapper
import Moya_ModelMapper
import RxSwift
import RxOptional

struct IssueTrackerModel {
    
    let provider: MoyaProvider<GitHub>
    let repositoryName: Observable<String>
    
    func trackIssues()->Observable<[Issue]>{
        return repositoryName
            .observeOn(MainScheduler.instance)
            .flatMapLatest { name -> Observable<Repository?> in
                print("Name: \(name)")
                return self
                    .findRepository(name: name)
            }
            .flatMapLatest { repository -> Observable<[Issue]?> in
                guard let repository = repository else { return Observable.just([]) }
                
                print("Repository: \(repository.fullName)")
                return self.findIssues(repository: repository)
            }.replaceNilWith([])
        
        
    }
    
    internal func findIssues(repository: Repository)->Observable<[Issue]?>{
        return self.provider
            .rx
            .request(GitHub.issues(repositoryFullName: repository.fullName))
            .debug()
            .mapOptional(to: [Issue].self).asObservable()
    }
    
    internal func findRepository(name: String)->Observable<Repository?> {
        return self.provider
            .rx
            .request(GitHub.repo(fullName: name))
            .debug()
            .mapOptional(to: Repository.self).asObservable()
    }
}
