Class {
	#name : #KomModuleValidator,
	#superclass : #KomModuleVisitor,
	#instVars : [
		'problems'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
KomModuleValidator >> doComancheModule: aComancheModule [
	"This method assumes that module traversal happens in depth first order"

	aComancheModule validateContext: self problems
]

{ #category : #'as yet unclassified' }
KomModuleValidator >> problems [

	^problems ifNil: [problems := OrderedCollection new]
]
