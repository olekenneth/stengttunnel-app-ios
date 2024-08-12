//
//  Double.swift
//  Stengt tunnel
//
//  Created by Ole-Kenneth on 12/08/2024.
//

import Foundation

extension Double {
  func convert(from originalUnit: UnitLength, to convertedUnit: UnitLength) -> Double {
      return Measurement(value: self, unit: originalUnit).converted(to: convertedUnit).value.rounded()
  }
}
