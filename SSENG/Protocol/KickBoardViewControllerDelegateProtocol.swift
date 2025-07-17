//
//  KickBoardViewControllerDelegateProtocol.swift
//  SSENG
//
//  Created by 이태윤 on 7/17/25.
//
protocol KickBoardViewControllerDelegate: AnyObject {
  func didRegisterKickBoard(at latitude: Double, longitude: Double)
}
