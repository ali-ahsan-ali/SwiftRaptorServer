//
// String+Substring.swift
//

// swiftlint:disable todo
// swiftlint:disable file_length

// TODO: Write "writeRecord".
// TODO: Write "writeHeader".

import Foundation

// MARK: Substring

extension Substring {

  /**
   Scans for, then returns, the next GTFS field found within `self`.
   
   `nextField` scans characters within `self` for a GTFS field. It will
	 scan characters until either a delimiting comma is found (which delimits
	 the target field from any subsequent fields in `self`) or there are no
	 more characters available to scan in `self` (i.e.,`self` is the final field
	 in the substring). If a comma is embedded within the text of the target
	 field, then the field must be enclosed within a pair
	 of escaping double-quotation marks (and there must be no leading or
	 trailing spaces before, or after, those quotation marks). `nextfield`
	 mutates `self`, so upon return, `self` will begin at the
	 character immediately following the extracted field (excluding any comma
	 delimiter separating the target field from subsequent fields). If self contains no characters, `nextField` assumes it is
	 the final field within the substring and returns an empty string as the
	 field value.
   - Returns: A `String` containing the next GTFS field found within `self`.
   - Throws: `TransitParseError.quoteExpected` will be thrown if a quoted
	 field is not terminated correctly. `TransitParseError.commaExpected` will
	 be thrown if a comma delimiter does not immediately follow a quoted field (except for the final field).
   - Tag: Substring-nextField
   */
  mutating func nextField() throws -> String {
		
		guard !self.isEmpty else { return "" }
		
		switch self[startIndex] {
    case "\"":
      removeFirst()
      guard let nextQuote = firstIndex(of: "\"") else {
        throw TransitError.quoteExpected
      }
      let field = prefix(upTo: nextQuote)
      self = self[index(after: nextQuote)...]
      if !isEmpty {
        let comma = removeFirst()
        if comma != "," { 
          throw TransitError.commaExpected 
        }
      }
      return String(field)
		case ",":
			removeFirst()
			return String("")
    default:
      if let nextComma = firstIndex(of: ",") {
        let field = prefix(upTo: nextComma)
          self = self[index(after: nextComma)...]
          return String(field)
      } else {
          let field = self
          removeAll()
          return String(field)
      }
    }
  }
}

// MARK: - String

extension String {

  /**
   Returns all GTFS fields contained within `self`.
   
   `readRecord` scans `self` for GTFS fields and returns those fields as an
   array of `String`s. Fields are delimited by commas. If a comma is contained
   within a field, then the field must be escaped by enclosing it within
	 quotation marks (`"`).
   - Returns: An array of `String`s containing all GTFS fields found within
	 `self`.
   - Throws: `TransitError.quoteExpected` will be thrown if a quoted field is
	 not terminated correctly. `TransitError.commaExpected` will be thrown if a
	 comma delimiter does not immediately follow a quoted field (except for the
	 final field).
   - Tag: String-readRecord
   */
  public func readRecord() throws -> [String] {
    var remainder = self[..<self.endIndex]
    var result: [String] = []
    do {
      while !remainder.isEmpty {
        var next = try remainder.nextField()
        if next.first == Character("\u{FEFF}") {
          next.removeFirst()
        }
        result.append(next)
      }
			// In the case that the record ends with a comma, then there is
			// an extra field that was not detected by `nextField` and we
			// add it as an empty string
			if self.last == "," {
				result.append("")
			}
					
    } catch let error {
      throw error
    }
    return result
  }

  /**
   Returns all GTFS header fields contained within `self`.
   
   `readHeader` scans `self` for contained GTFS header fields and returns them
	 as an array of header `FieldType`s. Header fields are delimited by commas.
	 If a comma is contained within a header field, then the field must be
	 escaped by enclosing it within quotation marks (`"`). If `readHeader` cannot
	 find a `FieldType` that corresponds to a known GTFS field, it will discard
	 the errant field and continue scanning.
   - Returns: An array of `String`s containing all GTFS header fields found
	 within `self`.
   - Throws: `TransitError.quoteExpected` will be thrown if a quoted field is
	 not terminated correctly. `TransitError.commaExpected` will be thrown if a
	 comma delimiter does not immediately follow a quoted field (except for the
	 final field).
   - Tag: String-readHeader
   */
  public func readHeader<FieldType: RawRepresentable>() throws -> [FieldType]
	where FieldType.RawValue == String {
    let components = try self.readRecord()
		return components.map {
			if let headerField = FieldType(rawValue: $0) {
				return headerField
			} else {
				return FieldType(rawValue: "nonstandard")!
      }
    }
  }

