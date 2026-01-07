Trait {
	#name : 'TPLPCommon',
	#instVars : [
		'currentId',
		'answerLoop',
		'clientInStream',
		'clientOutStream',
		'process',
		'answerLoopPriority',
		'withStdIO',
		'hasTCPServer',
		'requestHandlingPriority'
	],
	#category : 'PharoLanguageProtocol',
	#package : 'PharoLanguageProtocol'
}

{ #category : 'plp - answerLoop' }
TPLPCommon >> answerLoopPriority [
	"If withStdIO is true, it is important that this priority be less than requestHandlingPriority"

	^ answerLoopPriority ifNil: [
		  answerLoopPriority := self requestHandlingPriority - 1 ]
]

{ #category : 'accessing' }
TPLPCommon >> answerLoopPriority: anObject [

	answerLoopPriority := anObject
]

{ #category : 'id' }
TPLPCommon >> currentId [

	^ currentId
]

{ #category : 'id' }
TPLPCommon >> currentId: anObject [

	currentId := anObject
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> extractLengthOf: aData [
	(aData beginsWith: 'Content-Length: ')
		ifTrue:
			[ ^ (aData copyFrom: 16 to: (aData indexOf: Character cr)) asInteger ]
		ifFalse: [ ^ -1 ]
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> extractRequestFrom: stream [

	| length startingPoint endPoint result data |
	"data is the current buffer state"
	data := ''.
	length := -1.

	[ length = -1 and: [ answerLoop ] ] whileTrue: [
		[ data ifEmpty: [ data := stream plpNext: 25 ] ]
			on: ConnectionTimedOut
			do: [ self log: 'timed out but still working' ].
		length := self extractLengthOf: data ].

	startingPoint := data indexOf: ${.
	endPoint := data findCloseBracesFor: startingPoint.
	result := String new: length.

	"three options"
	"startingPoint and endPoint are found"
	(startingPoint ~= 0 and: [ endPoint ~= 0 ]) ifTrue: [
		result := data copyFrom: startingPoint to: endPoint.
		data := data copyFrom: endPoint + 1 to: data size.
		^ result ].

	startingPoint = 0
		ifTrue: [ "none were found"
			stream plpUpTo: ${.
			result at: 1 put: ${.
			stream nextInto: result startingAt: 2 ]

		ifFalse: [ "only startingPoint is found"
			(data copyFrom: startingPoint to: data size) withIndexDo: [
				:each
				:index | result at: index put: each ].
			stream nextInto: result startingAt: data size - startingPoint + 2 ].

	data := ''.
	^ result
]

{ #category : 'plp - send message' }
TPLPCommon >> getHeaderFor: answer into: aStream [

	aStream << 'Content-Length: ' << answer size asString << String crlf
	<< String crlf
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> handleRequest: request toClient: outputStream [

	self explicitRequirement
]

{ #category : 'accessing' }
TPLPCommon >> hasTCPServer [

	^ hasTCPServer := true
]

{ #category : 'accessing' }
TPLPCommon >> hasTCPServer: anObject [

	hasTCPServer := anObject
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> log: aString [

	aString record
]

{ #category : 'id' }
TPLPCommon >> nextId [

	^ currentId := currentId + 1
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> requestHandlingPriority [
	"This should be less than the priority for reading the input stream from the client
	 (which is lowIOPriority on stdin)"

	^ requestHandlingPriority ifNil: [
		  requestHandlingPriority := Processor lowIOPriority - 1 ]
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> requestHandlingPriority: priority [

  requestHandlingPriority := priority 
]

{ #category : 'plp - base protocol' }
TPLPCommon >> sendCancelRequest: id [

	self notifyMethod: '$/cancelRequest' arguments: (PLPCancelParams new
			 id: id;
			 yourself) asJRPCJSON
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> startAnswerLoop [

	answerLoop := true.

	process := [
		[ answerLoop ] whileTrue: [
			| request |
			request := self extractRequestFrom: clientInStream.
			self handleRequest: request toClient: clientOutStream.
		]
	]
	forkAt: self answerLoopPriority
	named: 'LanguageServerProtocol server'
]

{ #category : 'plp - answerLoop' }
TPLPCommon >> stopAnswerLoop [

	answerLoop := false
]

{ #category : 'accessing' }
TPLPCommon >> withStdIO [

	^ withStdIO
]

{ #category : 'accessing' }
TPLPCommon >> withStdIO: anObject [

	withStdIO := anObject
]
