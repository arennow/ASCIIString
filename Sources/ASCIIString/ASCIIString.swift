struct ASCIIString {
	struct Slice {
		let base: ASCIIString

		let asciiRange: Range<Int>
		let rawRange: Range<String.Index>
		var substring: Substring { self.base.base[self.rawRange] }
	}

	let base: String

	init(_ base: String) {
		self.base = base
	}

	func firstSlice(matching predicate: (Character) -> Bool) -> Slice? {
		var startIndices: (ascii: Int, raw: String.Index)?

		for (asciiI, rawI) in zip(0..., self.base.indices) {
			let char = self.base[rawI]

			if predicate(char) {
				if startIndices == nil {
					startIndices = (asciiI, rawI)
				}
			} else {
				if let startIndices {
					return Slice(base: self,
								 asciiRange: startIndices.ascii..<asciiI,
								 rawRange: startIndices.raw..<rawI)
				}
			}
		}

		if let startIndices {
			return Slice(base: self,
						 asciiRange: startIndices.ascii..<self.base.count,
						 rawRange: startIndices.raw..<self.base.endIndex)
		} else {
			return nil
		}
	}
}

extension ASCIIString.Slice: CustomDebugStringConvertible {
	var debugDescription: String {
		#""\#(self.substring)" (\#(self.asciiRange))"#
	}
}
