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
    var coverImage: String = "empty_cover"
    // 占位图居中的偏移量
    var imageOffsetY: CGFloat = 120.0
    // 占位图距描述间距
    var imageTextMargin: CGFloat = 12.0
    //MARK:描述
    var describe: String = "暂无数据~"
    // 描述的字体颜色
    var describeColor: UIColor = .subTextColor
    // 描述居中偏移量
    var describeOffsetX: CGFloat = 0.0
    // 按钮距描述的间距
    var buttonTextMargin: CGFloat = 24.0
    //按钮title
    var buttonName = "重新加载"
    //按钮的事件
    var buttonType: EmptyActionType = .refresh
    // 按钮高
    var buttonHeight: CGFloat = 32.0
    //后按钮字体颜色
    var buttonTextColor: UIColor = .themColor
}

extension EmptyContentView {
    //不带按钮的类型
    func show(delegate: MktEmptyProtocol, constant: EmptyConstant = EmptyConstant(), isCustom: Bool = false) -> EmptyContentView {
        self.delegate = delegate
        self.constant = constant
        if RequestManager.isNetworkConnect == false {
            self.constant.coverImage = "empty_cover"
            self.constant.describe = "数据加载失败，点击重试~"
            self.constant.buttonName = "检查网络"
            self.constant.buttonType = .checkNetwork
        } else if !Mkt.APP.isLogin {
            self.constant.coverImage =  "empty_cover"
            self.constant.describe = "未登录，点击去登录~"
            self.constant.buttonName = "去登录"
            self.constant.buttonType = .goLogin
        } else if isCustom {
            self.constant.coverImage =  "empty_cover"
            self.constant.describe = "自定义描述~"
            self.constant.buttonName = "自定义按钮"
            self.constant.buttonType = .refresh
        } else {
            self.constant.coverImage =  "empty_cover"
            self.constant.describe = "暂无数据~"
            self.constant.buttonName = "重新获取"
            self.constant.buttonType = .refresh
        }
        return EmptyContentView().commonInit()
    }
}

class EmptyContentView: UIView {
    
    private var constant = EmptyConstant()
    //代理
    private var delegate: MktEmptyProtocol?
    
    private func commonInit() -> EmptyContentView {
        self.addSubview(self.coverImg)
        self.coverImg.snp.makeConstraints { make in
            make.centerY.equalTo(self).offset(-self.constant.imageOffsetY)
            make.centerX.equalTo(self)
        }
        self.addSubview(self.descLabel)
        self.descLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverImg.snp.bottom).offset(self.constant.imageTextMargin)
            make.left.equalTo(16 + self.constant.describeOffsetX)
            make.right.equalTo(-16)
        }
        self.addSubview(self.actionButton)
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.descLabel.snp.bottom).offset(self.constant.buttonTextMargin)
            make.centerX.equalTo(self)
            make.width.equalTo(80)
            make.height.equalTo(self.constant.buttonHeight)
        }
        return self
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        let button_text = self.constant.buttonName
        var width = Mkt.labelWithWidth(text: button_text, font: .systemFont(ofSize: 14)) + 32
        if width > Mkt.screenWidth - 32 {
            width = Mkt.screenWidth - 32
        }
        self.actionButton.snp.updateConstraints { make in
            make.width.equalTo(width)
        }
    }
    
    //按钮点击事件
    @objc func clickButtonAction() {
        switch self.constant.buttonType {
        case .goLogin:
            Mkt.APP.pushLoginViewController()
        case .checkNetwork:
            Mkt.openWifi()
        case .refresh:
            self.delegate?.didReloadData()
        }
    }
    
    //背景图
    lazy var coverImg: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: self.constant.coverImage)
        return imageView
    }()
    //描述
    lazy var descLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.text = self.constant.describe
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
        button.setTitle(self.constant.buttonName, for: .normal)
        button.setTitleColor(self.constant.buttonTextColor, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14)
        button.layer.borderColor = self.constant.buttonTextColor.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = self.constant.buttonHeight/2.0
        button.layer.masksToBounds = false
        button.addTarget(self, action: #selector(clickButtonAction), for: .touchUpInside)
        return button
    }()
}
