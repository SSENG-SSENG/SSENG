//
//  TermsViewController.swift
//  SSENG
//
//  Created by luca on 7/17/25.
//

import UIKit

protocol TermsViewControllerDelegate: AnyObject {
  func termsViewControllerDidAgree(_ controller: TermsViewController)
}

class TermsViewController: UIViewController {
  // 동의 버튼 눌렀을 때 SignViewController의 checkbox를 누르기 위한 탐지
  weak var delegate: TermsViewControllerDelegate?
  
  // 이용약관
  private let termsTextView = UITextView().then {
    $0.isEditable = false
    $0.isScrollEnabled = true
    $0.font = .systemFont(ofSize: 16)
    $0.text = """
      '쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      쌩(이하 갑)'은 전동 킥보드 대여 서비스 애플리케이션입니다.
      갑이 진리입니다. 사고나도 책임지지 않습니다.
      감사합니다.
      
      """
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    
    setupUI()
    setupConstraints()
    setupButtonActions()
  }
  
  private func setupUI() {
    view.addSubview(termsTextView)
  }
  
  private func setupConstraints() {
    termsTextView.snp.makeConstraints {
      $0.leading.trailing.equalToSuperview().inset(10)
      $0.top.bottom.equalTo(view.safeAreaLayoutGuide)
    }
  }

  // MARK: 버튼 addTarget
  private func setupButtonActions() {
    // 상단 내비게이션 타이틀
    navigationItem.title = "이용약관"
    
    // 상단 우측 버튼
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "동의",
      style: .done,
      target: self,
      action: #selector(didTapOk)
    )
    
    // 상단 좌측 버튼
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "거부",
      style: .done,
      target: self,
      action: #selector(didTapNo)
    )
  }

  // MARK: 버튼 기능
  // 모달 OK 버튼(동의) 눌렀을 때 기능
  @objc private func didTapOk() {
    delegate?.termsViewControllerDidAgree(self)
    dismiss(animated: true, completion: nil)
  }
  
  // 모달 Reject 버튼(거부) 눌렀을 때 기능
  @objc private func didTapNo() {
    dismiss(animated: true, completion: nil)
  }
}
