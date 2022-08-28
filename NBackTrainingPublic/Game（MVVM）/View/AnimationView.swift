//
//  AnimationView.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/08/03.
//

import Foundation
import UIKit
import Lottie

struct LottieAnimation {
    static func makeAnimation(in view: UIView) -> AnimationView {
        let animationView = AnimationView(name: "99718-confetti-animation")
        animationView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        animationView.contentMode = .scaleToFill
        animationView.loopMode = .loop
        return animationView
    }
}
