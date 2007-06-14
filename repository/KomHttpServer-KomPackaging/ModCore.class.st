"
The is the Core module.  It extracts a few things from a request and can establish a server root directory (which is not required).  It will also process TRACE and OPTIONS requests.
"
Class {
	#name : #ModCore,
	#superclass : #ComancheModule,
	#instVars : [
		'serverRoot'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #bindings }
ModCore class >> host [

	^#'ModCore-Host' binding
]

{ #category : #bindings }
ModCore class >> host: aString [

	^#'ModCore-Host' binding: aString
]

{ #category : #bindings }
ModCore class >> method [

	^#'ModCore-Method' binding
]

{ #category : #bindings }
ModCore class >> method: methodString [

	#'ModCore-Method' binding: methodString
]

{ #category : #bindings }
ModCore class >> options [

	^#'ModCore-Options' binding
]

{ #category : #bindings }
ModCore class >> options: methodsString [

	^#'ModCore-Options' binding: methodsString
]

{ #category : #bindings }
ModCore class >> path [

	^#'ModCore-Path' binding
]

{ #category : #bindings }
ModCore class >> path: aString [

	^#'ModCore-Path' binding: aString
]

{ #category : #bindings }
ModCore class >> serverRoot [

	^#'ModCore-ServerRoot' binding
]

{ #category : #bindings }
ModCore class >> serverRoot: aFileDirectory [

	^#'ModCore-ServerRoot' binding: aFileDirectory
]

{ #category : #'as yet unclassified' }
ModCore >> isCore [

	^true
]

{ #category : #'as yet unclassified' }
ModCore >> optionsResponse [
	| opts |
	opts := self class options ifNil: ['GET,HEAD,POST,OPTIONS,TRACE'].
	^(HttpResponse fromString: '')
		fieldAt: 'Allow' put: opts;
		yourself
]

{ #category : #'as yet unclassified' }
ModCore >> processHttp [
	| request method |
	request := HttpRequest current.
	self class
		method: (method := request method);
		path: request url;
		host: request networkHost;
		serverRoot: self serverRoot.
	method = 'TRACE' 
		ifTrue: 
			[HttpResponse current: (self traceResponse: request).
			^true].
	self processSubModules ifTrue: [^true].
	method = 'OPTIONS' 
		ifTrue: 
			[HttpResponse current: self optionsResponse.
			^true].
	^false
]

{ #category : #'as yet unclassified' }
ModCore >> serverRoot [

	^serverRoot

]

{ #category : #'as yet unclassified' }
ModCore >> serverRoot: aDirOrString [ 
	serverRoot := aDirOrString isString 
		ifTrue: [FileDirectory on: aDirOrString]
		ifFalse: [aDirOrString]
]

{ #category : #'as yet unclassified' }
ModCore >> traceResponse: request [

	^HttpResponse fromString:
		(String streamContents: [ :strm | request writeOn: strm ])
]
