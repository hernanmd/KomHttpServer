"
I listen for TCP connections on a given port number.  

Instance variables:

	portNumber - the number of the port on which to listen for incoming connections

	handler - an object that is sent the #value: message whenever an incoming connection is established; the argument to this message is a connected socket

	socketsToDestroy - a list of sockets that need to be destroyed (usually a listening socket that is no longer needed)

Usage:

In the following example, a TcpListener is established on port 8123.  After evaluating the following example, if you open a transcript window and point a web browser to port 8123 of this machine (ie. http://localhost:8123/), you should see several http requests appear in the transcript.

	| count listener |
	count _ 0.
	listener _ TcpListener
		on: 8123
		handler: 
			[ :socket |
			count _ count + 1.
			Transcript show: socket getData.
			socket closeAndDestroy].
	listener forkAndListenWhile: [count < 5].

For an additional example of using TcpListener, see TcpService.

"
Class {
	#name : #TcpListener,
	#superclass : #Object,
	#instVars : [
		'portNumber',
		'handler',
		'socketsToDestroy',
		'address'
	],
	#category : #KomServices
}

{ #category : #preferences }
TcpListener class >> acceptTimeout [

	^#'TcpListener-acceptTimeout' binding ifNil: [10]
]

{ #category : #preferences }
TcpListener class >> acceptTimeout: seconds [

	^#'TcpListener-acceptTimeout' binding: seconds
]

{ #category : #preferences }
TcpListener class >> backlogSize [

	^#'TcpListener-backlogSize' binding ifNil: [10]
]

{ #category : #preferences }
TcpListener class >> backlogSize: anInteger [

	^#'TcpListener-backlogSize' binding: anInteger
]

{ #category : #preferences }
TcpListener class >> listenerDestroyDelay [

	^#'TcpListener-listenerDestroyDelay' binding ifNil: [10]
]

{ #category : #preferences }
TcpListener class >> listenerDestroyDelay: milliseconds [

	^#'TcpListener-listenerDestroyDelay' binding: milliseconds
]

{ #category : #'instance creation' }
TcpListener class >> on: aPort address: anAddress handler: aBlock [

	^self new initializeOnPort: aPort address: anAddress handler: aBlock 


]

{ #category : #'instance creation' }
TcpListener class >> on: portNumber handler: aValuable [

	^self new
		initializeOnPort: portNumber
		handler: aValuable

]

{ #category : #accessing }
TcpListener >> acceptTimeout [
	^self class acceptTimeout
]

{ #category : #accessing }
TcpListener >> address [
	^ address
]

{ #category : #accessing }
TcpListener >> address: aStringOrCollection [
	address := aStringOrCollection asIpByteArray
]

{ #category : #accessing }
TcpListener >> backlogSize [

	^self class backlogSize
]

{ #category : #private }
TcpListener >> bind: listener withBacklogSize: backlogSize [ 
	address 
		ifNil: 
			[ listener 
				listenOn: portNumber
				backlogSize: backlogSize ]
		ifNotNil: 
			[ listener 
				listenOn: portNumber
				backlogSize: backlogSize
				interface: address ]
]

{ #category : #'initialize-release' }
TcpListener >> destroySockets [
	socketsToDestroy notNil
		ifTrue: [ socketsToDestroy do: [ :ea | ea destroy ] ].
	socketsToDestroy := OrderedCollection new
]

{ #category : #private }
TcpListener >> forkAndListenWhile: aBlock [

	[self listenWhile: aBlock] fork

]

{ #category : #'initialize-release' }
TcpListener >> initialize [
	socketsToDestroy := OrderedCollection new
]

{ #category : #initialization }
TcpListener >> initializeOnPort: aPort address: anAddress handler: aValuableObject [ 
	self 
		initializeOnPort: aPort
		handler: aValuableObject.
	anAddress ifNotNil: [self address: anAddress]
]

{ #category : #'initialize-release' }
TcpListener >> initializeOnPort: aNumber handler: aValuableObject [ 
	portNumber := aNumber.
	handler := aValuableObject

]

{ #category : #private }
TcpListener >> listen [
	"This is the listening loop.  It runs forever accepting
	inbound sockect connections."

	self listenWhile: [true]
]

{ #category : #private }
TcpListener >> listenWhile: aBlock [
	"This is the listening loop.  It runs while aBlock evaluates
	to true.  When the loop terminates or when the process running
	the loop is terminated, any listening sockets will be destroyed."

	self socketClass initializeNetwork.
	[self pvtListenLoop: aBlock] ensure: [self destroySockets]

]

{ #category : #accessing }
TcpListener >> listenerDestroyDelay [

	^self class listenerDestroyDelay
]

{ #category : #private }
TcpListener >> newListener: backlogSize [
	"Create a new socket that listens on our port.  The backlog is how many simultaneous 
	connections to accept at the same time"

	[^self pvtNewListener: backlogSize] on: Error do: [].

	"Try one more time after initializing the network"
	Socket initializeNetwork.
	^self pvtNewListener: backlogSize.
]

{ #category : #accessing }
TcpListener >> portNumber [

	^portNumber
]

{ #category : #printing }
TcpListener >> printOn: aStream [

	aStream nextPutAll: (self class name asString, ' port: ', self portNumber asString).

]

{ #category : #private }
TcpListener >> pvtListenLoop: aBlock [
	| socket listener |

	listener := self newListener: self backlogSize.

	"If the listener is not valid then the we cannot use the
	BSD style accept() mechanism."
	listener isValid ifFalse: [^self pvtOldListenLoop: aBlock].

	aBlock whileTrue: 
		[Process terminationOkDuring: 
			[[socket := listener waitForAcceptFor: self acceptTimeout ifTimedOut: [nil]]
				ifCurtailed: [listener destroy]].
		socket ifNotNil:
			[socket isConnected
				ifTrue: [handler value: socket]
				ifFalse: [socket destroy].
			socket := nil].
		listener isValid ifFalse: 
			[(Delay forMilliseconds: self listenerDestroyDelay) wait.
			listener destroy.
			listener := self newListener: self backlogSize]]
]

{ #category : #private }
TcpListener >> pvtNewListener: backlogSize [ 
	"Create a new socket that listens on our port.  The backlog is how many simultaneous 
	connections to accept at the same time"
	| listener |
	listener := self socketClass newTCP.
	self socketsToDestroy add: listener.
	self 
		bind: listener
		withBacklogSize: backlogSize.
	^ listener
]

{ #category : #private }
TcpListener >> pvtOldListenLoop: aBlock [
	"see comment on ConnectionQueue>>oldStyleListenLoop"
	| socket |
	socket := nil.
	aBlock whileTrue:
		[socket ifNil:
			["try to create a new socket for listening"
			socket := Socket createIfFail: [nil]].
		socket 
			ifNil: [Process terminationOkDuring: [(Delay forMilliseconds: 100) wait]]
			ifNotNil:
				[socket isUnconnected ifTrue: 
					[self bind: socket withBacklogSize: self backlogSize.
					self socketsToDestroy add: socket].
				Process terminationOkDuring: 
					[[socket waitForConnectionUntil: (Socket deadlineSecs: 10)]
						ensure: [socket destroy]].
				socket isConnected
					ifTrue: 
						["connection established"
						handler value: socket.
						socket := nil]
					ifFalse:
						[socket isWaitingForConnection
							ifFalse: [socket destroy. socket := nil]]]]
]

{ #category : #accessing }
TcpListener >> socketClass [

	^Socket
]

{ #category : #accessing }
TcpListener >> socketsToDestroy [

	^socketsToDestroy ifNil: 
		[socketsToDestroy := OrderedCollection new].

]
