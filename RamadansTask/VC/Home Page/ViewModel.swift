//
//  ViewModel.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class ViewModel: VMRequestable {
    
    let userInfoObs: PublishRelay<UserModel?>
    let followersObs: BehaviorRelay<[UserModel]>
    let disposeBag = DisposeBag()
    var userFollowers: [UserModel] = []
    var isPaginationFailed: Bool = false
    
    init() {
        userInfoObs = PublishRelay()
        followersObs = BehaviorRelay(value: [])
        
        followersObs
            .subscribe(onNext: { followers in
                self.userFollowers = followers
            })
            .disposed(by: disposeBag)
    }
    
    func getUserInfo(userName: String) {
        
        let obs: VMResult<UserModel> = self.request(endpoint: EndPoints.getUserInfo(userName: userName))
            .retry(3)
        obs
            .subscribe(
                onNext: { [weak self] result in
                    switch result {
                    case .error(let error):
                        print(error)
                        self?.userInfoObs.accept(nil)
                    case .next(let elements):
                        self?.userInfoObs.accept(elements)
                    case .completed:
                        print("Completed")
                    }
                }
        )
            .disposed(by: disposeBag)
    }
    
    func getFollowing(userName: String, page: Int) {
        
        let obs: VMResult<[UserModel]> = self.request(endpoint: EndPoints.getUserFollowers(userName: userName, page: page))
            .retry(3)
        obs
            .subscribe(
                onNext: { [weak self] result in
                    switch result {
                    case .error(let error):
                        print(error)
                        self?.followersObs.accept([])
                    case .next(let elements):
                        if elements.count == 0 {
                            self?.isPaginationFailed = true
                        } else {
                            self?.userFollowers.append(contentsOf: elements)
                            self?.followersObs.accept(self?.userFollowers ?? [])
                            self?.isPaginationFailed = false
                        }
                        
                    case .completed:
                        print("Completed")
                    }
                }
        )
            .disposed(by: disposeBag)
    }
}
