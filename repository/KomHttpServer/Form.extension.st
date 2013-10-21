Extension { #name : #Form }

{ #category : #'*KomHttpServer' }
Form >> asHttpResponseTo: request [
	^HttpResponse fromMIMEDocument: self asWebImage
]

{ #category : #'*KomHttpServer' }
Form >> asWebImage [
	"return a MIMEDocument"
	| aStream |
	aStream := (RWBinaryOrTextStream on: String new).
	GIFReadWriter putForm: (self asFormOfDepth: 8) onStream: aStream.
	aStream reset.
	^MIMEDocument contentType: MIMEDocument contentTypeGif content: aStream
]
