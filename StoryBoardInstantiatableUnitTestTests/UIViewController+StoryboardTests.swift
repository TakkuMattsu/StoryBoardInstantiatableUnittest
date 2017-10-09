//
//  UIViewController+StoryboardTests.swift
//  StoryBoardInstantiatableUnitTestTests
//
//  Created by TakkuMattsu on 2017/10/08.
//  Copyright © 2017年 TakkuMattsu. All rights reserved.
//

import XCTest
@testable import StoryBoardInstantiatableUnitTest

class UIViewController_StoryboardTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    func test_ストーリボートからViewController作成() {
        // info.plistにViewControllerが置いてる場所のパスがあるのでそれを取得
        guard let infolist: [String : Any] = Bundle(for: UIViewController_StoryboardTests.self).infoDictionary, let vcPath =  infolist["Source Directory"] as? String else {
            XCTFail()
            return
        }
        /// 除外リスト
        let excludeList = [
            ViewController.className          // 起動Storyboardと結びついているので除外
        ]
        /// テスト
        let files = viewControllerFileNames(atPath: vcPath)
        print("ViewController数:\(files.count) うち除外:\(excludeList.count)")
        let testList = files.filter { (file) -> Bool in
            // 除外リスト
            excludeList.map({ (excludeClassName) -> Bool in
                file != "\(excludeClassName).swift"
            }).reduce(true, { (result, bool) -> Bool in
                result && bool
            })
            }.map { (file) in
                let fileName = (file as NSString).deletingPathExtension
                print("\(fileName)生成テスト")
                let className = Bundle.main.infoDictionary!["CFBundleName"] as! String + "." + fileName
                let aClass = NSClassFromString(className) as! UIViewController.Type
                let vc = aClass.instantiate()
                XCTAssertNotNil(vc, "\(className)")
        }
        // 全てテストできているか
        XCTAssertTrue(testList.count == (files.count - excludeList.count))
        print("実施:\(testList.count)")
        print("除外:\(excludeList.count)")
        excludeList.forEach { (file) in
            print("- \(file)")
        }
    }
}

private extension UIViewController_StoryboardTests {
    
    /// 指定ディレクトリ内の「ViewController.swift」が含まれているファイル名を取得
    ///
    /// - Parameter dirPath: ディレクトリパス
    /// - Returns: 「ViewController.swift」が含まれているファイル名の配列
    func viewControllerFileNames(atPath dirPath: String) -> [String] {
        
        var vcFileNames = [String]()
        var isDir: ObjCBool = false
        let vcSuffix = "ViewController.swift"
        let fileExists = FileManager.default.fileExists(atPath: dirPath, isDirectory: &isDir)
        
        if !fileExists {
            XCTFail("dirPath does not exist.")
        }
        if !isDir.boolValue {
            XCTFail("dirPath is not a directory.")
        }
        
        if let paths = FileManager.default.enumerator(atPath: dirPath) {
            while let path = paths.nextObject() as? String {
                if path.hasSuffix(vcSuffix) {
                    let fileName = (path as NSString).lastPathComponent
                    vcFileNames.append(fileName)
                }
            }
        }
        return vcFileNames
    }
}
