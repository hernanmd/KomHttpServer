Extension { #name : #String }

{ #category : #'*KomServices' }
String >> asIpByteArray [

	| ip tmp |
	ip := self findTokens: '.'.
	(ip size = 4) ifFalse: [ ^self error: 'Invalid IP Address' ].
	ip detect: [ :ea | ea isPositiveInteger and: [ (ea asNumber <= 255) and: [ ea asNumber >= 0 ]]]
		ifNone: [ ^self error: 'Invalid IP Address' ].
	tmp := ByteArray new: 4.
	1 to: 4 do: [ :in | tmp at: in put: (ip at: in) asNumber ].
	^tmp

]

{ #category : #'*KomServices' }
String >> isPositiveInteger [

	self isEmpty ifTrue: [^false].
	self detect: [ :letter | letter isDigit not] ifNone: [^true].
	^false
]
