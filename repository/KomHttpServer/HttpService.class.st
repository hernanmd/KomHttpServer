"
I am a comanche service that listens for inbound HTTP connectinos on a given port.

Usage:

Subclasses should override the #processHttpRequest: method to process incoming HTTP requests (an HttpRequest is passed as the sole argument to this method).  The #processHttpRequest: method should always answer an instance of an HttpResponse.  Starting and stopping instances of this class will start and stop listening on the given port number.  You may also use instances of this class in a pluggable manner rather than subclassing (see examples below).

Instance Variables:

plug - An object that responds to the message #threadSafeValue: (typically a BlockContext or a MessageSend).  If this variable is not nil, then the default implementation of #processHttpRequest: will send #threadSafeValue: to this object and answer the result.  This enables ComancheHttpService to be used in a pluggable manner.  

Pluggable Examples (MessageSend):

	(HttpService on: 8080 named: 'Example Http Service')
		onRequestDispatch: #processRequest: to: SomeGlobal;
		start

Pluggable Examples (BlockContext):

	(HttpService on: 8080 named: 'Example Http Service')
		onRequestDo: [ :httpRequest | SomeGlobal processRequest: httpRequest ];
		start

"
Class {
	#name : #HttpService,
	#superclass : #TcpService,
	#instVars : [
		'plug',
		'mode'
	],
	#classVars : [
		'ServerHostName',
		'ServerType'
	],
	#category : #'KomHttpServer-Kernel'
}

