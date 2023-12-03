public struct ASCIIString<Str: StringProtocol> {
	public struct Slice {
		public let base: ASCIIString

		public let asciiRange: Range<Int>
		public let rawRange: Range<String.Index>
		public var substring: Str.SubSequence { self.base.base[self.rawRange] }
	}

	public let base: Str
	let asciiStartIndex: Int

	private init(_ base: Str, asciiStartIndex: Int) {
		self.base = base
		self.asciiStartIndex = asciiStartIndex
	}

	public init(_ base: Str) where Str == String {
		self.base = base
		self.asciiStartIndex = 0
	}

	public init(_ base: Str) where Str == Substring {
		self.base = base
		let rootString = base.base
		var itInd = rootString.startIndex
		self.asciiStartIndex = (0...).first { _ in
			if itInd == base.startIndex {
				return true
			} else {
				itInd = rootString.index(after: itInd)
				return false
			}
		}!
	}

	public func firstSlice(matching predicate: (Character) -> Bool) -> Slice? {
		var startIndices: IndexPair?

		func slice(relativeTo starts: IndexPair, asciiEnd: Int, rawEnd: String.Index) -> Slice {
			Slice(base: self,
				  asciiRange: (self.asciiStartIndex + starts.ascii)..<(self.asciiStartIndex + asciiEnd),
				  rawRange: starts.raw..<rawEnd)
		}

		for (asciiI, rawI) in zip(0..., self.base.indices) {
			let char = self.base[rawI]

			if predicate(char) {
				if startIndices == nil {
					startIndices = .init(ascii: asciiI, raw: rawI)
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

	public func allSlices(matching predicate: (Character) -> Bool) -> Array<ASCIIString<Str.SubSequence>.Slice> {
		var nextStartIndices = IndexPair(ascii: self.asciiStartIndex, raw: self.base.startIndex)

		var out = Array<ASCIIString<Str.SubSequence>.Slice>()
		while true {
			let remainderString = ASCIIString<Str.SubSequence>(self.base[nextStartIndices.raw...],
															   asciiStartIndex: nextStartIndices.ascii)
			guard let slice = remainderString.firstSlice(matching: predicate) else { break }

			nextStartIndices = IndexPair(ascii: slice.asciiRange.upperBound, raw: slice.rawRange.upperBound)

			out.append(consume slice)
		}

		return out
	}
}

private extension ASCIIString {
	struct IndexPair {
		let ascii: Int
		let raw: Str.Index
	}
}

extension ASCIIString.Slice: CustomDebugStringConvertible {
	public var debugDescription: String {
		#""\#(self.substring)" (\#(self.asciiRange))"#
	}
}
