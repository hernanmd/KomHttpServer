Extension { #name : #WriteStream }

{ #category : #'*KomHttpServer' }
WriteStream >> asHttpResponseTo: request [

	^HttpResponse fromMIMEDocument: 
		(MIMEDocument contentType: self contentType content: self contents)
]

{ #category : #'*KomHttpServer' }
WriteStream >> contentType [

	self flag: #svp.
	"SVP: We should not be assuming that all write streams contain html content.  This needs to be fixed."

	^'text/html'
]

{ #category : #'*KomHttpServer' }
WriteStream >> endEntry [
	"No-op for compatibility with TranscriptStream."
]
