struct ASCIIString<Str: StringProtocol> {
	struct Slice {
		let base: ASCIIString

		let asciiRange: Range<Int>
		let rawRange: Range<String.Index>
		var substring: Str.SubSequence { self.base.base[self.rawRange] }
	}

	let base: Str
	let asciiStartIndex: Int

	init(_ base: Str) {
		self.base = base

		if let ss = base as? Substring {
			let rootString = ss.base
			var itInd = rootString.startIndex
			self.asciiStartIndex = (0...).first { _ in
				if itInd == base.startIndex {
					return true
				} else {
					itInd = rootString.index(after: itInd)
					return false
				}
			}!
		} else {
			self.asciiStartIndex = 0
		}
	}

	func firstSlice(matching predicate: (Character) -> Bool) -> Slice? {
		var startIndices: (ascii: Int, raw: String.Index)?

		func slice(relativeTo starts: (ascii: Int, raw: String.Index), asciiEnd: Int, rawEnd: String.Index) -> Slice {
			Slice(base: self,
				  asciiRange: (self.asciiStartIndex + starts.ascii)..<(self.asciiStartIndex + asciiEnd),
				  rawRange: starts.raw..<rawEnd)
		}

		for (asciiI, rawI) in zip(0..., self.base.indices) {
			let char = self.base[rawI]

			if predicate(char) {
				if startIndices == nil {
					startIndices = (asciiI, rawI)
				}
			} else {
				if let startIndices {
					return slice(relativeTo: startIndices,
								 asciiEnd: asciiI,
								 rawEnd: rawI)
				}
			}
		}

		if let startIndices {
			return slice(relativeTo: startIndices,
						 asciiEnd: self.base.count,
						 rawEnd: self.base.endIndex)
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
