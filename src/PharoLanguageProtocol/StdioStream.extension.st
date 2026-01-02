Extension { #name : 'StdioStream' }

{ #category : '*PharoLanguageProtocol' }
StdioStream >> plpNext: numberOfData [

	^ (self next: numberOfData) asString
]

{ #category : '*PharoLanguageProtocol' }
StdioStream >> plpUpTo: delim [

	^ self upTo: delim asInteger
]
