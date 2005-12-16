Extension { #name : #TextFontChange }

{ #category : #'*KomHttpServer-processing' }
TextFontChange >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</FONT>'
]

{ #category : #'*KomHttpServer-processing' }
TextFontChange >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<FONT SIZE="';
		nextPutAll: (self fontNumber + 2) asString;
		nextPutAll: '">'
]
