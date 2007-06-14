Extension { #name : #StandardFileStream }

{ #category : #'*KomHttpServer' }
StandardFileStream >> mimeType [

	^MIMEDocument guessTypeFromName: self name.

]
