//
//  SearchModel.swift
//  SSENG
//
//  Created by 이태윤 on 7/20/25.
//
struct SearchResponse: Decodable {
  let items: [Place]
}
// 장소 정보
struct Place: Decodable {
  let title: String
  let category: String
  let description: String
  let address: String
  let roadAddress: String
  let lng: String // 경도
  let lat: String // 위도

  enum CodingKeys: String, CodingKey {
    case title
    case category
    case description
    case address
    case roadAddress
    case lng = "mapx"
    case lat = "mapy"
  }
}
