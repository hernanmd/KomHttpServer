Extension { #name : #TextColor }

{ #category : #'*KomHttpServer' }
TextColor >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</FONT>'
]

{ #category : #'*KomHttpServer' }
TextColor >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<FONT COLOR="#';
		nextPutAll: self color hex;
		nextPutAll: '">'
]
