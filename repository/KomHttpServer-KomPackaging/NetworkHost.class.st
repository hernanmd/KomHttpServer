"
I am an abstaction of a network host (in DNS parlance) and port number.  I can abstract named or numbered host names (as allowed in a URI for example).

	NetworkHost fromString: 'www.yahoo.com:8080'
	NetworkHost fromString: '192.168.1.1:80'
"
Class {
	#name : #NetworkHost,
	#superclass : #Object,
	#instVars : [
		'fullName',
		'port',
		'name',
		'type'
	],
	#category : #'KomHttpServer-Kernel'
}

{ #category : #'instance creation' }
NetworkHost class >> fromNamePath: namePath [

	^self new
		initializeFromNamePath: namePath;
		yourself
]

{ #category : #'instance creation' }
NetworkHost class >> fromString: aString [

	^self new
		initializeFromString: aString;
		yourself
]

{ #category : #accessing }
NetworkHost >> domainString [

	| sz |
	^self isNamedHost ifTrue: [
		((sz _ self name size) >= 2) ifTrue: [
			(self name at: (sz - 1)), '.', self name last.
		] ifFalse: [
			''
		]
	] ifFalse: [
		self nameString
	]
]

{ #category : #accessing }
NetworkHost >> fileSystemPath [
	| delim |
	delim _ FileDirectory pathNameDelimiter.

	^String streamContents: 
		[ :strm |
		self isNamedHost
			ifTrue: [strm nextPutAll: 'hostname']
			ifFalse: [strm nextPutAll: 'ipaddress'].
		strm nextPut: delim.
		self name reversed 
			do:
				[ :part | strm nextPutAll: part asString ]
			separatedBy: 
				[ strm nextPut: delim ]]
]

{ #category : #accessing }
NetworkHost >> fullName [

	^fullName
]

{ #category : #accessing }
NetworkHost >> httpReference [

	^'http://', self fullName
]

{ #category : #initialization }
NetworkHost >> initializeFromIPAddress: str [

	| nums |
	((str occurrencesOf: $.) = 3) ifTrue: [
		nums _ (str findTokens: '.') collect: [ :ea | 
			ea isPositiveInteger ifTrue: [
				ea asNumber
			] ifFalse: [ ^self ]
		].
		name _ nums.
		type _ #address.
	].	
	


	
]

{ #category : #initialization }
NetworkHost >> initializeFromNamePath: namePath [

	name _ namePath.
	type _ #name.

	
]

{ #category : #initialization }
NetworkHost >> initializeFromString: aString [

	^self initializeFromString: aString defaultPort: 80

	
]

{ #category : #initialization }
NetworkHost >> initializeFromString: aString defaultPort: dPort [

	| tmp |
	fullName _ aString.
	tmp _ self initializePortFromString: aString defaultPort: dPort.
	self initializeFromIPAddress: tmp.
	name ifNil: [
		name _ tmp findTokens: '.'.
		type _ #name.
	].

	
]

{ #category : #initialization }
NetworkHost >> initializePortFromString: aString defaultPort: dPort [

	| in tmp |
	^(aString notNil and: [(in _ aString indexOf: $:) > 0]) ifTrue: [
		tmp _ aString copyFrom: (in + 1) to: aString size.
		tmp isPositiveInteger ifTrue: [ 
			port _ tmp asNumber 
		] ifFalse: [
			port _ dPort.
		].
		aString copyFrom: 1 to: (in - 1).
	] ifFalse: [ 
		port _ dPort. 
		aString ifNotNil: [aString] ifNil: ['unknown']
	].


	

	


	
]

{ #category : #testing }
NetworkHost >> isNamedHost [

	^self type == #name
]

{ #category : #accessing }
NetworkHost >> machineName [

	^(self isNamedHost and: [ self name size >= 3 ]) ifTrue: [
		self name at: 1
	] ifFalse: [
		nil
	]
]

{ #category : #accessing }
NetworkHost >> name [

	^name
]

{ #category : #accessing }
NetworkHost >> nameString [

	| tmp nm |
	tmp _ (nm _ self name) first asString.

	2 to: nm size do: [ :in |
		tmp _ tmp, '.', (nm at: in) asString
	].
	^tmp

]

{ #category : #accessing }
NetworkHost >> port [

	^port
]

{ #category : #accessing }
NetworkHost >> type [

	^type
]

{ #category : #accessing }
NetworkHost >> vhostName: nameIndex letter: letterIndex [

	"First get the name component"
	| ni word nStart nEnd li |
	ni _ nameIndex asNumber.
	ni = 0 
		ifTrue: [word _ self nameString]
		ifFalse:
			[ni < 0 
				ifTrue: 
					[nStart _ name size + 1 + ni.
					(nameIndex endsWith: '+') 
						ifTrue: 
							[nEnd _ nStart.
							nStart _ 1]
						ifFalse: [nEnd _ nStart]]
				ifFalse: 
					[nStart _ ni.
					(nameIndex endsWith: '+') 
						ifTrue: [nEnd _ name size]
						ifFalse: [nEnd _ nStart]].
			(nStart < 1 or: [nStart > name size])
				ifTrue: [word _ '_']
				ifFalse:
					[word _ String streamContents: 
						[ :strm |
						(nStart to: nEnd)
							do: [ :in | strm nextPutAll: (name at: in)]
							separatedBy: [strm nextPut: $.]]]].

	"Now get the letters"
	li _ letterIndex asNumber.
	li = 0 
		ifTrue: [^word]
		ifFalse:
			[li < 0 
				ifTrue: 
					[nStart _ word size + 1 + li.
					(letterIndex endsWith: '+') 
						ifTrue: 
							[nEnd _ nStart.
							nStart _ 1]
						ifFalse: [nEnd _ nStart]]
				ifFalse: 
					[nStart _ li.
					(letterIndex endsWith: '+') 
						ifTrue: [nEnd _ word size]
						ifFalse: [nEnd _ nStart]].
			(nStart < 1 or: [nStart > name size])
				ifTrue: [^'_']
				ifFalse: [^word copyFrom: nStart to: nEnd]].

]
