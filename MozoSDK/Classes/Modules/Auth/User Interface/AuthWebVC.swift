//
//  AuthWebVC.swift
//  MozoSDK
//
//  Created by MAC on 15/04/2022.
//

import CommonCrypto.CommonDigest
import Foundation
import WebKit
import MBProgressHUD

class AuthWebVC: UIViewController, WKNavigationDelegate, WKUIDelegate {
    private let webview = WKWebView()
    private let callbackScheme = Configuration.authRedirectURL()
    private var codeVerifier: String!
    private var clientId: String!
    private var loadingHub: MBProgressHUD?
    
    /*! @brief Number of random bytes generated for the @ state.*/
    private let kStateSizeBytes = 32;

    /*! @brief Number of random bytes generated for the @ codeVerifier.*/
    private let kCodeVerifierBytes = 32;
    
    private var isSignOut: Bool = false
    
    override func loadView() {
        let root = UIView()
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.allowsBackForwardNavigationGestures = false
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.scrollView.delegate = self
        
        root.addSubview(webview)
        NSLayoutConstraint.activate([
            webview.leadingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.leadingAnchor),
            webview.topAnchor.constraint(equalTo: root.topAnchor),
            webview.rightAnchor.constraint(equalTo: root.safeAreaLayoutGuide.rightAnchor),
            webview.bottomAnchor.constraint(equalTo: root.bottomAnchor)
        ])
        
        let btnCancel = UIButton()
        btnCancel.setTitle("Cancel".localized, for: .normal)
        btnCancel.setTitleColor(ThemeManager.shared.primary, for: .normal)
        btnCancel.addTarget(self, action: #selector(touchedCancel), for: .touchUpInside)
        btnCancel.translatesAutoresizingMaskIntoConstraints = false
        root.addSubview(btnCancel)
        NSLayoutConstraint.activate([
            btnCancel.widthAnchor.constraint(equalToConstant: 100),
            btnCancel.heightAnchor.constraint(equalToConstant: 48),
            btnCancel.trailingAnchor.constraint(equalTo: root.safeAreaLayoutGuide.trailingAnchor),
            btnCancel.topAnchor.constraint(equalTo: root.safeAreaLayoutGuide.topAnchor)
        ])
        
        self.view = root
    }
    
