//
//  Common.swift
//  iMarket
//
//  Created by 洪陪 on 2023/9/1.
//

import Foundation

/// 有参数的闭包
public typealias MktParamClosure<T> = (_ res: T?) -> Void
/// 无参数的闭包
public typealias MktParamlessClosure = () -> Void
