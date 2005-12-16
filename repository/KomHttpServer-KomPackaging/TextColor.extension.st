Extension { #name : #TextColor }

{ #category : #'*KomHttpServer-processing' }
TextColor >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</FONT>'
]

{ #category : #'*KomHttpServer-processing' }
TextColor >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<FONT COLOR="#';
		nextPutAll: self color hex;
		nextPutAll: '">'
]