    override func viewDidLoad() {
        // MARK: Build Sign In Request
        let authEndpoint = Configuration.AUTH_ISSSUER.appending(Configuration.BEGIN_SESSION_URL_PATH)
        codeVerifier = self.randomURLSafeStringWithSize(kCodeVerifierBytes)
        let codeChallenge = self.codeChallengeS256ForVerifier(code: codeVerifier)
        clientId = MozoSDK.appType == .Retailer ? Configuration.AUTH_RETAILER_CLIENT_ID : Configuration.AUTH_SHOPPER_CLIENT_ID
        guard var authUrlComponent = URLComponents(string: authEndpoint) else {
            self.touchedCancel()
            return
        }
        authUrlComponent.queryItems = [
            URLQueryItem(name: "redirect_uri", value: callbackScheme),
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "application_type", value: "native"),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "prompt", value: "consent"),
            URLQueryItem(name: "nonce", value: self.randomURLSafeStringWithSize(kStateSizeBytes)),
            URLQueryItem(name: "state", value: self.randomURLSafeStringWithSize(kStateSizeBytes)),
            URLQueryItem(name: "scope", value: "openid profile phone"),
            URLQueryItem(name: "kc_locale", value: Configuration.LOCALE.replace("_", withString: "-"))
        ]
        let signInUrl = authUrlComponent.url
        var finalUrl = signInUrl
        
        if isSignOut {
            // MARK: Build Log Out Request
            let signOutEndpoint = Configuration.LOGOUT_URL_WITH_REDIRECT_URI
            guard var urlComponent = URLComponents(string: signOutEndpoint) else {
                self.touchedCancel()
                return
            }
            urlComponent.queryItems = authUrlComponent.queryItems
            let index = urlComponent.queryItems?.firstIndex { i in
                i.name == "redirect_uri"
            }
            if index != nil, index! >= 0 {
                urlComponent.queryItems?.remove(at: index!)
            }
            urlComponent.queryItems?.append(
                URLQueryItem(name: "redirect_uri", value: signInUrl?.absoluteString ?? callbackScheme)
            )
            finalUrl = urlComponent.url
        }
        
        guard let url4Launch = finalUrl else {
            self.touchedCancel()
            return
        }
        DispatchQueue.main.async {
            self.webview.load(URLRequest(url: url4Launch))
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        loadingHub = nil
    }
    
    private func handleResponse(_ responseUrl: String) {
        guard let response = URLComponents(string: responseUrl), let queries = response.queryItems else {
            self.handleAuthFailed()
            return
        }
        
        var code = ""
        queries.forEach { q in
            if let value = q.value, q.name == "code" {
                code = value
            }
        }
        if code.isEmpty {
            self.handleAuthFailed()
            return
        }
        
        self.showLoading()
        _ = ApiManager.shared.requestToken(
            authorizationCode: code,
            codeVerifier: self.codeVerifier,
            clientId: self.clientId,
            redirectUri: callbackScheme
        ).done { res -> Void in
            self.handleAuthSuccess(res)
        }.catch { e in
            self.handleAuthFailed(e)
        }
    }
    
    private func handleAuthSuccess(_ token: AccessToken) {
        AccessTokenManager.save(token)
        self.loadingHub?.hide(animated: true)
        self.dismiss(animated: true) {
            ModuleDependencies.shared.authPresenter.finishedAuthenticate(accessToken: token.accessToken)
            ModuleDependencies.shared.authManager.setupRefreshTokenTimer()
        }
    }
    
    private func handleAuthFailed(_ error: Error? = nil) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05, execute: {
            self.loadingHub?.hide(animated: true)
            self.dismiss(animated: true) {
                ModuleDependencies.shared.authPresenter.errorWhileExchangeCode(
                    error: error as? ConnectionError ?? .systemError
                )
            }
        })
        
        
        /*
         var networkError = error != nil ? ConnectionError.network(error: error!) : .systemError
         // ID Token expired
         if let nsError = error as NSError?, nsError.code == -15 {
             networkError = .incorrectSystemDateTime
         } else {
             if let error = error {
                 if error.localizedDescription.contains("PKCE") || error.localizedDescription.contains("invalid") {
                     networkError = .authenticationRequired
                 }
             }
         }
         seal.reject(networkError)
         */
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url?.absoluteString, url.lowercased().starts(with: callbackScheme.lowercased()) {
            decisionHandler(.cancel)
            self.handleResponse(url)
            return
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if error.localizedDescription.contains("certificate") {
            let alert = UIAlertController(title: "There is an error occurred.".localized, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { action in
                self.touchedCancel()
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    private func randomURLSafeStringWithSize(_ size: Int) -> String? {
        guard let randomData = NSMutableData(length: size) else {
            return nil
        }
        let result = SecRandomCopyBytes(kSecRandomDefault, randomData.length, randomData.mutableBytes)
        if result != 0 {
            return nil
        }
        return encodeBase64urlNoPadding(randomData)
    }
    
    private func codeChallengeS256ForVerifier(code: String?) -> String? {
        guard let codeVerifier = code, let sha256Verifier = self.sha256(codeVerifier) else { return nil }
        return self.encodeBase64urlNoPadding(sha256Verifier)
    }
    
    private func encodeBase64urlNoPadding(_ data: NSData) -> String {
        var base64string = data.base64EncodedString(options: .lineLength64Characters)
        base64string = base64string.replacingOccurrences(of: "+", with: "-")
        base64string = base64string.replacingOccurrences(of: "/", with: "_")
        base64string = base64string.replacingOccurrences(of: "=", with: "")
        return base64string
    }
    
    private func sha256(_ input: String) -> NSData? {
        guard let verifierData = input.data(using: .utf8),
              let sha256Verifier = NSMutableData(length: Int(CC_SHA256_DIGEST_LENGTH))
        else { return nil }
        
        let pointer = sha256Verifier.mutableBytes.bindMemory(to: UInt8.self, capacity: verifierData.count)
        CC_SHA256(verifierData.bytes, CC_LONG(verifierData.count), pointer)
        return sha256Verifier
    }
    
    private func showLoading() {
        loadingHub = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingHub?.isUserInteractionEnabled = true
    }
    
    @objc func touchedCancel() {
        loadingHub?.hide(animated: true)
        self.dismiss(animated: true) {
            ModuleDependencies.shared.authPresenter.cancelledAuthenticateByUser()
        }
    }
    
    class func signIn(_ parent: UIViewController) {
        if let lastVC = DisplayUtils.getTopViewController(), lastVC is AuthWebVC {
            return
        }
        let vc = AuthWebVC()
        vc.modalPresentationStyle = .fullScreen
        parent.present(vc, animated: true)
    }
    
    class func signOut(_ parent: UIViewController) {
        if let lastVC = DisplayUtils.getTopViewController(), lastVC is AuthWebVC {
            return
        }
        let vc = AuthWebVC()
        vc.modalPresentationStyle = .fullScreen
        vc.isSignOut = true
        parent.present(vc, animated: true)
    }
}
extension AuthWebVC: UIScrollViewDelegate {
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollView.zoomScale = 1.0
    }
}
