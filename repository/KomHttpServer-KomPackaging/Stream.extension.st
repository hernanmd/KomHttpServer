Extension { #name : #Stream }

{ #category : #'*KomHttpServer-processing' }
Stream >> asHttpResponseTo: request [

	^HttpResponse fromStream: self
]

{ #category : #'*KomHttpServer' }
Stream >> isTranscriptStream [

	^ false
]
