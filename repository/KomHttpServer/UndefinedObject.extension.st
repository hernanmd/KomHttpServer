Extension { #name : #UndefinedObject }

{ #category : #'*KomHttpServer' }
UndefinedObject >> asHttpResponseTo: request [

	^HttpResponse 
		status: #notFound 
		contents: 'The object you requested was not found on this server.'
]
