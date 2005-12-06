"
Comanche modules response to the message #processHttp and are responsible for examining the http serving environment and possibly altering that environment.  They can act a filters on both the inbound request and the outbound response.  They may also produce content (and even filter content).  Modules for any given server are arranged in a hierarchy that is formed by following the path of subModules.  Any given module may or may not process its subModules.  The method #processHttp answers a boolean to indicate whether or not a response has been made available.  It is up to the parent module to decide whether or not to continue processing other modules if a response is available.  The default behavior is to stop processing and return once a response is made available.
"
Class {
	#name : #ComancheModule,
	#superclass : #Object,
	#instVars : [
		'subModules'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ComancheModule class >> new [

	^super new initialize
]

{ #category : #accessing }
ComancheModule class >> version [
	"Answer a version string...subclasses that override this method will
	have their answers appended to the 'Server' header in HTTP responses."

	^''
]

{ #category : #accessing }
ComancheModule >> addSubModule: aComancheModule [

	^self subModules add: aComancheModule
]

{ #category : #logging }
ComancheModule >> attachAllLoggersToTheTranscript [

	self loggers do: [ :ea | ea attachTheTranscript ]
]

{ #category : #logging }
ComancheModule >> detachAllLoggersFromTranscripts [

	self loggers do: [ :ea | ea detachTranscripts]
]

{ #category : #'error handling' }
ComancheModule >> errorResponseStatus: aSymbol description: aString [

	^HttpService current
		errorResponseStatus: aSymbol
		description: aString.

]

{ #category : #testing }
ComancheModule >> isComancheModule [

	^true
]

{ #category : #testing }
ComancheModule >> isCore [

	^false
]

{ #category : #testing }
ComancheModule >> isDir [

	^false
]

{ #category : #testing }
ComancheModule >> isDoc [

	^false
]

{ #category : #testing }
ComancheModule >> isLog [

	^false
]

{ #category : #testing }
ComancheModule >> isSession [

	^false
]

{ #category : #testing }
ComancheModule >> isVhost [

	^false
]

{ #category : #logging }
ComancheModule >> loggers [

	| answer |
	answer := OrderedCollection new.
	self visitWithValuable: 
		[ :mod |
		(mod isComancheModule and: [mod isLog]) 
			ifTrue: [answer add: mod logger]].
	^answer
]

{ #category : #validation }
ComancheModule >> modulesOnStack [

	| tmp answer |
	answer := OrderedCollection new.
	tmp := thisContext.
	[tmp notNil] whileTrue:
		[tmp receiver isComancheModule
			ifTrue: [answer add: tmp receiver].
		tmp := tmp sender].
	^answer asArray

]

{ #category : #logging }
ComancheModule >> openTranscriptsOnAllLoggers [

	self loggers do: [ :ea | ea openTranscript]
]

{ #category : #accessing }
ComancheModule >> options [

	^'GET,HEAD,POST,OPTIONS,TRACE'
]

{ #category : #processing }
ComancheModule >> processHttp [
	"<Boolean> Subclasses should override this method to process
	the current http request (accessed via HttpRequest current).
	Answer true if a response has been made available (via 
	HttpResponse current:) and false if no response was generated."

	self subclassResponsibility
]

{ #category : #processing }
ComancheModule >> processHttpRequest: request [
	"<HttpResponse>"

	self processHttp.
	^HttpResponse current
]

{ #category : #processing }
ComancheModule >> processSubModules [

	self subModulesDo: 
		[ :module |
		module processHttp ifTrue: [^true]].
	^false
]

{ #category : #visitor }
ComancheModule >> processVisitor: aKomModuleVisitor [

	^aKomModuleVisitor doComancheModule: self
]

{ #category : #accessing }
ComancheModule >> subModules [

	^subModules ifNil: [subModules _ OrderedCollection new]
]

{ #category : #processing }
ComancheModule >> subModulesDo: aBlock [

	subModules ifNotNil: 
		[subModules do: aBlock]

]

{ #category : #validation }
ComancheModule >> validate [

	| validator |
	validator := KomModuleValidator new.
	self visitModules: validator.
	validator problems isEmpty 
		ifFalse: [self error: 'validate of the module hierarchy failed']
	
]

{ #category : #validation }
ComancheModule >> validateContext: problems [
	"Validation is successful by default, subclass to check the 
	context stack for the the presence of required modules and add
	to the list of problems"

	self validateForStack: self modulesOnStack problems: problems

]

{ #category : #validation }
ComancheModule >> validateForStack: anArray [
	| probs |
	probs := OrderedCollection new.
	self validateForStack: anArray problems: probs.
	probs isEmpty ifFalse: [self error: 'invalid context for module']

]

{ #category : #validation }
ComancheModule >> validateForStack: anArray problems: problems [

	"Subclasses may wish to override this method to check that
	prerequisite modules are on the stack above them"

]

{ #category : #visitor }
ComancheModule >> visitModules: aKomModuleVisitor [

	self visitWithValuable: [ :ea | ea processVisitor: aKomModuleVisitor ].

]

{ #category : #visitor }
ComancheModule >> visitWithValuable: aMonadicValuable [

	aMonadicValuable value: self.
	self subModules do: [ :ea | ea visitWithValuable: aMonadicValuable]

]
