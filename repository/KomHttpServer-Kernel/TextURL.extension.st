Extension { #name : #TextURL }

{ #category : #'*KomHttpServer' }
TextURL >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</A>'
]

{ #category : #'*KomHttpServer' }
TextURL >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<A HREF="';
		nextPutAll: self info;
		nextPutAll: '">'
]
