//
//  AAPhotoBrowserProtocol.swift
//  uchain
//
//  Created by Fxxx on 2018/11/14.
//  Copyright © 2018 Fxxx. All rights reserved.
//

import Foundation
import UIKit

@objc public protocol AAPhotoBrowserProtocol {
    
    //需要显示图片的数量
    func numberOfPhotos(with browser: AAPhotoBrowser) -> Int
    //序号对应显示的图片
    func photo(of index: Int, with browser: AAPhotoBrowser) -> AAPhoto
    
    //当前显示的图片序号
    @objc optional func didDisplayPhoto(at index: Int, with browser: AAPhotoBrowser) -> Void
    //长按序号为index的图片，可以自己在这里添加一些菜单操作
    @objc optional func didLongPressPhoto(at index: Int, with browser: AAPhotoBrowser) -> Void
    
    //点击保存按钮，保存图片
    @objc optional func saveImageWithPhoto(at image: UIImage, with view: UIImageView) -> Void
    
}
