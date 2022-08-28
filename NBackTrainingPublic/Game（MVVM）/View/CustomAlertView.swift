//
//  CustomAlertView.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/08/03.
//

import Foundation
import UIKit
import Lottie

class ResultAlert {
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }
    
    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0
        return backgroundView
    }()
    
    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        alert.layer.borderColor = UIColor.white.cgColor
        alert.layer.borderWidth = 2
        return alert
    }()
    
    private let titleLabel: UILabel = {
        let resultLabel = UILabel()
        resultLabel.textColor = .white
        resultLabel.backgroundColor = .clear
        resultLabel.textAlignment = .center
        resultLabel.font = UIFont(name:"Helvetica", size: 50.0)
        return resultLabel
    } ()
    
    private let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.textColor = .white
        messageLabel.backgroundColor = .clear
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name:"Helvetica", size: 20.0)
        messageLabel.numberOfLines = 0
        return messageLabel
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("OK", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private var myTargetView: UIView?
    
    private var myAnimationView: AnimationView?
    
    func makeMessage(in result: Int) -> String {
        if result >= 80 {
           return "Congratulations\n1 back up"
        } else if result >= 60 {
           return "just right"
        } else {
           return "1 back down\n(least 3 back)"
        }
    }
    
    func show(with result: Int,
              on viewController: UIViewController) {
        guard let targerView = viewController.view else {
            return
        }
        
        myTargetView = targerView
        
        //Frame
        backgroundView.frame = targerView.bounds
        
        alertView.frame = CGRect(x: 40,
                                 y: -300,
                                 width: targerView.frame.size.width - 80,
                                 height: 300)

        titleLabel.frame = CGRect(x: 0,
                                  y: 10,
                                  width: alertView.frame.size.width,
                                  height: 80)
        
        messageLabel.frame = CGRect(x: 0,
                                     y: 80,
                                     width: alertView.frame.size.width,
                                     height: 170)
        
        button.frame = CGRect(x: 0,
                              y: alertView.frame.size.height - 50,
                              width: alertView.frame.size.width,
                              height: 50)
        
        titleLabel.text = "\(result)%"
        messageLabel.text = makeMessage(in: result)
        
        button
            .addTarget(
                self,
                action: #selector(dismissAlert),
                for: .touchUpInside
            )
        
        //MARK: subView
        targerView.addSubview(backgroundView)
        targerView.addSubview(alertView)
        alertView.addSubview(titleLabel)
        alertView.addSubview(messageLabel)
        alertView.addSubview(button)
        //GradientLayer
        let color = CAGradientLayer.colors(in: result)
        let layer = CAGradientLayer.gradientLayer(for: color, in: alertView.bounds)
        alertView.layer.insertSublayer(layer, at: 0)
        
        let animationView = LottieAnimation.makeAnimation(in: targerView)
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo
            if result >= 80 {
                self.myAnimationView = animationView
                animationView.play()
                targerView
                    .insertSubview(
                        animationView,
                        belowSubview: self.alertView
                    )
            }
        }) { done in
            if done  {
                UIView.animate(withDuration: 0.25) {
                    self.alertView.center = targerView.center
                }
            }
        }
        
    }
    
    @objc func dismissAlert() {
        guard let targetView = myTargetView else {
            return
        }
        
        UIView.animate(withDuration: 0.25, animations: {
            self.alertView.frame = CGRect(x: 40,
                                          y: targetView.frame.size.height,
                                          width: targetView.frame.size.width - 80,
                                          height: 300)
        }) { done in
            if done  {
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.alpha = 0
                }) { done in
                    if done {
                        self.myAnimationView?.stop()
                        
                        self.myAnimationView?.removeFromSuperview()
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                }
            }
        }
        
    }
}
