Extension { #name : #Color }

{ #category : #'*KomHttpServer' }
Color >> hex [
	^ (rgb hex allButFirst: 3) asLowercase
]
