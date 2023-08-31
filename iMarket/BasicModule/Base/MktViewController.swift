//
//  MktViewController.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/31.
//

import UIKit

class MktViewController: UIViewController {
    
    //外部传进来的参数
    public var params: [String: Any]?
    //返回上个界面刷新的回调
    public var backHandle: ((_ data: [String : Any]?) -> Void)?
    //初始化
    required init() {
        super.init(nibName: nil, bundle: nil)
    }
    required init(_ para: [String : Any]?, _ block: (([String : Any]?) -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.params = para
        self.backHandle = block
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    //返回按钮点击回调
    typealias DidBackHandler = (_ viewController: UIViewController) -> Void
    
    private var backHandler: DidBackHandler?
    
    //系统方法
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        let count = self.navigationController?.viewControllers.count ?? 0
        if (count > 1) {
            self.navigationController?.navigationBar.isHidden = false
            let leftItem = UIBarButtonItem(image: UIImage(named: "icon_back"), style: .plain, target: self, action: #selector(backButtonEvent))
            self.navigationItem.leftBarButtonItem = leftItem;
        }
    }
    
    //将要显示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let count = self.navigationController?.viewControllers.count ?? 0
        self.navigationController?.navigationBar.isHidden = (count > 1) ? false : true
    }
    //view被点击
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    //返回按钮点击回调
    func didBackHandler(_ backHandler: @escaping DidBackHandler) {
        self.backHandler = backHandler
    }
    //返回按钮点击事件
    @objc func backButtonEvent() {
        //拦截返回按钮点击事件
        if (self.backHandler != nil) {
            self.backHandler?(self)
            return
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //用来标记当前控制器是否已释放
    deinit {
        dlog(message: "\(NSStringFromClass(Self.self)) dealloc")
    }
}
