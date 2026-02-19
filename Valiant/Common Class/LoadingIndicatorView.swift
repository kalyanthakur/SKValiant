//
//  LoadingIndicatorView.swift
//  Valiant
//
//  Created by Kalyan Thakur on 02/02/26.
//


import UIKit

class LoadingIndicatorView {
    
    static var currentOverlay: UIView?
    
    // MARK: - Public Show Methods
    static func show() {
        guard let currentMainWindow = Self.keyWindow else { return }
        show(currentMainWindow)
    }
    
    static func show(_ loadingText: String) {
        guard let currentMainWindow = Self.keyWindow else { return }
        show(currentMainWindow, loadingText: loadingText)
    }
    
    static func show(_ overlayTarget: UIView) {
        show(overlayTarget, loadingText: nil)
    }
    
    static func show(_ overlayTarget: UIView, loadingText: String?) {
        hide() // Clear existing overlay
        
        // Overlay setup
        let overlay = UIView(frame: overlayTarget.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        overlay.alpha = 0
        overlayTarget.addSubview(overlay)
        overlayTarget.bringSubviewToFront(overlay)
        
        // Activity Indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)
        
        // Optional Text Label
        if let text = loadingText, !text.isEmpty {
            let label = UILabel()
            label.text = text
            label.textColor = .white
            label.font = .systemFont(ofSize: 15, weight: .medium)
            label.sizeToFit()
            label.center = CGPoint(x: indicator.center.x, y: indicator.center.y + 40)
            overlay.addSubview(label)
        }
        
        // Fade in animation
        UIView.animate(withDuration: 0.25) {
            overlay.alpha = 1
        }
        
        currentOverlay = overlay
    }
    
    // MARK: - Hide Method
    static func hide() {
        guard let overlay = currentOverlay else { return }
        UIView.animate(withDuration: 0.25, animations: {
            overlay.alpha = 0
        }) { _ in
            overlay.removeFromSuperview()
            currentOverlay = nil
        }
    }
    
    // MARK: - Private Helper
    private static var keyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first(where: { $0.isKeyWindow })
    }
}
