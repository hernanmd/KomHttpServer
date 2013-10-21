Extension { #name : #MessageSend }

{ #category : #'*KomHttpServer' }
MessageSend >> doPostProcessingFor: request response: response [
	"The method is to provide compatibility with HttpAdaptor's post processing.
	The receiver is expected to accept two arguments."

	^self value: request value: response
]

{ #category : #'*KomHttpServer' }
MessageSend >> processHttp [
	"<Boolean> The receiver should answer a boolean to indicate whether 
	there is an HttpResponse available (accessed by HttpResponse current).
	If the receiver takes no arguments, then assume that it answers a Boolean
	and uses dyanmic bindings to access the current request/response, otherwise
	pass in the current request and set the current response."

	| response |
	arguments size = 0
		ifTrue: [^self value].
	arguments size = 1
		ifTrue: 
			[response := self value: HttpRequest current.
			response ifNotNil:
				[HttpResponse current: response.
				^true].
			^false]

	
]

{ #category : #'*KomHttpServer' }
MessageSend >> processHttpRequest: request [
	"<HttpResponse> The receiver should answer an HttpResponse for sending 
	to the client."

	arguments size = 1
		ifTrue: [^self value: HttpRequest current].
	arguments size = 0
		ifTrue: [^self value].

	
]

{ #category : #'*KomHttpServer' }
MessageSend >> processVisitor: aKomModuleVisitor [

	^aKomModuleVisitor doMessageSend: self
]

{ #category : #'*KomHttpServer' }
MessageSend >> validateForStack: anArray [
	"Do nothing, provided to provide compatibility with ComancheModule"
]

{ #category : #'*KomHttpServer' }
MessageSend >> visitWithValuable: aMonadicValuable [

	aMonadicValuable value: self.


]
