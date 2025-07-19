//
//  LogoTransitionAnimator.swift
//  SSENG
//
//  Created by luca on 7/19/25.
//

import ObjectiveC
import UIKit

class LogoTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
  private let operation: UINavigationController.Operation

  init(operation: UINavigationController.Operation) {
    self.operation = operation
    // super.init()
  }

  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.4
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let fromVC = transitionContext.viewController(forKey: .from),
      let toVC = transitionContext.viewController(forKey: .to),
      let containerView = transitionContext.containerView as UIView?
    else {
      transitionContext.completeTransition(false)
      return
    }

    let fromLogo: UIImageView
    let toLogo: UIImageView

    if operation == .push,
      let loginVC = fromVC as? LoginViewController,
      let signVC = toVC as? SignViewController
    {
      fromLogo = loginVC.appLogoImageView
      toLogo = signVC.appLogoImageView
    } else if operation == .pop,
      let signVC = fromVC as? SignViewController,
      let loginVC = toVC as? LoginViewController
    {
      fromLogo = signVC.appLogoImageView
      toLogo = loginVC.appLogoImageView
    } else {
      transitionContext.completeTransition(false)
      return
    }

    let fromFrame = fromLogo.superview!.convert(fromLogo.frame, to: containerView)
    containerView.addSubview(toVC.view)
    toVC.view.setNeedsLayout()
    toVC.view.layoutIfNeeded()

    let toFrame = toLogo.superview!.convert(toLogo.frame, to: containerView)

    let movingLogo = UIImageView(image: fromLogo.image)
    movingLogo.contentMode = fromLogo.contentMode
    movingLogo.frame = fromFrame
    containerView.addSubview(movingLogo)

    fromLogo.isHidden = true
    toLogo.isHidden = true
    // toVC.view.alpha = (operation == .push) ? 0 : 1
    toLogo.alpha = 0
    toVC.view.alpha = 0
    movingLogo.layer.zPosition = 999

    UIView.animate(
      withDuration: transitionDuration(using: transitionContext),
      animations: {
        movingLogo.frame = toFrame
        toVC.view.alpha = 1
        // fromVC.view.alpha = 0
      },
      completion: { _ in
        fromLogo.isHidden = false
        toLogo.isHidden = false
        toLogo.alpha = 1
        movingLogo.removeFromSuperview()

        if self.operation == .push {
          if let signVC = toVC as? SignViewController {
            signVC.animateContentAppearance()
          }
        } else if self.operation == .pop {
          if let loginVC = toVC as? LoginViewController {
            loginVC.animateContentAppearance()
          }
        }

        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
      }
    )
  }
}
