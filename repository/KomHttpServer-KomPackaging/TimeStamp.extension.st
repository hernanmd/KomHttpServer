Extension { #name : #TimeStamp }

{ #category : #'*KomHttpServer-BaseExtensions' }
TimeStamp >> printCLFFormatOn: aStream [

	| d t |
	d := self date.
	t := self time.
	aStream nextPut: $[.
	d printOn: aStream format: #(1 2 3 $/ 2 1 2).
	aStream nextPut: $:.
	t print24: true on: aStream.
	aStream nextPut: $].

]

{ #category : #'*KomHttpServer-BaseExtensions' }
TimeStamp >> printCLFFormatOn: aStream timezoneOffset: offset [ 

	| d t |
	d := self date.
	t := self time.
	aStream nextPut: $[.
	d printOn: aStream format: #(1 2 3 $/ 2 1 2).
	aStream nextPut: $:.
	t print24: true on: aStream.
	aStream nextPut: $ .
	offset < 0 
		ifTrue: [aStream nextPut: $-]
		ifFalse: [aStream nextPut: $+].
	offset abs < 10 ifTrue: [aStream nextPut: $0].
	offset abs printOn: aStream.
	aStream nextPutAll: '00'.
	aStream nextPut: $].

]

{ #category : #'*KomHttpServer-BaseExtensions' }
TimeStamp >> printHttpFormat [

	^String streamContents: [ :strm | self printHttpFormatOn: strm]
]

{ #category : #'*KomHttpServer-BaseExtensions' }
TimeStamp >> printHttpFormatOn: aStream [

	| d t |
	d := self date.
	t := self time.
	aStream nextPutAll: (d weekday copyFrom: 1 to: 3).
	aStream nextPutAll: ', '.
	d printOn: aStream format: #(1 2 3 $  2 1 2).
	aStream nextPut: $ .
	t print24: true on: aStream.
	aStream nextPutAll: ' GMT'.
]
