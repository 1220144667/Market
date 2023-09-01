//
//  RefreshGradientTextHeader.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

class RefreshGradientTextHeader: MJRefreshHeader {
    
    //重写prepare
    override func prepare() {
        super.prepare()
        // 设置控件的高度
        self.height = 50;
        
        self.addSubview(self.textColorView)
        
        self.mask = self.textLabel
    }
    
    func feedbackOccured() {
        let impactLight = UIImpactFeedbackGenerator(style: .light)
        impactLight.impactOccurred()
    }
    
    override var state: MJRefreshState {
        didSet {
            switch state {
            case .idle:
                self.gradientColorLayer.removeAllAnimations()
                self.gradientColorLayer.removeFromSuperlayer()
            case .pulling:
                self.feedbackOccured()
            case .refreshing:
                if state != .pulling {
                    self.feedbackOccured()
                }
                self.gradientColorLayer.add(self.locationsAnimation, forKey: nil)
                self.layer.addSublayer(self.gradientColorLayer)
            default:
                break
            }
        }
    }
    
    override func placeSubviews() {
        super.placeSubviews()
        self.textLabel.frame = CGRect(x: (self.width - self.textLabel.width)/2, y: (self.height - self.textLabel.height)/2, width: self.textLabel.width, height: self.textLabel.height)
        self.gradientColorLayer.frame = self.textLabel.frame
    }
    
    override var pullingPercent: CGFloat {
        didSet {
            let paddingPercent = self.textLabel.y / self.height;
            let percent = max(0, self.pullingPercent - paddingPercent)
            self.textColorView.width = self.width
            self.textColorView.height = self.height * percent
            self.textColorView.y = self.height - self.textColorView.height
        }
    }
    
    //懒加载
    lazy var textLabel: UILabel = {
        let label = UILabel()
        label.text = Mkt.appName
        label.textAlignment = .center
        label.font = UIFont(name: "", size: 30)
        label.sizeToFit()
        return label
    }()
    lazy var textColorView: UIView = {
        let view = UIView()
        view.backgroundColor = .colorToHex("#A87676");
        return view
    }()
    lazy var gradientColorLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [UIColor.lightGray.cgColor, UIColor.red.cgColor, UIColor.lightGray.cgColor]
        layer.locations = [NSNumber(floatLiteral: -0.2), NSNumber(floatLiteral: -0.1), NSNumber(floatLiteral: -0)]
        layer.startPoint = CGPointMake(0, 0.6);
        layer.endPoint = CGPointMake(1, 0.4);
        return layer
    }()
    lazy var locationsAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "locations")
        animation.fromValue = [NSNumber(floatLiteral: -0.2), NSNumber(floatLiteral: -0.1), NSNumber(floatLiteral: -0)]
        animation.toValue = [NSNumber(floatLiteral: 1.0), NSNumber(floatLiteral: 1.1), NSNumber(floatLiteral: 1.2)]
        animation.duration = 0.5
        animation.repeatCount = MAXFLOAT
        return animation
    }()
}
