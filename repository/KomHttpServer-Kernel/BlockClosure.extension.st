Extension { #name : #BlockClosure }

{ #category : #'*KomHttpServer' }
BlockClosure >> doPostProcessingFor: request response: response [
	"The method is to provide compatibility with HttpAdaptor's post processing.
	The receiver is expected to accept two arguments."

	^self value: request value: response
]

{ #category : #'*KomHttpServer' }
BlockClosure >> processHttp [
	"<Boolean> The receiver should answer a boolean to indicate whether 
	there is an HttpResponse available (accessed by HttpResponse current).
	If the receiver takes no arguments, then assume that it answers a Boolean
	and uses dyanmic bindings to access the current request/response, otherwise
	pass in the current request and set the current response."

	| response |
	self numArgs = 0
		ifTrue: [^self value].
	self numArgs = 1
		ifTrue: 
			[response := self copy fixTemps value: HttpRequest current.
			response ifNotNil:
				[HttpResponse current: response.
				^true].
			^false].
]

{ #category : #'*KomHttpServer' }
BlockClosure >> processHttpRequest: request [
	"<HttpResponse> The receiver should answer an HttpResponse for sending 
	to the client."

	self numArgs = 1
		ifTrue: [^self value: request].
	self numArgs = 0
		ifTrue: [^self value].

]

{ #category : #'*KomHttpServer' }
BlockClosure >> processVisitor: aKomModuleVisitor [

	^aKomModuleVisitor doBlock: self
]

{ #category : #'*KomHttpServer' }
BlockClosure >> validateForStack: anArray [
	"Do nothing, provided to provide compatibility with ComancheModule"
]

{ #category : #'*KomHttpServer' }
BlockClosure >> visitWithValuable: aMonadicValuable [

	aMonadicValuable value: self.


]
