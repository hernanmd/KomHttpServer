"
Usage:

	InstallOptions do: 
		[ :opts |
		opts at: 'silent' put: true.
		opts at: 'loadPrerequisites' put: false.
		""do the installation here""]
"
Class {
	#name : #InstallOptions,
	#superclass : #Notification,
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #accessing }
InstallOptions class >> at: aKey [

	^self current at: aKey ifAbsent: [self error: 'key not found']
]

{ #category : #accessing }
InstallOptions class >> at: aKey ifAbsent: absentBlock [

	^self current at: aKey ifAbsent: absentBlock
]

{ #category : #accessing }
InstallOptions class >> at: aKey ifAbsentPut: absentBlock [

	^self current at: aKey ifAbsentPut: absentBlock
]

{ #category : #accessing }
InstallOptions class >> at: aKey put: anObject [

	^self current at: aKey put: anObject
]

{ #category : #accessing }
InstallOptions class >> beSilent [

	^self at: #beSilent ifAbsent: [false]
]

{ #category : #accessing }
InstallOptions class >> beSilent: aBoolean [

	^self at: #beSilent put: aBoolean
]

{ #category : #accessing }
InstallOptions class >> clamp: aBlock [

	| opts |
	opts := Dictionary new.
	[aBlock value: opts]
		on: InstallOptions
		do: [ :io | io resume: opts ]
]

{ #category : #accessing }
InstallOptions class >> current [

	^self signal ifNil: [Dictionary new]
]

{ #category : #accessing }
InstallOptions class >> includesKey: aKey [

	^self current includesKey: aKey
]

{ #category : #accessing }
InstallOptions class >> loadTestClasses [

	^(self at: #loadTestClasses ifAbsentPut: [true])
		and: [Smalltalk includesKey: #TestCase]
]

{ #category : #accessing }
InstallOptions class >> log: aString [

	| logger |
	(logger := self logger) nextPutAll: aString.
	logger flush.
	logger == Transcript ifTrue: [logger endEntry].

]

{ #category : #accessing }
InstallOptions class >> logger [

	^self at: #logger ifAbsentPut: [Transcript]
]

{ #category : #accessing }
InstallOptions class >> prerequisites [

	^self at: #prerequisites ifAbsentPut: [Dictionary new]
]

{ #category : #accessing }
InstallOptions class >> runTests [

	^self at: #runTests ifAbsentPut: [true]
]
