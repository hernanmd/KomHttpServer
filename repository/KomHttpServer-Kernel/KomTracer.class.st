"
I am a KomLogger, but instead of writing a log file format, I write out a detailed trace of the http request and response pairs.  The following example will dump a trace on the transcript.

	| ma |
	ma _ ModuleAssembly core.
	ma logTo: (KomTracer on: Transcript).
	ma addPlug: [ :request | HttpResponse fromString: 'Hello World!'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule
"
Class {
	#name : #KomTracer,
	#superclass : #KomLogger,
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
KomTracer >> logEntryFor: request response: response [
	"This is the Common Log Format (CLF) - the stream is a TranscriptStream"

	| aStream |
	aStream := self streams anyOne.
	aStream
		nextPutAll: '-----';
		nextPut: Character cr.
	request writeOn: aStream.
	response writeHeadersOn: aStream.
	aStream endEntry.

]
