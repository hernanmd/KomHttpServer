Extension { #name : #Form }

{ #category : #'*KomHttpServer-processing' }
Form >> asHttpResponseTo: request [
	^HttpResponse fromMIMEDocument: self asWebImage
]

{ #category : #'*KomHttpServer-processing' }
Form >> asWebImage [
	"return a MIMEDocument"
	| aStream |
	aStream _ (RWBinaryOrTextStream on: '').
	GIFReadWriter putForm: (self asFormOfDepth: 8) onStream: aStream.
	aStream reset.
	^MIMEDocument contentType: MIMEDocument contentTypeGif content: aStream
]
