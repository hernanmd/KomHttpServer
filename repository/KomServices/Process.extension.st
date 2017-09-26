Extension { #name : #Process }

{ #category : #'*KomServices' }
Process >> okToTerminate [
	self suspendedContext
		ifNotNil: [ :suspendedCtx | 
			suspendedCtx
				stackDo: [ :ctx | 
					ctx method == self class termMethod
						ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : #'*KomServices' }
Process class >> termMethod [

	^Process class methodDictionary at: #terminationOkDuring:
]

{ #category : #'*KomServices' }
Process class >> terminationOkDuring: aBlock [

	^aBlock value
]
