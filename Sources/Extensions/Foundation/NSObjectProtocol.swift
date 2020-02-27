//
//  NSObjectProtocol.swift
//  
//
//  Created by Aleksander Tooszovsky on 27.02.2020.
//

import Foundation

extension NSObjectProtocol {
  
  func with(_ closure: (Self) -> Void) -> Self {
    closure(self)
    return self
  }
  
}
