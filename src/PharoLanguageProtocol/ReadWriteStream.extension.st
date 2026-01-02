Extension { #name : 'ReadWriteStream' }

{ #category : '*PharoLanguageProtocol' }
ReadWriteStream >> plpNext: numberOfData [
	
	^ self next: numberOfData
]

{ #category : '*PharoLanguageProtocol' }
ReadWriteStream >> plpUpTo: delim [

	^ self upTo: delim
]
