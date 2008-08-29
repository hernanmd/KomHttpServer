Extension { #name : #Collection }

{ #category : #'*KomServices' }
Collection >> asIpByteArray [
	(self size = 4)
		ifFalse: [^self error: 'Invalid IP Address'].
	^ self asByteArray
]
