//
//  GuidanceView.swift
//  NBackTraining
//
//  Created by 山田　天星 on 2022/07/29.
//

import UIKit

class GuidanceViewController: UIViewController {
    
    let text = """
    ここには計算式が流れてきます。
    まずはじめにN個分の式を順に記憶します。
    N個は現在のレベルです。
    
    
    """
    
    let text22 = """
    ちなみにN個はこのBack数を指します。
    遡った式を回答するためNバックと呼ばれます。
    """
    
    let text11 = """
    どのような形か、試してみましょう。
    まずは3バック、3個の式を覚えてみましょう。
        
    実際のゲームの時は時間制限がありますが、
    いまは確認のため時間制限はありません。
    覚えたら次のボタンを押してください。
    """
    
    let text1 = """
    2問目です。
    """
    
    let text2 = """
    3問目です。1問目、2問目をまだ覚えていますか？
    """
    
    let text3 = """
    どうでしたか、覚えられましたか。
    ゲームでは常にはじめのN個分の式を覚えることになります。
    
    
    いままでは覚えるだけでしたが、実際のゲームに近づけて、今度は答えるも一緒にやってみましょう。
    
    ボタンをタップして計算式の答えを回答します。
    """
    
    let text4 = """
    ここが回答欄です、回答する段階になると計算式が伏字の状態で表示されます。
    回答すると、その式が公開されます。
    """
    
    let text5 = """
    
    """

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

