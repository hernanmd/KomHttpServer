Extension { #name : #TextFontChange }

{ #category : #'*KomHttpServer' }
TextFontChange >> printHtmlCloseTagOn: strm [
	strm
		nextPutAll: '</FONT>'
]

{ #category : #'*KomHttpServer' }
TextFontChange >> printHtmlOpenTagOn: strm [
	strm
		nextPutAll: '<FONT SIZE="';
		nextPutAll: (self fontNumber + 2) asString;
		nextPutAll: '">'
]
