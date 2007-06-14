Extension { #name : #Stream }

{ #category : #'*KomHttpServer' }
Stream >> asHttpResponseTo: request [

	^HttpResponse fromStream: self
]

{ #category : #'*KomHttpServer' }
Stream >> isTranscriptStream [

	^ false
]

{ #category : #'*KomHttpServer' }
Stream >> mimeType [

	^MIMEDocument defaultContentType
]
