Extension { #name : #WriteStream }

{ #category : #'*KomHttpServer' }
WriteStream >> asHttpResponseTo: request [

	^HttpResponse fromMIMEDocument: 
		(MIMEDocument contentType: self mimeType content: self contents)
]

{ #category : #'*KomHttpServer' }
WriteStream >> endEntry [
	"No-op for compatibility with TranscriptStream."
]

{ #category : #'*KomHttpServer' }
WriteStream >> mimeType [

	self flag: #svp.
	"SVP: We should not be assuming that all write streams contain html content.  This needs to be fixed."

	^'text/html' asMIMEType
]
