Extension { #name : #TimeStamp }

{ #category : #'*KomHttpServer' }
TimeStamp >> printCLFFormatOn: aStream [

	| d t |
	d _ self date.
	t _ self time.
	aStream nextPut: $[.
	d printOn: aStream format: #(1 2 3 $/ 2 1 2).
	aStream nextPut: $:.
	t print24: true on: aStream.
	aStream nextPut: $].

]

{ #category : #'*KomHttpServer' }
TimeStamp >> printCLFFormatOn: aStream timezoneOffset: zoneOffset [ 

	| d t |
	d := self date.
	t := self time.
	aStream nextPut: $[.
	d printOn: aStream format: #(1 2 3 $/ 2 1 2).
	aStream nextPut: $:.
	t print24: true on: aStream.
	aStream nextPut: $ .
	zoneOffset  < 0 
		ifTrue: [aStream nextPut: $-]
		ifFalse: [aStream nextPut: $+].
	zoneOffset abs < 10 ifTrue: [aStream nextPut: $0].
	zoneOffset abs printOn: aStream.
	aStream nextPutAll: '00'.
	aStream nextPut: $].

]

{ #category : #'*KomHttpServer' }
TimeStamp >> printHttpFormat [

	^String streamContents: [ :strm | self printHttpFormatOn: strm]
]

{ #category : #'*KomHttpServer' }
TimeStamp >> printHttpFormatOn: aStream [
	"Print receiver's date and time on aStream in HTTP format;
	'<day>, DD <mth> YYYY HH:MM:SS GMT' ->	'Thu, 01 Dec 1994 16:00:00 GMT'
	"
	
	| d t |
	d _ self date.
	t _ self time.
	aStream nextPutAll: (d weekday copyFrom: 1 to: 3).
	aStream nextPutAll: ', '.
	d printOn: aStream format: #(1 2 3 $  2 1 2).
	aStream nextPut: $ .
	t print24: true on: aStream.
	aStream nextPutAll: ' GMT'.
]
