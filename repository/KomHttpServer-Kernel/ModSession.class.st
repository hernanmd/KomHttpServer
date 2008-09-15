"
I add provide a session context to sub modules.  To access the current session, use ""KomSession current""...all requests passing through this module will be assigned a session, and responses from its subModules (if any) will be given a cookie to assign the session id.

Notes:  This is basically a straight translation of the old Comanche session handling.  Ideas for the future include:

- add the ability to use post/query fields instead of cookies
- add methods to assist in building Urls with session query parameters added
- be able to specify the cookie/field name that is used to store the session
- be able to tie sessions to a specific IP address (to minimize risk of man in the middle attacks)

Required Bindings:

	HttpRequest current

Exported Bindings:

	KomSession current

Example:

In the following example, we enable session tracking, set the session timeout to 30 minutes, and show the session id in the web browser.

	| ma |
	ma _ ModuleAssembly core.
	ma trackSessions.
	ma sessionTimeout: 30.  ""Sets the session timeout to 30 minutes""
	ma addPlug:
		[:request | 
		HttpResponse fromString: 
			('Your session id is: ', KomSession current id)].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule.



"
Class {
	#name : #ModSession,
	#superclass : #ComancheModule,
	#instVars : [
		'sessions',
		'mutex',
		'lastCleanup',
		'secondsToLive'
	],
	#category : 'KomHttpServer-Modules'
}

{ #category : #private }
ModSession >> basicExtractSession: aRequest ifAbsent: absentBlock [
	"PRIVATE: answer the current session based on the 'SessionID' cookie"

	aRequest cookies
		at: #SessionID
		ifPresent: [ :sid | ^sessions at: sid ifAbsent: absentBlock].
	^absentBlock value

]

{ #category : #private }
ModSession >> checkForCleanup [
	"PRIVATE: run the cleanup if the last cleanup was more than
	1 minute ago"

	lastCleanup + 60 < Time totalSeconds
		ifTrue: [self cleanup]
]

{ #category : #private }
ModSession >> cleanup [
	"PRIVATE: iterate over all sessions and remove stale ones"

	| session cutoff |
	lastCleanup := Time totalSeconds.
	cutoff := lastCleanup - secondsToLive.
	sessions keys do: 
		[:key | 
		session := sessions at: key.
		(session lastAccess < cutoff) ifTrue: 
			[sessions removeKey: key]]
]

{ #category : #private }
ModSession >> extractSession: aRequest [ 
	"<KomSession> extract or create a session for aRequest"
	| session |
	mutex critical: 
		[self checkForCleanup.
		session := self 
					basicExtractSession: aRequest 
					ifAbsent: [self newSession].
		session touch].
	^ session
]

{ #category : #initialization }
ModSession >> initialize [
	super initialize.
	
	sessions := Dictionary new.
	mutex := Semaphore forMutualExclusion.
	lastCleanup := Time totalSeconds.
	"30 minutes"
	secondsToLive := 30 * 60
]

{ #category : #testing }
ModSession >> isSession [

	^true
]

{ #category : #private }
ModSession >> newSession [
	"PRIVATE: creates a new Session and stores it"
	| session |
	session := KomSession new.
	sessions at: session id put: session.
	^ session
]

{ #category : #processing }
ModSession >> processHttp [

	| session |
	session := self extractSession: HttpRequest current.
	KomSession current: session.
	self processSubModules ifFalse: [^false].
	HttpResponse current
		setCookieName: #SessionID
		value: session id
		path: '/'.
	^ true
]

{ #category : #accessing }
ModSession >> secondsToLive: anInteger [

	secondsToLive := anInteger
]

{ #category : #enumeration }
ModSession >> sessionsDo: aBlock [
	"Iterate over sessions."

	^ sessions valuesDo: aBlock
]
