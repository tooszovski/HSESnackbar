//
//  UIColor.swift
//  
//
//  Created by Aleksander Tooszovsky on 27.02.2020.
//

import UIKit

extension UIColor {
  enum SnackBarColors {
    static var defaultText: UIColor {
      if #available(iOS 13, *) {
        return UIColor.label.withAlphaComponent(0.8)
      } else {
        return UIColor(white: 0, alpha: 0.8)
      }
    }
    
    static var toastBackground : UIColor {
      if #available(iOS 13, *) {
        return UIColor { (UITraitCollection: UITraitCollection) -> UIColor in
          if UITraitCollection.userInterfaceStyle == .dark {
            return #colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 1)
          } else {
            return .white
          }
        }
      } else {
        return .white
      }
    }
    static var defaultShadow : UIColor {
      if #available(iOS 13, *) {
        return .label
      } else {
        return .black
      }
    }
  }
}
