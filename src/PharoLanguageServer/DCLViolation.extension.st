Extension { #name : 'DCLViolation' }

{ #category : '*PharoLanguageServer' }
DCLViolation >> asPLSDiagnostic [ 

	^PLSDiagnostic new
		message: (self constraint description) ;
		range: (association sourceAnchor asPLSRange)
]
