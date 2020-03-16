//
//  ViewController.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var followersTitleLabel: UILabel!
    @IBOutlet weak var followersLabel: UILabel!
    @IBOutlet weak var followingTitleLabel: UILabel!
    @IBOutlet weak var followingLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var userFollowers: [UserModel] = []
    let viewModel = ViewModel()
    let disposeBag = DisposeBag()
    var nextPage: Int = 1
    var userName: String = ""
    
    // MARK: - View LifeCicle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
        setupCollectionView()
        setupBinding()
    }
    
    //MARK: - Setup Methods
    func setupViews() {
        followersTitleLabel.text = NSLocalizedString("Followers", comment: "Followers title label")
        followingTitleLabel.text = NSLocalizedString("Following", comment: "Following title label")
    }
    
    func setupCollectionView() {
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        
        let layoutFlow = UICollectionViewFlowLayout()
        let size = (UIScreen.main.bounds.width / 2) - 10
        
        layoutFlow.minimumInteritemSpacing = 10
        layoutFlow.minimumLineSpacing = 10
        layoutFlow.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
        layoutFlow.itemSize = CGSize(width: size, height: size)
        
        collectionView.setCollectionViewLayout(layoutFlow, animated: false)
    }
    
    //MARK: - Binding Method
    func setupBinding() {
        
        viewModel.userInfoObs
            .map { $0?.login }
            .asDriver(onErrorJustReturn: "")
            .drive(userNameLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userInfoObs
            .map { $0?.followers }
            .compactMap { "\($0 ?? 0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(followersLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userInfoObs
            .map { $0?.following }
            .compactMap { "\($0 ?? 0)"}
            .asDriver(onErrorJustReturn: "")
            .drive(followingLabel.rx.text)
            .disposed(by: disposeBag)
        
        viewModel.userInfoObs
            .map { $0?.avatarURL }
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: {[weak self] imgPath in
                guard let self = self else { return }
                self.userImage.setImage(pth: imgPath, placeholder: UIImage(named: "avatar-placeholder"))
            })
            .disposed(by: disposeBag)
        
        viewModel.followersObs.bind(to: collectionView.rx.items(cellIdentifier: "CollectionViewCell")) { index, users, cell in
            if let cell = cell as? CollectionViewCell {
                let vm = CollectionViewCellVM(viewModel: users)
                cell.configure(viewModel: vm)
            }
        }
        .disposed(by: disposeBag)
        
        searchBar
            .rx
            .text
            .orEmpty
            .throttle(3, latest: true, scheduler: MainScheduler.instance)
            .subscribe(onNext: { query in
                if query == "" {
                    self.resetData()
                }else {
                    self.userName = query
                    self.viewModel.getUserInfo(userName: query)
                    self.viewModel.getFollowing(userName: query, page: 1)
                    self.viewModel.isPaginationFailed = false
                }
            }).disposed(by: disposeBag)
        
        viewModel.followersObs
            .subscribe(onNext: { followers in
                self.userFollowers = followers
            })
            .disposed(by: disposeBag)
        
        collectionView.rx.willDisplayCell
            .subscribe(onNext: { cell, index in
                if !self.viewModel.isPaginationFailed {
                    if index.row == self.userFollowers.count - 2 {
                        print("next page")
                        self.nextPage+=1
                        print(self.nextPage)
                        self.viewModel.getFollowing(userName: self.userName, page: self.nextPage)
                    }
                }
            })
            .disposed(by: disposeBag)
    }
    
    //MARK: - Helping Methods
    func resetData() {
        self.userFollowers = []
        self.nextPage = 1
        self.userName = ""
        viewModel.followersObs.accept([])
        viewModel.userInfoObs.accept(nil)
    }
}
