"
kom/4.12 (Comanche/4.12)

HTTPAdaptor (kom/4.8; bolot 4/2/2001 18:48)
- logging is removed from kom46 core
- so is Process>>contextAt:ifAbsent:
- kom48 adds rudimentary persistent connections
-- see keepAliveConnection senders (also in Preferences)

Comment from kom46:
I encapsulate the HTTP protocol from my clients (who must support the HttpPlug interface).  I use an HttpRequest to pick apart a request and I use an HttpResponse to formulate a response.  Mainly, I broker the conversation, turning a request into a message send (to an HttpPlug) and converting the answer to an HttpResponse.  Thus, my clients must simply implement a message based protocol (eliminating the need for them to be concerned with HTTP syntax).

Instance Variables:

stream <Stream> - A bidirectional stream for reading and writing request (note: previously Comanche separated the readStream and writeStream, if you need to separate the read stream from the write stream you can create a new bidirectional stream class that uses two separate streams for reading and writing)

httpService <HttpService> - an instance of an HttpService or a protocol compatible substitute; this object is used as the error handler and the target of http request dispatching

postProcessors <OrderedCollection | nil> - this is a list of objects that are sent post processing messages (after the response has been written); this enables objects to request that they get called after the HttpAdaptor has actually written the response onto the write stream

"
Class {
	#name : #HttpAdaptor,
	#superclass : #Object,
	#instVars : [
		'stream',
		'httpService',
		'postProcessors'
	],
	#classVars : [
		'LastTimeStampTime',
		'TimezoneOffset',
		'LastTimeStamp'
	],
	#category : #'KomHttpServer-Protocol'
}

