Extension { #name : #TextMorph }

{ #category : #'*KomHttpServer' }
TextMorph >> asHttpResponseTo: request [
	^self asText asHttpResponseTo: request
]
