Extension { #name : #TextMorph }

{ #category : #'*KomHttpServer-processing' }
TextMorph >> asHttpResponseTo: request [
	^self asText asHttpResponseTo: request
]
