Extension { #name : #TextURL }

{ #category : #'*KomHttpServer-processing' }
TextURL >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</A>'
]

{ #category : #'*KomHttpServer-processing' }
TextURL >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<A HREF="';
		nextPutAll: self info;
		nextPutAll: '">'
]
