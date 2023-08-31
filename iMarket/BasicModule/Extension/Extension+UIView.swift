//
//  Extension+UIView.swift
//  iMarket
//  UIView扩展
//  Created by 洪陪 on 2023/8/30.
//

import UIKit

//添加UIView点击事件
fileprivate typealias gesture = ((_ gesture: UITapGestureRecognizer)->())

extension UIView {

    @objc private func clickCallBack(_ sender: UITapGestureRecognizer) {
        self.actionBlock?(sender)
    }

    private struct RuntimeKey {
        static let actionBlock = UnsafeRawPointer.init(bitPattern: "actionBlock".hashValue)
    }
    
    private var actionBlock: gesture? {
        set {
            objc_setAssociatedObject(self, RuntimeKey.actionBlock!, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)
        }
        get {
            return  objc_getAssociatedObject(self, RuntimeKey.actionBlock!) as? gesture
        }
    }

    /// 点击事件
    func clickHandle(_ listener: @escaping ((_ sender: UITapGestureRecognizer)->())) {
        self.actionBlock = listener
        self.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickCallBack(_ :)))
        self.addGestureRecognizer(tap)
    }
 }
 

extension UIView {
    ///  清空view
    func removeAll() {
        self.subviews.forEach {
            $0.removeFromSuperview()
        }
       
        if self is UIStackView {
            (self as! UIStackView).arrangedSubviews.forEach{
               $0.removeFromSuperview()
            }
        }
    }
}



extension UIView {
    // MARK: - 可视化设置 添加圆角和边框(性能差) 性能高的:addCornerRadius
    @IBInspectable var cornerViewRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderViewWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    /// 像素宽度
    @IBInspectable var borderViewWidthPixel: CGFloat {
        get {
            return layer.borderWidth * UIScreen.main.scale
        }
        set {
            layer.borderWidth = newValue / UIScreen.main.scale
        }
    }
    
    @IBInspectable var borderViewColor: UIColor? {
        get {
            if let c = layer.borderColor {
                return UIColor(cgColor: c)
            }
            return nil
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    func setGradientColor(colors: [CGColor]) -> CAGradientLayer {
        // 渐变颜色
        let gradientLayer = CAGradientLayer()
        //设置渐变的主颜色（可多个颜色添加）
        gradientLayer.colors = colors
        //从左到右 的渐变
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0)
        gradientLayer.frame = frame
        //将gradientLayer作为子layer添加到主layer上
        return gradientLayer
    }
}

extension UIView {
    /// 添加多个View
    public func addSubviews(_ views: [UIView]) {
        views.forEach { [weak self] eachView in
            self?.addSubview(eachView)
        }
    }

    //TODO: 自适应方法
    /// 调整此视图的大小，使其适合最大的子视图
    public func resizeToFitSubviews() {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for someView in self.subviews {
            let aView = someView
            let newWidth = aView.x + aView.width
            let newHeight = aView.y + aView.height
            width = max(width, newWidth)
            height = max(height, newHeight)
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }

    /// 调整此视图的大小，使其适合最大的子视图
    public func resizeToFitSubviews(_ tagsToIgnore: [Int]) {
        var width: CGFloat = 0
        var height: CGFloat = 0
        for someView in self.subviews {
            let aView = someView
            if !tagsToIgnore.contains(someView.tag) {
                let newWidth = aView.x + aView.width
                let newHeight = aView.y + aView.height
                width = max(width, newWidth)
                height = max(height, newHeight)
            }
        }
        frame = CGRect(x: x, y: y, width: width, height: height)
    }

    /// 调整此视图的大小以适应其宽度。
    public func resizeToFitWidth() {
        let currentHeight = self.height
        self.sizeToFit()
        self.height = currentHeight
    }

    /// 调整此视图的大小以适应其高度。
    public func resizeToFitHeight() {
        let currentWidth = self.width
        self.sizeToFit()
        self.width = currentWidth
    }

    /// 视图原点的x坐标的getter和setter。
    public var x: CGFloat {
        get {
            return self.frame.origin.x
        } set(value) {
            self.frame = CGRect(x: value, y: self.y, width: self.width, height: self.height)
        }
    }

    /// 视图原点的y坐标的getter和setter。
    public var y: CGFloat {
        get {
            return self.frame.origin.y
        } set(value) {
            self.frame = CGRect(x: self.x, y: value, width: self.width, height: self.height)
        }
    }

    /// 视图的宽度的getter和setter。
    public var width: CGFloat {
        get {
            return self.frame.size.width
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: value, height: self.height)
        }
    }