{ #category : #timestamp }
HttpAdaptor class >> buildTimeStamp: seconds [

	^((TimeStamp fromSeconds: seconds) minusSeconds: self timezoneOffset) printHttpFormat
]

{ #category : #bindings }
HttpAdaptor class >> current [

	^#'HttpAdaptor-current' binding
]

{ #category : #bindings }
HttpAdaptor class >> current: anInstance [

	^#'HttpAdaptor-current' binding: anInstance
]

{ #category : #preferences }
HttpAdaptor class >> dataTimeout [
	"The number of seconds to wait for data to be received on a
	given socket."

	^#'HttpAdaptor-dataTimeout' binding ifNil: [10]
]

{ #category : #preferences }
HttpAdaptor class >> dataTimeout: seconds [

	^#'HttpAdaptor-dataTimeout' binding: seconds
]

{ #category : #preferences }
HttpAdaptor class >> keepAlive [

	^#'HttpAdaptor-keepAlive' binding ifNil: [true]
]

{ #category : #preferences }
HttpAdaptor class >> keepAlive: aBoolean [

	^#'HttpAdaptor-keepAlive' binding: aBoolean
]

{ #category : #preferences }
HttpAdaptor class >> maxKeepAliveRequests [
	"This is the maximum number of requests to allow
	during a persistent connection. (zero means unlimited)."

	^#'HttpAdaptor-maxKeepAliveRequests' binding ifNil: [100]
]

{ #category : #preferences }
HttpAdaptor class >> maxKeepAliveRequests: anInteger [

	^#'HttpAdaptor-maxKeepAliveRequests' binding: anInteger
]

{ #category : #'instance creation' }
HttpAdaptor class >> readAndWriteTo: aStream service: httpService [

	^self new
		initializeOn: aStream httpService: httpService;
		beginConversation;
		yourself
]

{ #category : #'instance creation' }
HttpAdaptor class >> readAndWriteToSocket: aSocket service: httpService [

	^self 
		readAndWriteTo: 
			((SocketStream on: aSocket)
				timeout: self dataTimeout;
				autoFlush: false;
				yourself)
		service: httpService
]

{ #category : #timestamp }
HttpAdaptor class >> timeStamp [

	| seconds |
	seconds _ Time totalSeconds.
	^seconds ~= LastTimeStampTime
		ifTrue: 
			[LastTimeStamp _ self buildTimeStamp: (LastTimeStampTime _ seconds)]
		ifFalse: 
			[LastTimeStamp]
]

{ #category : #preferences }
HttpAdaptor class >> timezoneOffset [
	"The offset (in seconds) of the server's timezone relative to GMT."

	^TimezoneOffset ifNil: [0]
]

{ #category : #preferences }
HttpAdaptor class >> timezoneOffset: aNumber [

	^TimezoneOffset := aNumber
]

{ #category : #processing }
HttpAdaptor >> addConnectionHeaders: response request: request count: count [

	response fieldAt: 'Server' put: self serverType.
	response fieldAt: 'Date' put: self timeStamp.
	(request isPersistent and: [self keepAlive])
		ifTrue: 
			[response fieldAt: 'Connection' put: 'Keep-Alive'.
			response fieldAt: 'Keep-Alive' put: 
				(String streamContents: 
					[ :s |
					s nextPutAll: 'timeout='.
					s nextPutAll: self dataTimeout asString.
					s nextPutAll: ', max='.
					s nextPutAll: (self maxKeepAliveRequests - count) asString])]
		ifFalse: 
			[response fieldAt: 'Connection' put: 'close'].

]

{ #category : #'post processing' }
HttpAdaptor >> addPostProcessor: anObject [
	"Add anObject to my list of postProcessor, anObject must respond to
	the message #doPostProcessingFor:response:"

	(postProcessors ifNil: [postProcessors := OrderedCollection new])
		add: anObject
]

{ #category : #processing }
HttpAdaptor >> beginConversation [

	| response request count limit continue |
	"note: there is a lot of effort in this method to ensure that we don't have
	and explicit method returns.  For some reason (bugs in exception handling?) we
	can get errors if we have explicit returns...this behavior seems to
	only happen when Seaside is also loaded (though it doesn't look like Seaside code
	is being invoked when the problems happen."

	count := 0.
	continue := true.
	limit := self maxKeepAliveRequests.
	[
		[request := self readRequest] on: Error do: [ :ex | continue := false].
		continue ifTrue:		
			[[Bindings clamp:
				[response := self dispatchRequest: request.
				self addConnectionHeaders: response request: request count: count.
				(self writeResponse: response for: request) ifFalse: [^self destroy].
				self doPostProcessingFor: request response: response].
			count := count + 1.
			continue := response isPersistent and: [count < limit]]
				ifCurtailed: [continue := false]].
		continue.
	] whileTrue.
	self destroy.
]

{ #category : #accessing }
HttpAdaptor >> dataTimeout [

	^self class dataTimeout
]

{ #category : #processing }
HttpAdaptor >> destroy [

	[self stream close] 
		on: Error do: [ :ex | "ignore" ].

]

{ #category : #dispatching }
HttpAdaptor >> dispatchRequest: request [ 
	"<HttpResponse> Dispatches an HttpRequest as a method to the target and
	answers an HttpResponse to be transferred to the client"

	| response |
	response := self errorHandler handleDispatchErrorsIn: 
		[HttpAdaptor current: self.
		HttpRequest current: request.
		self target processHttpRequest: request].
	response ifNil: [response := self notFoundResponseFor: request].
	response addCookies: request responseCookies.
	^response
]

{ #category : #'post processing' }
HttpAdaptor >> doPostProcessingFor: request response: response [
	"Do the post processing for the given request/response pair and
	then reset our list of post processors."

	self postProcessorsDo: 
		[ :ea |
		ea doPostProcessingFor: request response: response].
	postProcessors := nil.
]

{ #category : #accessing }
HttpAdaptor >> errorHandler [

	^self httpService
]

{ #category : #accessing }
HttpAdaptor >> httpService [

	^httpService
]

{ #category : #accessing }
HttpAdaptor >> httpService: aComancheHttpService [

	httpService _ aComancheHttpService
]

{ #category : #'initialize-release' }
HttpAdaptor >> initializeOn: aStream httpService: anHttpService [
 
	stream _ aStream.
	httpService _ anHttpService.
]

{ #category : #accessing }
HttpAdaptor >> keepAlive [

	^self class keepAlive
]

{ #category : #accessing }
HttpAdaptor >> maxKeepAliveRequests [

	^self class maxKeepAliveRequests
]

{ #category : #dispatching }
HttpAdaptor >> notFoundResponseFor: request [

	^self httpService
		errorResponseStatus: #notFound
		description: ('The requested URL ', request url, ' was not found on this server').
]

{ #category : #'post processing' }
HttpAdaptor >> postProcessorsDo: aBlock [

	postProcessors ifNotNil: [postProcessors do: aBlock]
]

{ #category : #processing }
HttpAdaptor >> readRequest [

	^HttpRequest readFromStream: self readStream.


]

{ #category : #accessing }
HttpAdaptor >> readStream [

	^self stream
]

{ #category : #accessing }
HttpAdaptor >> serverType [

	^self httpService serverType
]

{ #category : #accessing }
HttpAdaptor >> stream [

	^stream
]

{ #category : #accessing }
HttpAdaptor >> target [

	^self httpService
]

{ #category : #accessing }
HttpAdaptor >> timeStamp [

	^self class timeStamp
]

{ #category : #processing }
HttpAdaptor >> writeResponse: response for: request [
	"<Boolean> Answer whether or not we succeeded in writing out the
	response.  If we did not, the caller may want to shut down this Http
	conversation.  We try to handle errors in writing the response by 
	getting and writing another response (note: this might not always work
	since the error could have occurred after some data has been written
	on the response stream).  For debugging, the method #handleResponseWritingError:
	can #pass on the exception to allow a walkback to appear."

	| errorResponse |
	[[request method = 'HEAD'
		ifTrue: [response writeHeadersOn: self writeStream]
		ifFalse: [response writeOn: self writeStream]]
			on: Error
			do: 
				[ :ex |
				errorResponse := self errorHandler handleResponseWritingError: ex.
				[errorResponse writeOn: self writeStream] on: Error do: [^false]].
	] ensure: [response destroy].
	^true

]

{ #category : #accessing }
HttpAdaptor >> writeStream [

	^self stream
]
