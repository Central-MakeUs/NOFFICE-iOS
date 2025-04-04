//
//  WebViewController.swift
//  Router
//
//  Created by DOYEON LEE on 7/30/24.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate {

    var webView: WKWebView!
    var url: URL

    init(url: URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        // 웹뷰 생성
        webView = WKWebView()
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        // 웹뷰를 safe area에 맞추기
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // 웹페이지 로드
        let request = URLRequest(url: url)
        webView.load(request)
        
        // 사파리로 연결될 버튼 추가
//        let safariButton = UIButton(type: .system)
//        safariButton.setTitle("Open in Safari", for: .normal)
//        safariButton.addTarget(self, action: #selector(openInSafari), for: .touchUpInside)
//        safariButton.backgroundColor = .fullWhite
//        view.addSubview(safariButton)
//        
//        // 버튼 제약 조건 설정
//        safariButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            safariButton.bottomAnchor.constraint(
//                equalTo: view.safeAreaLayoutGuide.bottomAnchor,
//                constant: -20
//            ),
//            safariButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
    }
    
    @objc func openInSafari() {
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
