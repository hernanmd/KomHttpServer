Extension { #name : #Object }

{ #category : #'*KomHttpServer' }
Object >> asHtmlDocumentForRequest: aNetworkRequest [

	self error: 
		('The requested object (', 
		self asString, 
		'), could not be converted into HTML for your browser.')
]

{ #category : #'*KomHttpServer' }
Object >> asHttpResponseTo: anHttpRequest [

	^(self asHtmlDocumentForRequest: anHttpRequest) 
		asHttpResponseTo: anHttpRequest

]

{ #category : #'*KomHttpServer' }
Object >> contentType [
	^MIMEDocument defaultContentType
]

{ #category : #'*KomHttpServer' }
Object >> isComancheModule [

	^false
]
