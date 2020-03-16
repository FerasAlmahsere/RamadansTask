//
//  APIManager.swift
//  RamadansTask
//
//  Created by Feras Almahsere on 3/16/20.
//  Copyright © 2020 Feras Almahsere. All rights reserved.
//

import Foundation
import RxSwift
import Alamofire
import Kingfisher

typealias VMResult<T> = Observable<Event<T>>

protocol VMRequestable {
    
    func request<T: Decodable>(endpoint: URLRequestConvertible) -> Observable<Event<T>>
    
}

extension VMRequestable {
    
    func request<T: Decodable>(endpoint: URLRequestConvertible) -> Observable<T>{

        return Observable<T>.create { observer in
            let request = AF.request(endpoint)
            
            request.validate(statusCode: 200...300).responseDecodable {
                (response: DataResponse<T, AFError>) in
                
                print("\n\n\n")
                print(request.cURLDescription())
                print("\n\n\n")
                print(response.debugDescription)
                
                switch response.result {
                case .success(let v):
                    observer.onNext(v)
                    observer.onCompleted()
                case .failure(let error):
                    if error.isResponseValidationError {
                        switch error.responseCode {
                        default: 
                        observer.onError(APIError.other(error, data: response.data))
                        }
                    }else if error.isSessionTaskError {
                        observer.onError(error)
                    }else if error.isParameterEncodingError {
                        observer.onError(APIError.badResponse)
                    }else {
                        observer.onError(error)
                    }
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
            
        }
    }
    
    func request<T: Decodable>(endpoint: URLRequestConvertible) -> VMResult<T>{
        return request(endpoint: endpoint)
            .materialize()
    }
}

extension UIImageView {
    
    func setImage(pth: String!, placeholder: UIImage! = nil, cacheKey: String! = nil) {
        guard let path = pth, let url = URL(string: path) else {
            self.image = placeholder
            return
        }
                
        let resource = ImageResource(downloadURL: url, cacheKey: cacheKey)
        kf.setImage(with: resource, placeholder: placeholder, options: KingfisherOptionsInfo.init(repeating: KingfisherOptionsInfoItem.cacheOriginalImage, count: 4), progressBlock: nil) { [weak self] (result) in
        }
    }
}
