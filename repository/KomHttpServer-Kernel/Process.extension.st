Extension { #name : #Process }

{ #category : #'*KomHttpServer' }
Process >> okToTerminate [

	self suspendedContext ifNotNilDo: 
		[ :suspendedCtx |
		suspendedCtx stackDo: 
			[ :ctx |
			ctx method == self class termMethod
				ifTrue: [^true]]].
	^false
]

{ #category : #'*KomHttpServer' }
Process class >> termMethod [

	^Process class methodDictionary at: #terminationOkDuring:
]

{ #category : #'*KomHttpServer' }
Process class >> terminationOkDuring: aBlock [

	^aBlock value
]
