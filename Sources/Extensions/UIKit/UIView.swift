//
//  UIView.swift
//  
//
//  Created by Aleksander Tooszovsky on 27.02.2020.
//

import UIKit

extension UIView {
  func addSubviews(_ views: [UIView]) {
    views.forEach {
      addSubview($0)
    }
  }
}
