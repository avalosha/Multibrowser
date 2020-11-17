//
//  ViewController.swift
//  Project31
//
//  Created by Álvaro Ávalos Hernández on 14/11/20.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    @IBOutlet weak var addressBar: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    
    weak var activeWebView: WKWebView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setDefaultTitle()

        let add = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addWebView))
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteWebView))
        navigationItem.rightBarButtonItems = [delete, add]
    }
    
    func setDefaultTitle() {
        title = "Multibrowser"
    }
    
    func updateUI(for webView: WKWebView) {
        title = webView.title
        addressBar.text = webView.url?.absoluteString ?? ""
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.horizontalSizeClass == .compact {
            stackView.axis = .vertical
        } else {
            stackView.axis = .horizontal
        }
    }

}

extension ViewController: WKNavigationDelegate {
    
    @objc func addWebView() {
        let webView = WKWebView()
        webView.navigationDelegate = self

        stackView.addArrangedSubview(webView)

        let url = URL(string: "https://www.hackingwithswift.com")!
        webView.load(URLRequest(url: url))
        
        webView.layer.borderColor = UIColor.blue.cgColor
        selectWebView(webView)
        
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(webViewTapped))
        recognizer.delegate = self
        webView.addGestureRecognizer(recognizer)
    }
    
    @objc func deleteWebView() {
        if let webView = activeWebView {
            if let index = stackView.arrangedSubviews.firstIndex(of: webView) {
                //Se encontro el webView para remover del stack y destruirlo
                webView.removeFromSuperview()
                //Si se deseara conservar para volver abrirlo se usaria removeArrangedSubview()
                
                if stackView.arrangedSubviews.count == 0 {
                    //Restablecer el titulo por default
                    setDefaultTitle()
                } else {
                    var currentIndex = Int(index)
                    
                    //Sí es la ultima webView del stack, retroceder uno
                    if currentIndex == stackView.arrangedSubviews.count {
                        currentIndex = stackView.arrangedSubviews.count - 1
                    }
                    
                    //Buscar la webView en el nuevo indice y seleccionarla
                    if let newSelectedWebView = stackView.arrangedSubviews[currentIndex] as? WKWebView {
                        selectWebView(newSelectedWebView)
                    }
                }
            }
        }
    }
    
    func selectWebView(_ webView: WKWebView) {
        for view in stackView.arrangedSubviews {
            view.layer.borderWidth = 0
        }
        
        activeWebView = webView
        webView.layer.borderWidth = 3
        
        updateUI(for: webView)
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if webView == activeWebView {
            updateUI(for: webView)
        }
    }
}

extension ViewController: UITextFieldDelegate {
    
    //Se activara cuando el usuario de Enter
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let webView = activeWebView, var address = addressBar.text {
            if !address.hasPrefix("https://") || !address.hasPrefix("http://") {
                address = "https://\(address)"
            }
            if let url = URL(string: address) {
                webView.load(URLRequest(url: url))
            }
        }
        //Oculta el teclado
        textField.resignFirstResponder()
        return true
    }
    
//    func verifyUrl (urlString: String?) -> Bool {
//       if let urlString = urlString {
//           if let url = NSURL(string: urlString) {
//               return UIApplication.shared.canOpenURL(url as URL)
//           }
//       }
//       return false
//   }
}

extension ViewController: UIGestureRecognizerDelegate {
    
    @objc func webViewTapped(_ recognizer: UITapGestureRecognizer) {
        if let selectedWebView = recognizer.view as? WKWebView {
            selectWebView(selectedWebView)
        }
    }
    
    //Activar los reconocedores de gestos con los propios de WKWebView
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
