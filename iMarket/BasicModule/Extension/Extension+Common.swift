//
//  Extension+Common.swift
//  iMarket
//
//  Created by 洪陪 on 2023/8/30.
//

import Foundation
import UIKit
import CommonCrypto

extension String {
    var sha256: String {
        let utf8 = cString(using: .utf8)
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        CC_SHA256(utf8, CC_LONG(utf8!.count - 1), &digest)
        return digest.reduce("") { $0 + String(format:"%02x", $1) }
    }
    
    static func getCurrentDate(dateFormat: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let date = NSDate()
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = dateFormat
        let dateString = dateformatter.string(from: date as Date)
        return dateString
    }
    //MARK: -与当前时间比较 是否已过期
    static func compareToCurrentTime(time: Int) -> Bool {
        let currentTime = Date().timeIntervalSince1970
        let timeStamp = TimeInterval(time)
        return (currentTime > timeStamp)
    }
    //MARK: -根据后台时间戳返回几分钟前，几小时前，几天前
    static func compareCurrentTime(time: Int) -> String {
        //获取当前的时间戳
        let currentTime = Date().timeIntervalSince1970
        //时间戳转换
        let timeStamp = TimeInterval(time)
        //时间差
        let reduceTime = currentTime - timeStamp
        //时间差小于60秒
        if reduceTime < 60 {
            return "刚刚"
        }
        //时间差大于一分钟小于60分钟内
        let mins = Int(reduceTime / 60)
        if mins < 60 {
            return "\(mins)分钟前"
        }
        let hours = Int(reduceTime / 3600)
        if hours < 24 {
            return "\(hours)小时前"
        }
        let days = Int(reduceTime / 3600 / 24)
        if days < 30 {
            return "\(days)天前"
        }
        //不满足上述条件---或者是未来日期-----直接返回日期
        let date = NSDate(timeIntervalSince1970: timeStamp)
        let dfmatter = DateFormatter()
        //yyyy-MM-dd HH:mm:ss
        dfmatter.dateFormat="yyyy年MM月dd日 HH:mm:ss"
        return dfmatter.string(from: date as Date)
    }
}

//时间戳转字符串
extension Int {
    /// 时间戳转string：秒
    /// - Parameter format: 格式
    /// - Returns: 字符串时间
    public func timeStampToString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeSta: TimeInterval = TimeInterval(self)
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        let dateString = dateformatter.string(from: date as Date)
        return dateString
    }
    
    /// 时间戳转string：毫秒级
    /// - Parameter format: 格式
    /// - Returns: 字符串时间
    public func millisecondTimeStampToString(format: String = "yyyy-MM-dd HH:mm:ss") -> String {
        let timeSta: TimeInterval = TimeInterval(self / 1000)
        let date = NSDate(timeIntervalSince1970: timeSta)
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        let dateString = dateformatter.string(from: date as Date)
        return dateString
    }
}

extension UIControl {
    /// 添加点击事件
    /// - Parameters:
    ///   - target: target
    ///   - action: action
    public func addTarget(_ target: Any?, action: Selector) {
        self.addTarget(target, action: action, for: .touchUpInside)
    }
    //扩大点击区域  最大为44*44
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        var bounds: CGRect = self.bounds;
        //若点击区域小于44x44，则放大点击区域，否则保持原大小不变
        let widthDelta: CGFloat = max(44.0 - bounds.size.width, 0)
        let heightDelta: CGFloat  = max(44.0 - bounds.size.height, 0);
        bounds = bounds.insetBy(dx: -0.5*widthDelta, dy: -0.5*heightDelta)
        let isContain: Bool = bounds.contains(point)
        return isContain;
    }
}

extension UITextField {
    public func limit(shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard string == "." || string == "0" else {
            let newString = (self.text! as NSString).replacingCharacters(in: range, with: string)
            
            let expression = "^[0-9]{0,6}?$*((\\.|,)[0-9]{0,2})?$"
            let regex = try! NSRegularExpression(pattern: expression, options: NSRegularExpression.Options.allowCommentsAndWhitespace)
            let numberOfMatches = regex.numberOfMatches(in: newString, options:.reportProgress, range: NSMakeRange(0, (newString as NSString).length))
            return numberOfMatches != 0
        }
        guard let text = self.text else { return true }
        if text.range(of: ".") != nil && string == "." {
            return false
        }
        if text.range(of: ".") != nil{
            let list = self.text!.components(separatedBy: ".")
            let last = list.last!
            return (last as NSString).length < 2
        }
        return true
    }
}
