Extension { #name : #String }

{ #category : #'*KomHttpServer' }
String >> asHttpResponseTo: request [

	^HttpResponse fromString: self
]
