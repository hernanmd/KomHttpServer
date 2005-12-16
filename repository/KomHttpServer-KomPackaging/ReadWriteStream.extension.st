Extension { #name : #ReadWriteStream }

{ #category : #'*KomHttpServer-processing' }
ReadWriteStream >> asHttpResponseTo: request [

	^HttpResponse fromStream: self
]
