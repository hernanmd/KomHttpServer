"
I am a session and am used by ModSession to associate sessions with incoming http requests.  After a period of inactivity, sessions are expired.

Notes: This class is a hold over from the old HttpSession class.  This class was renamed because it is not part of the HTTP protocol.  See ModSession for details on how to establish sessions.  You may use the attributes instance variable to hold additional state (such as user object for your application).  Alternatively, other modules may use the session to assign additional dynamic bindings.

For examples see the class comments for ModSession.
"
Class {
	#name : #KomSession,
	#superclass : #Object,
	#instVars : [
		'id',
		'attributes',
		'lastAccess'
	],
	#classVars : [
		'LastSessionID'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #bindings }
KomSession class >> current [

	^#'KomSession-current' binding
]

{ #category : #bindings }
KomSession class >> current: aKomSession [

	^#'KomSession-current' binding: aKomSession
]

{ #category : #'class initialization' }
KomSession class >> initialize [

	LastSessionID := Time totalSeconds.
]

{ #category : #'instance creation' }
KomSession class >> new [

	^ super new initialize
]

{ #category : #'session id' }
KomSession class >> nextSessionID [
	self flag: #TODO.
	"more robust unique number"
	LastSessionID _ LastSessionID + 1.
	^ (65535 atRandom hex allButFirst: 3)
		, (LastSessionID hex allButFirst: 3)
		, (65535 atRandom hex allButFirst: 3)
]

{ #category : #accessing }
KomSession >> attributes [
	"answer the attributes stored in Session"
	^ attributes
]

{ #category : #accessing }
KomSession >> id [

	^id
]

{ #category : #initialization }
KomSession >> initialize [

	attributes := Dictionary new.
	id := self class nextSessionID
]

{ #category : #accessing }
KomSession >> lastAccess [

	^lastAccess
]

{ #category : #accessing }
KomSession >> lastAccess: secondCount [

	lastAccess := secondCount
]

{ #category : #printing }
KomSession >> printOn: aStream [ 
	aStream 
		nextPutAll: self class name;
		nextPutAll: ' id:';
		nextPutAll: id asString;
		nextPutAll: ' attributes:';
		nextPutAll: attributes asString;
		nextPutAll: ' lastAccess:';
		nextPutAll: lastAccess asString
]

{ #category : #accessing }
KomSession >> touch [

	lastAccess := Time totalSeconds.
]