  /**
   Return all GTFS records contained within `self`.
   
   `splitRecords()` scans `self` for GTFS records and returns them as an array
   of `Substring`s. GTFS records must be delimited by a line feed, carriage
	 return, or a carriage return followed by line feed. Each GTFS record should
	 then be processed to extract the GTFS fields contained within it.
   - Returns: An array of `Substring`s containing all GTFS records found
	 within `self`.
   - Tag: String-splitRecords
   */
  func splitRecords() -> [Substring] {
    return self.split(whereSeparator: { char in
      switch char {
      case "\r", "\n", "\r\n": return true
      default: return false
      }
    })
  }

  /**
   Set `self` as the `String` value corresponding to `field` within `instance`.
   
   `assignStringTo` attempts to assign the `String` value associated with
   `self` into `instance` using the `WriteableKeyPath` associated with `field`.
   `field` must conform to the `KeyPathVending` protocol.
   - Throws: `TransitAssignError.invalidPath` if there is no `WriteableKeyPath`
   associated with `field`.
   - Tag: String-assignStringTo
   */
  func assignStringTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
	throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, String>
		else {
      throw TransitAssignError.invalidPath
    }
    instance[keyPath: path] = self
  }

  /**
   Set `self` as a value for an optional `String` field in `instance`.
   - Tag: String-assignOptionalStringTo
   */
  func assignOptionalStringTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
	throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, String?>
		else {
      throw TransitAssignError.invalidPath
    }
		guard self.count > 0 else {
			instance[keyPath: path] = nil
			return
		}
    instance[keyPath: path] = self
  }

  func assignIntTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
	throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, Int>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
    guard let int = Int(trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = int
  }

  /**
   Set `self` as a value for an optional `UInt` field in `instance`.
   - Tag: String-assignOptionalUIntTo
   */
  func assignOptionalIntTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
	throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, Int?>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
		guard trimmed.count > 0 else {
			instance[keyPath: path] = nil
			return
		}
    guard let int = Int(self)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = int
  }

  /**
   Set `self` as a value for a `URL` field in `instance`.
   - Tag: String-assignURLValueTo
   */
  func assignURLValueTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
  throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, URL>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
    guard let url = URL(string: trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = url
  }

  /**
   Set `self` as a value for an optional `URL` field in `instance`.
   - Tag: String-assignOptionalURLTo
   */
  func assignOptionalURLTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
  throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, URL?>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
		guard trimmed.count > 0 else {
			instance[keyPath: path] = nil
			return
		}
    guard let url = URL(string: trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = url
  }

  /**
   Set `self` as a value for an optional `TimeZone` field in `instance`.
   - Tag: String-assignTimeZoneTo
   */
  func assignTimeZoneTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
  throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, TimeZone>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
    guard let timeZone = TimeZone(identifier: trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = timeZone
  }

  /**
   - Tag: String-assignOptionalTimeZoneTo
   */
  func assignOptionalTimeZoneTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
  throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, TimeZone?>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
		guard trimmed.count > 0 else {
			instance[keyPath: path] = nil
			return
		}
    guard let timeZone = TimeZone(identifier: self)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = timeZone
  }

  func assignLocaleTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType
	) throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, Locale?>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
    let locale: Locale? = Locale(identifier: trimmed)
    instance[keyPath: path] = locale
  }

  // Remember to test passing an optional to a non-optional value assign.
  /**
   - Tag: String-assignRouteTypeTo
   */
  func assignRouteTypeTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType)
  throws where FieldType: KeyPathVending {
    guard let path = field.path as? WritableKeyPath<InstanceType, RouteType>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
    guard let routeType = Route.routeTypeFrom(string: trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = routeType
  }

  /**
   - Tag: String-assignOptionalPickupDropOffPolicyTo
   */
  func assignOptionalPickupDropOffPolicyTo<InstanceType, FieldType>(
		_ instance: inout InstanceType,
		for field: FieldType
	) throws where FieldType: KeyPathVending {
    guard let path = field.path
						as? WritableKeyPath<InstanceType, PickupDropOffPolicy?>
		else {
      throw TransitAssignError.invalidPath
    }
		let trimmed = self.trimmingCharacters(in: .whitespaces)
		guard trimmed.count > 0 else {
			instance[keyPath: path] = nil
			return
		}
    guard let pickupDropOffPolicy =
						Route.pickupDropOffPolicyFrom(string: trimmed)
		else {
      throw TransitAssignError.invalidValue
    }
    instance[keyPath: path] = pickupDropOffPolicy
  }
}
