Extension { #name : #Morph }

{ #category : #'*KomHttpServer-processing' }
Morph >> asHttpResponseTo: request [
	^self imageForm asHttpResponseTo: request
]
