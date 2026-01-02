Extension { #name : 'SocketStream' }

{ #category : '*PharoLanguageProtocol' }
SocketStream >> plpNext: number [

	^ self next: number
]

{ #category : '*PharoLanguageProtocol' }
SocketStream >> plpUpTo: delim [

	^ self upTo: delim
]
