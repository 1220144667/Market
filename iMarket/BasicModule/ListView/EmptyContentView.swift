//
//  EmptyContentView.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import UIKit
import SnapKit

//占位View的一些配置
struct EmptyConstant {
    //MARK:占位图
    static var coverImage: String = "empty_cover"
    // 占位图居中的偏移量
    static var imageOffsetY: CGFloat = 120.0
    // 占位图距描述间距
    static var imageTextMargin: CGFloat = 12.0
    //MARK:描述
    static var describe: String = "暂无数据~"
    // 描述的字体颜色
    static var describeColor: UIColor = .subTextColor
    // 描述居中偏移量
    static var describeOffsetX: CGFloat = 0.0
    // 按钮距描述的间距
    static var buttonTextMargin: CGFloat = 24.0
    //按钮title
    static var buttonName = "重新加载"
    //按钮的事件
    static var buttonType: EmptyActionType = .refresh
    // 按钮高
    static var buttonHeight: CGFloat = 32.0
    //后按钮字体颜色
    static var buttonTextColor: UIColor = .themColor
}

extension EmptyContentView {
    //不带按钮的类型
    static func show(delegate: MktEmptyProtocol) -> EmptyContentView {
        self.delegate = delegate
        if RequestManager.isNetworkConnect == false {
            EmptyConstant.coverImage = "empty_cover"
            EmptyConstant.describe = "数据加载失败，点击重试~"
            EmptyConstant.buttonName = "检查网络"
            EmptyConstant.buttonType = .checkNetwork
        } else if !Mkt.APP.isLogin {
            EmptyConstant.coverImage =  "empty_cover"
            EmptyConstant.describe = "未登录，点击去登录~"
            EmptyConstant.buttonName = "去登录"
            EmptyConstant.buttonType = .goLogin
        } else {
            EmptyConstant.coverImage =  "empty_cover"
            EmptyConstant.describe = "暂无数据~"
            EmptyConstant.buttonName = "重新获取"
            EmptyConstant.buttonType = .refresh
        }
        return EmptyContentView()
    }
}

class EmptyContentView: UIView {
    //代理
    static var delegate: MktEmptyProtocol?
    //初始化方法
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.coverImg)
        self.coverImg.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(-EmptyConstant.imageOffsetY)
            make.centerX.equalTo(self)
        }
        self.addSubview(self.descLabel)
        self.descLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImg.snp.bottom).offset(EmptyConstant.imageTextMargin)
            make.left.equalTo(16 + EmptyConstant.describeOffsetX)
            make.right.equalTo(-16)
        }
        self.addSubview(self.actionButton)
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.descLabel.snp.bottom).offset(EmptyConstant.buttonTextMargin)
            make.centerX.equalTo(self)
            make.width.equalTo(80)
            make.height.equalTo(EmptyConstant.buttonHeight)
        }
        //背景添加点击事件
        self.clickHandle { [weak self] sender in
            guard let self = self else { return }
            self.clickBackgroundAction()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let button_text = EmptyConstant.buttonName
        var width = Mkt.labelWithWidth(text: button_text, font: .systemFont(ofSize: 14)) + 32
        if width > Mkt.screenWidth - 32 {
            width = Mkt.screenWidth - 32
        }
        self.actionButton.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    //背景图
    lazy var coverImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: EmptyConstant.coverImage)
        return imageView
    }()
    //描述
    lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.text = EmptyConstant.describe
        descLabel.textColor = .subTextColor
        descLabel.textAlignment = .center
        descLabel.font = .systemFont(ofSize: 14)
        descLabel.numberOfLines = 4
        descLabel.clipsToBounds = true
        return descLabel
    }()
    //按钮
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(EmptyConstant.buttonName, for: .normal)
        button.setTitleColor(EmptyConstant.buttonTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.borderColor = EmptyConstant.buttonTextColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = EmptyConstant.buttonHeight/2.0
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(clickButtonAction(_:)), for: .touchUpInside)
        return button
    }()
}

//MARK：-点击事件-
extension EmptyContentView {
    //背景点击事件
    func clickBackgroundAction() {
        EmptyContentView.delegate?.didActionEvent(.refresh)
    }
    //按钮点击事件
    @objc func clickButtonAction(_ sender: UIButton) {
        let type = EmptyActionType(rawValue: sender.tag) ?? .refresh
        EmptyContentView.delegate?.didActionEvent(type)
    }
    
    /// 前往Wi-Fi设置页面
    func gotoSettings() {
        let urlStr:String = "App-Prefs:root=WIFI"
        let url = NSURL.init(string: urlStr)
        if UIApplication.shared.canOpenURL(url! as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url! as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url! as URL)
            }
        }
    }
}
