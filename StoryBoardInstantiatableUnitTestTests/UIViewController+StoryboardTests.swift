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
        /// ViewControllerのファイル名取得
        ///
        /// - Parameters:
        ///   - fileName: ファイル名
        ///   - dirPath: ディレクトリパス
        func getAllFile(fileName: String?, dirPath: String) -> [String] {
            do {
                let files = try FileManager.default.contentsOfDirectory(atPath: dirPath)
                // TODO: ☠️この辺もっと上手く書けるはず...これはひどい
                // swiftファイルの配列作成
                let names: [String] = files.filter({ (file) -> Bool in
                    return file.hasSuffix(".swift")
                })
                // swiftファイルを含まないもの=ディレクトリ
                let notFiles: [String] = files.filter({ (file) -> Bool in
                    return !file.hasSuffix(".swift")
                })
                // ディレクトリの場合は再帰的にファイル名を取得
                let otherfiles: [String] = notFiles.map({ (file) -> [String] in
                    let path: String = {
                        guard let fileName = fileName else {
                            return dirPath
                        }
                        return "\(dirPath)/\(fileName)"
                    }()
                    return getAllFile(fileName: file, dirPath: path)
                }).flatMap({ (strs) -> [String] in
                    return strs
                })
                // ファイル名の配列を結合
                return names + otherfiles
            } catch {
                XCTFail()
                fatalError("\(error.localizedDescription)")
            }
        }
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
        let files = getAllFile(fileName: nil, dirPath: vcPath)
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
