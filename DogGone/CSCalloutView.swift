//
//  CSCalloutView.swift
//  DogGone
//
//  Created by Love Mob on 12/11/16.
//  Copyright © 2016 Love Mob. All rights reserved.
//

import UIKit
import MapKit

class CSCalloutView: CalloutView {
    
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
//        label.font = .preferredFont(forTextStyle: .callout)
        label.font = UIFont(name: "Avenir Next Condensed", size: 20.0)
        
        return label
    }()
    init(annotation: MKShape) {
        super.init()
        
        configure()
        
        updateContents(for: annotation)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Should not call init(coder:)")
    }
    
    /// Update callout contents
    
    private func updateContents(for annotation: MKShape) {
        titleLabel.text = annotation.title ?? "Unknown"
    }
    
    /// Add constraints for subviews of `contentView`
    
    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(titleLabel)
        //        contentView.addSubview(subtitleLabel)
        
        let views: [String: UIView] = [
            "titleLabel": titleLabel
        ]
        
        let vflStrings = [
            "V:|[titleLabel]|",
            "H:|[titleLabel]|"
        ]
        
        for vfl in vflStrings {
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: vfl, metrics: nil, views: views))
        }
    }
    
    // This is an example method, defined by `CalloutView`, which is called when you tap on the callout
    // itself (but not one of its subviews that have user interaction enabled).
    
    override func didTouchUpInCallout(_ sender: Any) {
        print("didTouchUpInCallout")
    }
}
