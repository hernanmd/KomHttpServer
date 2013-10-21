Extension { #name : #StandardFileStream }

{ #category : #'*KomHttpServer' }
StandardFileStream >> contentType [
	^self mimeType
]

{ #category : #'*KomHttpServer' }
StandardFileStream >> mimeType [

	^MIMEDocument guessTypeFromName: self name.

]
