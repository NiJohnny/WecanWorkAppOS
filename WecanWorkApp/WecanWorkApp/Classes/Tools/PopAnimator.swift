//
//  PopAnimator.swift
//  WecanWorkApp
//
//  Created by erp on 2021/7/30.
//

import Foundation
import UIKit

class PopAnimator: NSObject,UIViewControllerAnimatedTransitioning {

    let duration = 1.0
    //动画持续时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    
    //动画执行的方法
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toView = transitionContext.view(forKey: UITransitionContextViewKey.to)
        containerView.addSubview(toView!)
        toView!.alpha = 0.0
        UIView.animate(withDuration: duration,
            animations: {
                toView!.alpha = 1.0
            }, completion: { _ in
                transitionContext.completeTransition(true)
        })
    }
    
}
