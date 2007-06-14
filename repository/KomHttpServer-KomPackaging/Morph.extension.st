Extension { #name : #Morph }

{ #category : #'*KomHttpServer' }
Morph >> asHttpResponseTo: request [
	^self imageForm asHttpResponseTo: request
]