{ #category : #bindings }
HttpService class >> current [

	^#'ComancheHttpService-Current' binding
]

{ #category : #bindings }
HttpService class >> current: anInstance [

	#'ComancheHttpService-Current' binding: anInstance
]

{ #category : #accessing }
HttpService class >> initialize [

	self initializeServerType
]

{ #category : #accessing }
HttpService class >> initializeServerType [
	"self initializeServerType"

	ServerType := String streamContents: 
					[:s | 
					s nextPutAll: self serviceName.
					s nextPutAll: '/'.
					s nextPutAll: self version.
					s nextPutAll: ' ('.
					s nextPutAll: self platform.
					s nextPutAll: ') '.
					ComancheModule withAllSubclassesDo: 
							[:modClass | 
							modClass version isEmpty 
								ifFalse: 
									[s nextPutAll: modClass version.
									s nextPut: $ ]]]
]

{ #category : #accessing }
HttpService class >> platform [

	^Smalltalk os platformName
]

{ #category : #accessing }
HttpService class >> serverType [

	^ServerType
]

{ #category : #accessing }
HttpService class >> serviceName [
	^ 'KomHttpServer'
]

{ #category : #accessing }
HttpService class >> version [

	^'7.1.3'
]

{ #category : #'error handling' }
HttpService >> detailedErrorResponseStatus: aSymbol exception: anException [ 
	^self errorResponseStatus: aSymbol
		description: '<pre><b>' , anException description , '</b><br><br>' 
				, anException signalerContext longStack , '</pre>'
]

{ #category : #'error handling' }
HttpService >> errorResponseStatus: aSymbol description: aString [

	^HttpResponse
		status: aSymbol
		contents: 
'<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
<html><head>
<title>', (HttpResponse statusCodeFor: aSymbol), ' ', (HttpResponse statusDescriptionFor: aSymbol), '</title>
</head><body>
<h1>', (HttpResponse statusDescriptionFor: aSymbol),'</h1>
', aString, '<p>
<hr>
<address>', self serverDescription,'</address>
</body></html>'
]

{ #category : #'error handling' }
HttpService >> handleDispatchErrorsIn: aBlock [
	"Note: We could break the error handling out into a separate
	object to allow more sophisticated error handling scenarios, however
	you can achieve the same result by writing a module that traps 
	errors and provides special handling.  So, here, we just provide three
	simple and common possibilities for handling dispatch errors."

	"Debug mode doesn't handle the error (you'll get a walkbalk)"
	self isDebugMode ifTrue: [^aBlock value].

	"Verbose mode will send a long stack dump to the browser"
	self isVerboseMode ifTrue: 
		[^aBlock on: Error do: 
			[ :ex | 
			self
				detailedErrorResponseStatus: #serverError
				exception: ex]].

	"By default, operate in deployment mode (just the exception description is
	displayed in the browser)"
	^aBlock on: Error do: 
		[ :ex | 
		self
			errorResponseStatus: #serverError
			description: ex description]
]

{ #category : #'error handling' }
HttpService >> handleResponseWritingError: anException [
	"Handle errors that occur when trying to write out a response."

	"Debug mode doesn't handle the error (you'll get a walkbalk)"
	self isDebugMode ifTrue: [^anException pass].

	"Verbose mode will send a long stack dump to the browser"
	self isVerboseMode ifTrue: 
		[^self
			detailedErrorResponseStatus: #serverError
			exception: anException].

	"By default, operate in deployment mode (just the exception description is
	displayed in the browser)"
	^self
		errorResponseStatus: #serverError
		description: anException description
]

{ #category : #'initialize-release' }
HttpService >> initialize [

	super initialize.
	mode := #deployment.
]

{ #category : #'error handling' }
HttpService >> isDebugMode [
	" Answer <true> if receiver's is acting in debug mode "

	^ self mode == #debug
]

{ #category : #'error handling' }
HttpService >> isDeploymentMode [
	" Answer <true> if receiver's is acting in deployment mode "
	
	^ self isVerboseMode not and: [ self isDebugMode not ]
]

{ #category : #'error handling' }
HttpService >> isVerboseMode [
	" Answer <true> if receiver's is acting in verbose mode "
	
	^ self mode == #verbose
]

{ #category : #configuration }
HttpService >> keepAlive [

	^self withBindingsDo: [HttpAdaptor keepAlive]
]

{ #category : #configuration }
HttpService >> keepAlive: aBool [

	self withBindingsDo: [HttpAdaptor keepAlive: aBool]
]

{ #category : #'error handling' }
HttpService >> mode [
	"<#deployment | #debug | #verbose > - Answers the debugging
	mode of the receiver."

	^ mode
]

{ #category : #'error handling' }
HttpService >> mode: aSymbol [
	"aSymbol <#deployment | #debug | #verbose > - Sets the debugging
	mode of the receiver."

	mode := aSymbol
]

{ #category : #pluggable }
HttpService >> module: aComancheModule [
	" This message is useful if you wish to validate your module. "

	aComancheModule validate.
	self plug: aComancheModule
]

{ #category : #pluggable }
HttpService >> onRequestDispatch: aSelector to: anObject [

	self plug: 
		(MessageSend 
			receiver: anObject 
			selector: aSelector 
			arguments: #(nil))
]

{ #category : #pluggable }
HttpService >> onRequestDo: plugBlock [

	self plug: plugBlock

]

{ #category : #configuration }
HttpService >> perceivedHostName [

	"Answer the host name as perceived by the client.  If there
	is no current HttpRequest, fall back on the name as determined
	on the server."

	| request |
	(request := HttpRequest current) ifNotNil: 
		[^request networkHost nameString].

	^self serverHostName

]

{ #category : #configuration }
HttpService >> perceivedPortNumber [

	"Answer the port number as it is perceived by the client (which could
	be different from the port we are listening on if for example you are 
	using port forwarding rules to reach your server).  If there is no 
	current http request, fall back on the real port number that we are 
	listening on."

	| request |
	(request := HttpRequest current) ifNotNil: 
		[^request networkHost port].

	^self portNumber

]

{ #category : #pluggable }
HttpService >> plug [

	^plug
]

{ #category : #pluggable }
HttpService >> plug: aMonadicValuable [

	plug := aMonadicValuable
]

{ #category : #'startup and shutdown' }
HttpService >> prepareForStartup [
	super prepareForStartup.
	ServerHostName := nil.
	self class initializeServerType.
	"this is necessary to make it start on cog images"
	process ifNotNil: [ :p |
		| list |
		list := p suspendingList.
		(list isKindOf: Semaphore)
			ifTrue: [ list signal ] ]
]

{ #category : #serving }
HttpService >> processHttpRequest: anHttpRequest [
	"Subclasses can override this method and answer an instance of an 
	HttpResponse.  Alternatively, if we have a plug (typically a BlockContext
	or a MessageSend), then invoke it."

	plug ifNotNil: [^plug processHttpRequest: anHttpRequest].
	^self subclassResponsibility

]

{ #category : #serving }
HttpService >> serve: aSocket [ 
	self class current: self.
	HttpAdaptor readAndWriteToSocket: aSocket service: self
]

{ #category : #configuration }
HttpService >> serverDescription [

	^String streamContents: [ :strm | self serverDescriptionOn: strm]
]

{ #category : #configuration }
HttpService >> serverDescriptionOn: strm [

	strm nextPutAll: self serverType.
	strm nextPutAll: ' Server at '.
	strm nextPutAll: self perceivedHostName.
	strm nextPutAll: ' Port '.
	strm nextPutAll: self perceivedPortNumber asString.

]

{ #category : #configuration }
HttpService >> serverHostName [

	"Cache the host name (it can take several milliseconds to make this call
	on some platforms.  The cache value will be reset every time the image
	is started"

	^ServerHostName ifNil:
		[ServerHostName := NetNameResolver 
								nameForAddress: NetNameResolver localHostAddress 
								timeout: 5]

]

{ #category : #configuration }
HttpService >> serverType [

	^self class serverType
]

{ #category : #'error handling' }
HttpService >> setDebugMode [

	self mode: #debug
]

{ #category : #'error handling' }
HttpService >> setDeploymentMode [

	self mode: #deployment
]

{ #category : #'error handling' }
HttpService >> setVerboseMode [

	self mode: #verbose
]

{ #category : #'starting and stopping' }
HttpService >> start [

	self class initializeServerType.
	^super start
]
