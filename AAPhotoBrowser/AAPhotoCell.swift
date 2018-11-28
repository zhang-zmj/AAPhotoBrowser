//
//  AAPhotoCell.swift
//  uchain
//
//  Created by Fxxx on 2018/11/14.
//  Copyright © 2018 Fxxx. All rights reserved.
//

import UIKit
import Kingfisher

class AAPhotoCell: UICollectionViewCell {
    
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    weak var browser: AAPhotoBrowser?
    private var firstTouch: CGPoint?
    private var photo: AAPhoto!
    var index: Int = 0
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        self.clipsToBounds = true
        scrollView = UIScrollView.init(frame: self.contentView.bounds)
        scrollView.maximumZoomScale = 3.0
        scrollView.minimumZoomScale = 1.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.clipsToBounds = true
        self.contentView.addSubview(scrollView)
        imageView = UIImageView.init(frame: scrollView.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
//        imageView.isUserInteractionEnabled = true
        scrollView.addSubview(imageView)
        
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTapAction))
        doubleTap.numberOfTapsRequired = 2
        self.addGestureRecognizer(doubleTap)
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapAction))
        tap.require(toFail: doubleTap)
        self.addGestureRecognizer(tap)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(pacAction(pan:)))
        pan.delegate = self
        self.addGestureRecognizer(pan)
       
        let longPress = UILongPressGestureRecognizer.init(target: self, action: #selector(longPressAction(longPress:)))
        longPress.minimumPressDuration = 0.5
        self.addGestureRecognizer(longPress)
        
    }
    
    deinit {
//        print("PhotoCell销毁")
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        var frameToCenter = imageView.frame
        let boundsSize = scrollView.bounds.size
        
        if frameToCenter.width < boundsSize.width {
            frameToCenter.origin.x = (boundsSize.width - frameToCenter.width) / 2.0
        } else {
            frameToCenter.origin.x = 0.0
        }
        
        if frameToCenter.height < boundsSize.height {
            frameToCenter.origin.y = (boundsSize.height - frameToCenter.height) / 2.0
        } else {
            frameToCenter.origin.y = 0.0
        }
        
        if !frameToCenter.equalTo(imageView.frame) {
            imageView.frame = frameToCenter
        }
        
    }
    
    func setPhoto(photo: AAPhoto) {
        
        self.photo = photo
        scrollView.contentSize = CGSize.zero
        scrollView.zoomScale = 1.0
        imageView.frame = UIScreen.main.bounds
        imageView.image = nil
        
        guard photo.image == nil else {
            showImage(photo.image!)
            return
        }
        
        let placeHolder = photo.placeholderImage != nil ? photo.placeholderImage! : photo.originalView?.image
        if placeHolder != nil {
            showImage(placeHolder!)
        }
        
        guard photo.urlString != nil else {
            return
        }
        
        let view = self.contentView.viewWithTag(111)
        view?.removeFromSuperview()
        
        let progressView = AACircleProgressView.init(in: self.contentView)
        progressView.tag = 111
        weak var weakSelf = self
        KingfisherManager.shared.retrieveImage(with: URL.init(string: photo.urlString!)!, options: nil, progressBlock: { (receivedSize, totalSize) in
            progressView.setProgress(progress: Float(receivedSize / totalSize))
        }, completionHandler: { (image, error, cacheType, url) in
            
            progressView.removeFromSuperview()
            if image != nil {
                weakSelf?.showImage(image!)
            }
            
        })
        
    }
    
    func showImage(_ image: UIImage) {
        
        imageView.image = image
        imageView.frame = imageView.fitRect()
        let mode = photo.originalView?.contentMode
        if mode != nil && mode != imageView.contentMode {
            imageView.contentMode = mode!
        }
        
    }
    
    @objc func doubleTapAction() {
        let scale: CGFloat = scrollView.zoomScale < 2.0 ? 2.0 : 1.0
        scrollView.setZoomScale(scale, animated: true)
    }
    
    @objc func tapAction() {
        dissmissAction()
    }
    
    @objc func pacAction(pan: UIPanGestureRecognizer) {
        
        guard scrollView.zoomScale == 1 else {
            return
        }
        
        let translation = pan.translation(in: self.window!)
        let scale = 1.0 - abs(translation.y) / AAscreenH
        browser?.view.backgroundColor = UIColor.init(white: 0, alpha: scale)
        
        let fitRect = imageView.fitRect()
        let size = CGSize.init(width: fitRect.size.width * scale, height: fitRect.size.height * scale)
        let center = CGPoint.init(x: AAscreenW / 2 + translation.x, y: AAscreenH / 2 + translation.y)
        let origin = CGPoint.init(x: center.x - size.width / 2, y: center.y - size.height / 2)
        imageView.frame = CGRect.init(origin: origin, size: size)
        
//        let scaleTransform = CGAffineTransform.init(scaleX: CGFloat(scale), y: CGFloat(scale))
//        let translationTransform = CGAffineTransform.init(translationX: translation.x, y: translation.y)
//        self.transform = scaleTransform.concatenating(translationTransform)
        
        if pan.state == .ended || pan.state == .failed || pan.state == .cancelled {
            
            guard scale > 0.75 else {
                dissmissAction()
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.imageView.frame = self.imageView.fitRect()
                self.browser?.view.backgroundColor = UIColor.init(white: 0, alpha: 1.0)
            }
        }
        
    }
    
    @objc func longPressAction(longPress: UILongPressGestureRecognizer) {
        
        guard longPress.state == .began else {
            return
        }
        browser?.delegate.didLongPressPhoto?(at: index, with: browser!)
        
    }
    
    func dissmissAction() {
        
        browser?.dismiss(animated: true, completion: nil)
        browser = nil
        
    }
    
}

extension AAPhotoCell: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
}

extension AAPhotoCell: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        firstTouch = touch.location(in: self.window)
        return true
        
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        let location = gestureRecognizer.location(in: self.window)
        let horizontal = abs(location.x - firstTouch!.x)
        let vertical = abs(location.y - firstTouch!.y)
        return vertical > horizontal
        
    }
    
}

extension UIImageView {
    
    func fitRect() -> CGRect {
        
        guard self.image != nil else {
            return UIScreen.main.bounds
        }
        
        let imageSize = self.image!.size
        let whRate = imageSize.width / imageSize.height
        let rateScreen = AAscreenW / AAscreenH
        if whRate < rateScreen {
            
            let h = AAscreenH
            let w = h * whRate
            return CGRect.init(x: (AAscreenW - w) / 2.0, y: 0, width: w, height: h)
            
        } else {
            
            let w = AAscreenW
            let h = w / whRate
            return CGRect.init(x: 0, y: (AAscreenH - h) / 2.0, width: w, height: h)
            
        }
        
    }
    
}
