Extension { #name : #ByteArray }

{ #category : #'*KomHttpServer' }
ByteArray >> asIpString [

	^String streamContents: 
		[ :strm |
		self do: 
			[ :ea |
			strm nextPutAll: ea asString.
			strm nextPut: $.].
		strm skip: -1]

]
