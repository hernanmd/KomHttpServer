"
I am a comanche service that listens for inbound TCP connectinos on a given port.

Instance Variables:

	portNumber - the TCP port number on which to listen for inbound connections

Usage:

Subclasses should override the #serve: method to process incoming TCP connections (a connected socket is passed as the sole argument to this method).  Starting and stopping instances of this class will start and stop listening on the given port number.

"
Class {
	#name : #TcpService,
	#superclass : #ApplicationService,
	#instVars : [
		'portNumber'
	],
	#classVars : [
		'PortAssignments'
	],
	#category : #KomServices
}

{ #category : #'class initialization' }
TcpService class >> initialize [
	"self initialize"

	PortAssignments := Dictionary new.
]

{ #category : #'instance creation' }
TcpService class >> on: portNumber [

	^self 
		on: portNumber
		priority: self defaultPriority 

]

{ #category : #'instance creation' }
TcpService class >> on: portNumber named: aString [

	^self 
		on: portNumber
		named: aString
		priority: self defaultPriority 

]

{ #category : #'instance creation' }
TcpService class >> on: portNumber named: aString priority: priorityNum [

	^self new
		name: aString;
		portNumber: portNumber;
		priority: priorityNum;
		yourself

]

{ #category : #'instance creation' }
TcpService class >> on: portNumber priority: priorityNum [

	^self new
		portNumber: portNumber;
		priority: priorityNum;
		yourself

]

{ #category : #'instance creation' }
TcpService class >> startOn: portNumber [

	^(self on: portNumber) start; yourself

]

{ #category : #'instance creation' }
TcpService class >> startOn: portNumber named: aString [

	^(self on: portNumber named: aString) start; yourself

]

{ #category : #'instance creation' }
TcpService class >> startOn: portNumber named: aString priority: aPriority [

	^(self on: portNumber named: aString priority: aPriority) start; yourself

]

{ #category : #running }
TcpService >> assignPort [

	self verifyPortAvailability: self portNumber.
	PortAssignments at: self portNumber put: self.

]

{ #category : #initialization }
TcpService >> initializeOnPort: portNum priority: priorityLevel [

	portNumber := portNum.
	priority := priorityLevel.

]

{ #category : #accessing }
TcpService >> portNumber [

	^portNumber
]

{ #category : #accessing }
TcpService >> portNumber: aNumber [

	self isRunning 
		ifTrue: 
			[self verifyPortAvailability: aNumber.
			self stop.
			portNumber := aNumber.
			self start.]
		ifFalse: 
			[portNumber := aNumber].

]

{ #category : #'startup and shutdown' }
TcpService >> prepareForStartup [
	"The squeak system just started up"
	Socket initializeNetwork.
]

{ #category : #printing }
TcpService >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: ' port: ', self portNumber asString
]

{ #category : #running }
TcpService >> runWhile: aBlock [

	[(TcpListener on: self portNumber handler: self)
		listenWhile: aBlock] ensure: [self unassignPort]

]

{ #category : #conversation }
TcpService >> serve: aSocket [
	"Subclasses should override this method to provide socket based 
	communications services.  Each new socket connection is handed to
	this method."

	self subclassResponsibility

]

{ #category : #'starting and stopping' }
TcpService >> start [

	self verifyOkToStart ifFalse: [^self].
	self assignPort.
	[super start] on: Error do: 
		[ :ex | self unassignPort. ex pass]

]

{ #category : #'starting and stopping' }
TcpService >> startOn: portNum [

	(self portNumber ~= portNum) ifTrue: [self stop].
	self portNumber: portNum.
	self start.
]

{ #category : #running }
TcpService >> unassignPort [

	PortAssignments at: self portNumber ifPresent: 
		[ :srv |
		srv == self ifTrue: 
			[PortAssignments removeKey: self portNumber]]


]

{ #category : #conversation }
TcpService >> value: aSocket [
	"This method is invoked by the ComancheListener"

	[self serve: aSocket] newProcessWithClampedBindings
		name: (self name, ' connection');
		resume

]

{ #category : #running }
TcpService >> verifyPortAvailability: aNumber [

	PortAssignments at: aNumber ifPresent: 
		[ :otherService | 
		self error: ('a service is already running on port ', self portNumber asString)].


]