    /// 视图的高度的getter和setter。
    public var height: CGFloat {
        get {
            return self.frame.size.height
        } set(value) {
            self.frame = CGRect(x: self.x, y: self.y, width: self.width, height: value)
        }
    }

    /// 视图最左边的x坐标的getter和setter。
    public var left: CGFloat {
        get {
            return self.x
        } set(value) {
            self.x = value
        }
    }

    /// 视图最右边的x坐标的getter和setter。
    public var right: CGFloat {
        get {
            return self.x + self.width
        } set(value) {
            self.x = value - self.width
        }
    }

    /// 视图最上边y坐标的getter和setter。
    public var top: CGFloat {
        get {
            return self.y
        } set(value) {
            self.y = value
        }
    }

    /// 视图最底部边缘的y坐标的getter和setter。
    public var bottom: CGFloat {
        get {
            return self.y + self.height
        } set(value) {
            self.y = value - self.height
        }
    }

    /// 获取和设置视图原点。
    public var origin: CGPoint {
        get {
            return self.frame.origin
        } set(value) {
            self.frame = CGRect(origin: value, size: self.frame.size)
        }
    }

    /// 获取和设置视图的center x。
    public var centerX: CGFloat {
        get {
            return self.center.x
        } set(value) {
            self.center.x = value
        }
    }

    /// 获取和设置视图的center y。
    public var centerY: CGFloat {
        get {
            return self.center.y
        } set(value) {
            self.center.y = value
        }
    }

    /// 获取和设置视图的size。
    public var size: CGSize {
        get {
            return self.frame.size
        } set(value) {
            self.frame = CGRect(origin: self.frame.origin, size: value)
        }
    }

    /// 获取从最左侧边缘向左偏移的值
    public func leftOffset(_ offset: CGFloat) -> CGFloat {
        return self.left - offset
    }

    /// 获取从最右侧侧边缘向左偏移的值
    public func rightOffset(_ offset: CGFloat) -> CGFloat {
        return self.right + offset
    }

    /// 向上的偏移量
    public func topOffset(_ offset: CGFloat) -> CGFloat {
        return self.top - offset
    }

    /// 向下的偏移量
    public func bottomOffset(_ offset: CGFloat) -> CGFloat {
        return self.bottom + offset
    }

    /// 将视图沿宽度向右对齐给定偏移量。
    public func alignRight(_ offset: CGFloat) -> CGFloat {
        return self.width - offset
    }

    /// 子视图重新布局
    public func reorderSubViews(_ reorder: Bool = false, tagsToIgnore: [Int] = []) -> CGFloat {
        var currentHeight: CGFloat = 0
        for someView in subviews {
            if !tagsToIgnore.contains(someView.tag) && !(someView ).isHidden {
                if reorder {
                    let aView = someView
                    aView.frame = CGRect(x: aView.frame.origin.x, y: currentHeight, width: aView.frame.width, height: aView.frame.height)
                }
                currentHeight += someView.frame.height
            }
        }
        return currentHeight
    }
    
    /// 移除所有子视图
    public func removeSubviews() {
        for subview in subviews {
            subview.removeFromSuperview()
        }
    }

    /// 在superview中水平居中
    public func centerXInSuperView() {
        guard let parentView = superview else {
            assertionFailure("EZSwiftExtensions Error: The view \(self) doesn't have a superview")
            return
        }

        self.x = parentView.width/2 - self.width/2
    }

    /// 在superview中垂直居中
    public func centerYInSuperView() {
        guard let parentView = superview else {
            assertionFailure("EZSwiftExtensions Error: The view \(self) doesn't have a superview")
            return
        }
        
        self.y = parentView.height/2 - self.height/2
    }

    /// 在superview中水平和垂直居中视图
    public func centerInSuperView() {
        self.centerXInSuperView()
        self.centerYInSuperView()
    }
}
