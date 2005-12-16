"
I am a version number.  My representation allows me to handle an entire tree of versions.  Once created, an instance should not change (note: VersionNumbers could be canonicalized like Symbols, but are not currently).  

I am a magnitude so that you can see if one version preceeds another (only if the two versions are in the same branch).  

	'2.1' asVersion < '2.2.1' asVersion	""true""
	'2.3' asVersion < '2.2.1' asVersion	""error different branches""
	'2.3' asVersion inSameBranchAs: '2.2.1' asVersion	""false, why the previous one failed.""	
	'2.1' asVersion = '2.1' asVersion		""true, obviously""

To get the next version number in the same branch:

	'2.3.4' asVersion next	""2.3.5""

To get the next version number, starting a new branch:

	'2.3.4' asVersion branchNext		""2.3.4.1""

To get the common base version of any two version numbers (useful for merging):

	'2.3.8' asVersion commonBase: '2.3.4.1' asVersion		""2.3.4""
"
Class {
	#name : #VersionNumber,
	#superclass : #Magnitude,
	#instVars : [
		'numbers'
	],
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #'as yet unclassified' }
VersionNumber class >> first [

	^self fromCollection: #(1)
]

{ #category : #'as yet unclassified' }
VersionNumber class >> fromCollection: aCollection [

	^self new
		initializeNumbers: aCollection;
		yourself
]

{ #category : #'as yet unclassified' }
VersionNumber class >> fromString: aString [

	^self fromCollection: 
		((aString findTokens: '.') collect: [:ea | ea asNumber ])
	
]

{ #category : #comparing }
VersionNumber >> < another [ 
	"Answer whether the receiver is less than the argument."

	| tmp |
	(self inSameBranchAs: another) ifFalse: 
		[^self error: 'Receiver and argument in different branches'].

	tmp := another numbers.
	(tmp size = numbers size) ifTrue:
		[1 to: numbers size do: 
			[ :in | (numbers at: in) < (tmp at: in) ifTrue: [^true]].
		^false].

	^numbers size < tmp size

]

{ #category : #comparing }
VersionNumber >> = aVersion [

	^numbers = aVersion numbers
]

{ #category : #accessing }
VersionNumber >> branchNext [

	^self class fromCollection: (numbers, (Array with: 1))
]

{ #category : #accessing }
VersionNumber >> commonBase: aVersion [

	| smallNums largeNums cutoff |
	(aVersion numbers size <= numbers size) 
		ifTrue: [smallNums := aVersion numbers. largeNums := numbers] 
		ifFalse: [smallNums := numbers. largeNums := aVersion numbers].

	cutoff := (1 to: smallNums size) 
		detect: [ :in | ((smallNums at: in) ~= (largeNums at: in))] 
		ifNone: [^self class fromCollection: smallNums].

	^self class fromCollection: 
		((numbers copyFrom: 1 to: (cutoff - 1)), 
		(Array with: ((smallNums at: cutoff) min: (largeNums at: cutoff))))

]

{ #category : #comparing }
VersionNumber >> hash [

	^numbers hash
]

{ #category : #testing }
VersionNumber >> inSameBranchAs: aVersion [

	| less more |
	(aVersion numbers size <= numbers size) 
		ifTrue: [less := aVersion numbers. more := numbers] 
		ifFalse: [less := numbers. more := aVersion numbers].

	1 to: (less size - 1) do: [ :in | ((less at: in) = (more at: in)) ifFalse: [^false]].
	^less size = more size or:
		[(less at: less size) <= (more at: less size)]

]

{ #category : #initialization }
VersionNumber >> initializeNumbers: aCollection [

	aCollection do: [ :ea | 
		ea <= 0 ifTrue: 
			[^self error: 'VersionNumbers cannot contain zero or negative numbers']].

	numbers := aCollection asArray
]

{ #category : #accessing }
VersionNumber >> next [

	| tmp |
	tmp := numbers copy.
	tmp at: numbers size put: (numbers last + 1).
	^self class fromCollection: tmp
]

{ #category : #accessing }
VersionNumber >> numbers [
	"Answer a copy (to discourage people from directly changing a version number).
	VersionNumbers should never change, instead, instantiate a new instance."

	^numbers copy
]

{ #category : #accessing }
VersionNumber >> previous [

	| tmp |
	numbers last = 1 ifTrue: 
		[^self class fromCollection: (numbers allButLast)].
	tmp := numbers copy.
	tmp at: numbers size put: (numbers last - 1).
	^self class fromCollection: tmp

]

{ #category : #printing }
VersionNumber >> printOn: strm [

	self storeOn: strm
]

{ #category : #printing }
VersionNumber >> storeOn: strm [

	strm nextPut: $'.
	self versionStringOn: strm.
	strm nextPutAll: ''' asVersion'.
]

{ #category : #printing }
VersionNumber >> versionString [

	^String streamContents: [ :strm | self versionStringOn: strm ]
]

{ #category : #printing }
VersionNumber >> versionStringOn: strm [

	| first |
	first := true.
	numbers do: [ :ea |
		first ifFalse: [strm nextPut: $.].
		first := false.
		ea printOn: strm]
	
]
