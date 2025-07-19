//
//  SearchService.swift
//  SSENG
//
//  Created by 이태윤 on 7/20/25.
//
import Foundation
import Alamofire

// 네이버 지역 검색 API 호출
class SearchService {
  private let clientID: String
  private let clientSecret: String

  init() {
    self.clientID = Bundle.main.object(forInfoDictionaryKey: "NaverClientID") as? String ?? ""
    self.clientSecret = Bundle.main.object(forInfoDictionaryKey: "NaverClientSecret") as? String ?? ""
  }

  func search(query: String, completion: @escaping (Result<[Place], AFError>) -> Void) {
    let url = "https://openapi.naver.com/v1/search/local.json"
    let headers: HTTPHeaders = [
      "X-Naver-Client-Id": clientID,
      "X-Naver-Client-Secret": clientSecret
    ]
    let parameters: Parameters = [
      "query": query,
      "display": 10,
      "sort": "random"
    ]

    AF.request(url, parameters: parameters, headers: headers)
      .validate()
      .responseDecodable(of: SearchResponse.self) { response in
        switch response.result {
        case .success(let data):
          completion(.success(data.items))
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }
}
