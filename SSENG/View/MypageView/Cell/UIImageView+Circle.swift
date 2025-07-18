//
//  UIImageView+Circle.swift
//  SSENG
//
//  Created by 서광용 on 7/18/25.
//
import UIKit

extension UIImageView {
  func makeCircular() {
    layer.cornerRadius = frame.width / 2
    layer.borderWidth = 0.5
    layer.borderColor = UIColor.lightGray.cgColor
    clipsToBounds = true
  }
}
