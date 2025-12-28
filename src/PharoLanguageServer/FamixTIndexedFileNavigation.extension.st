Extension { #name : 'FamixTIndexedFileNavigation' }

{ #category : '*PharoLanguageServer' }
FamixTIndexedFileNavigation >> asPLSRange [

	| lines |
	lines := self fileReference contents lines.

	^PLSRange
		start: (self toLineCharacter: self startPos in: lines)
		end:   (self toLineCharacter: self endPos   in: lines)
]

{ #category : '*PharoLanguageServer' }
FamixTIndexedFileNavigation >> lineColumn: position in: lines [

	| remaining eol |
	remaining := position.
	eol := OSPlatform current lineEnding size. 
	lines withIndexDo: [ :aLine :i |
		(aLine size > remaining) 
			ifTrue: [ ^{ i . remaining } ].
		remaining := remaining - aLine size - eol
	].

	^{ lines size . (lines last size) }
]

{ #category : '*PharoLanguageServer' }
FamixTIndexedFileNavigation >> toLineCharacter: aPosition in: lines [
	"Converts a '{line-index . character-index}' to a dictionary
	 converts also from 1 based indices to 0 based"

	| lineCharacter |
	lineCharacter := self lineColumn: aPosition in: lines.
	^ {
		(#line -> (lineCharacter first - 1)) .
		(#character -> (lineCharacter second - 1))
	} asDictionary
]
