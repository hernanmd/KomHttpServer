Extension { #name : #TextEmphasis }

{ #category : #'*KomHttpServer-processing' }
TextEmphasis >> printHtmlCloseTagOn: strm [
	emphasisCode = 1 ifTrue: [strm nextPutAll: '</B>'].
	emphasisCode = 2 ifTrue: [strm nextPutAll: '</I>'].
	emphasisCode = 4 ifTrue: [strm nextPutAll: '</U>'].
	emphasisCode = 16 ifTrue: [strm nextPutAll: '</S>']
]

{ #category : #'*KomHttpServer-processing' }
TextEmphasis >> printHtmlOpenTagOn: strm [
	emphasisCode = 1 ifTrue: [strm nextPutAll: '<B>'].
	emphasisCode = 2 ifTrue: [strm nextPutAll: '<I>'].
	emphasisCode = 4 ifTrue: [strm nextPutAll: '<U>'].
	emphasisCode = 16 ifTrue: [strm nextPutAll: '<S>']
]
