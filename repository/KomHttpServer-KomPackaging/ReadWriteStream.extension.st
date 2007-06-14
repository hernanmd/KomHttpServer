Extension { #name : #ReadWriteStream }

{ #category : #'*KomHttpServer' }
ReadWriteStream >> asHttpResponseTo: request [

	^HttpResponse fromStream: self
]
