"
I create a Publish Diagnotics Params from the document and the current requestor (that defines variables)
"
Class {
	#name : 'PLSDiagnosticsParamsEngine',
	#superclass : 'Object',
	#instVars : [
		'document',
		'requestor',
		'source',
		'sourceIsMethod'
	],
	#category : 'PharoLanguageServer-Structure-Diagnostic',
	#package : 'PharoLanguageServer',
	#tag : 'Structure-Diagnostic'
}

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine class >> document: aDocument [

	"Document is aDictionary with uri, version, and sourceCode"

	^ self new
		  document: aDocument;
		  source: aDocument text;
		  sourceIsMethod: false;
		  yourself
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> computeDiagnostics [

	^(MiApplication current itemsFor: DCLViolation)
		select: [ :v | ('file://' , v sourceFile) = self document uri ]
		thenCollect: #asPLSDiagnostic

]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> document [
	^ document
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> document: anObject [
	document := anObject
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> requestor [
	^ requestor
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> requestor: anObject [
	requestor := anObject
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> source [

	^ source
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> source: anObject [

	source := anObject
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> sourceIsMethod [
	^ sourceIsMethod
]

{ #category : 'accessing' }
PLSDiagnosticsParamsEngine >> sourceIsMethod: boolean [
	sourceIsMethod := boolean
]
