Extension { #name : #Object }

{ #category : #'*KomHttpServer-processing' }
Object >> asHtmlDocumentForRequest: aNetworkRequest [

	self error: 
		('The requested object (', 
		self asString, 
		'), could not be converted into HTML for your browser.')
]

{ #category : #'*KomHttpServer-processing' }
Object >> asHttpResponseTo: anHttpRequest [

	^(self asHtmlDocumentForRequest: anHttpRequest) 
		asHttpResponseTo: anHttpRequest

]

{ #category : #'*KomHttpServer-processing' }
Object >> isComancheModule [

	^false
]
