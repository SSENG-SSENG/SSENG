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
  weak var delegate: TermsViewControllerDelegate?
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
    navigationItem.rightBarButtonItem = UIBarButtonItem(
      title: "승낙",
      style: .done,
      target: self,
      action: #selector(didTapOk)
    )
    navigationItem.title = "이용약관"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: "거부",
      style: .done,
      target: self,
      action: #selector(didTapNo)
    )
  }

  // MARK: 버튼 기능
  @objc private func didTapOk() {
    delegate?.termsViewControllerDidAgree(self)
    dismiss(animated: true, completion: nil)
  }
  
  @objc private func didTapNo() {
    dismiss(animated: true, completion: nil)
  }
}
