"
Instance Variable:

logger <Stream> - a stream for writing out request/response pairs 

Examples:

The following example will log requests to the Transcript:

	| ma |
	ma _ ModuleAssembly core.
	ma logTo: (KomLogger on: Transcript).
	ma addPlug: [ :request | HttpResponse fromString: 'Hello World!'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule

It is possible to segregate logging by inserting #logTo: messages a different places in the module assembly...one example using ModAlias follows:

	| ma |
	Smalltalk at: #MyHttpLog put: (WriteStream on: '').
	ma _ ModuleAssembly core.
	ma alias: '/log1' to: [ma logTo: (KomLogger on: Transcript)].
	ma alias: '/log2' to: [ma logTo: (KomLogger on: (Smalltalk at: #MyHttpLog))].
	ma addPlug: [ :request | HttpResponse fromString: 'Hello World!'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule

In this example, all requests will respond with 'Hello World!', but requests whose url begins with '/log1' will be logged to the transcript and requests whose url begins with '/log2' will be logged to MyHttpLog.  Other requests will not be logged.

In the next example, we illustrate how to start enable logging, and also how to open a transcript window on that log.  Output sent to the logger will be concurrently written to the WriteStream ""MyHttpLog"" and to the TranscriptStream opened by the #openTranscript message.

	| ma logger |
	Smalltalk at: #MyHttpLog put: (WriteStream on: '').
	ma _ ModuleAssembly core.
	ma logTo: (logger := KomLogger on: (Smalltalk at: #MyHttpLog)).
	ma addPlug: [ :request | HttpResponse fromString: 'Hello World!'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule.
	logger openTranscript.

Tip: With the SharedStreams package (on SqueakMap), a number of asynchronous logging configurations can be constructed.
"
Class {
	#name : #ModLog,
	#superclass : #ComancheModule,
	#instVars : [
		'logger'
	],
	#category : 'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ModLog >> doPostProcessingFor: request response: response [
	"This method is called after the response has been written, we need 
	to log the request/response pair"

	self logger nextPut: (Array with: request with: response)
]

{ #category : #testing }
ModLog >> isLog [

	^true
]

{ #category : #'as yet unclassified' }
ModLog >> logger [

	^logger
]

{ #category : #'as yet unclassified' }
ModLog >> logger: aStream [

	logger := aStream
]

{ #category : #'as yet unclassified' }
ModLog >> processHttp [

	HttpAdaptor current addPostProcessor: self.
	^self processSubModules
]
