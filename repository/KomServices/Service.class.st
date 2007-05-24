"
I am an abstract superclass.  Subclass me to create your own service classes whose instances can be started and stopped.  Subclasses should override the #runWhile: method to do something useful.  An instance of a ComancheService will have a Process associated with it while it is running.  

If you have the ""Named Process"" package loaded (available on SqueakMap), then processes associated with a ComancheService will be named like their service name for easier process debugging.

A Service can be in one of three states that are determined by the process and condiction instance variables:

	running: condition == #run & process notNil
	stopping: condition ~~ #run & process notNil 
	stopped: process isNil

Instance Variables:

name <String | nil> - An optional name for the given service

process <Process | nil> - The Process instance for a running service 

condition <#run | #stop> - Indicates whether the associated process should continue to run or whether it should stop running

dynamicBindings <DynamicBindings | nil> - A set of dynamic bindings that are active for the associated process; if used instead of global variables, then multiple services can run simultaneously a be bound to different sets of ""globals""; see the class comments for DynamicBindings for more details

priority <Number> - The priority at which the associated process will run

log - not yet implemented

"
Class {
	#name : #Service,
	#superclass : #Object,
	#instVars : [
		'name',
		'process',
		'stopSignal',
		'bindings',
		'priority'
	],
	#classVars : [
		'Services'
	],
	#category : #KomServices
}

{ #category : #registration }
Service class >> addService: aService [

	self services add: aService

]

{ #category : #accessing }
Service class >> defaultPriority [

	^Processor userBackgroundPriority
]

{ #category : #initialization }
Service class >> initialize [
	"self initialize"

	Services := Set new.
	Smalltalk addToStartUpList: self.
	Smalltalk addToShutDownList: self
]

{ #category : #'instance creation' }
Service class >> new [

	^super new initialize
]

{ #category : #'instance creation' }
Service class >> newNamed: aString [

	^self new name: aString; yourself
]

{ #category : #registration }
Service class >> removeService: aService [

	self services remove: aService ifAbsent: []

]

{ #category : #accessing }
Service class >> serviceNamed: aString [

	^self services 
		detect: [ :ea | ea name = aString ] 
		ifNone: [self error: 'No service by that name']
]

{ #category : #accessing }
Service class >> services [

	^Services
]

{ #category : #accessing }
Service class >> servicesNamed: aString [

	^self services select: [ :ea | ea name = aString ]
]

{ #category : #snapshots }
Service class >> shutDown [

	self services do: 
		[ :ea | ea prepareForShutdown]
]

{ #category : #private }
Service class >> sleepMethod [
	"This method is used to detect whether or not the 
	service is currently sleeping"

	^Service methodDict at: #sleepFor:
]

{ #category : #snapshots }
Service class >> startUp [

	self services do: 
		[ :ea | ea prepareForStartup].

]

{ #category : #private }
Service >> addStopSignal [

	stopSignal ifNil: [stopSignal := OrderedCollection new].
	^stopSignal add: Semaphore new.
]

{ #category : #accessing }
Service >> bindings [

	^bindings
]

{ #category : #accessing }
Service >> bindings: aDynamicBindings [

	bindings := aDynamicBindings
]

{ #category : #'starting and stopping' }
Service >> cancelStopRequest [
	"If the service is currently in a state of stopping, this method
	will return the service to a state of running"

	self releaseProcessesWaitingForStop.
	stopSignal := nil.


]

{ #category : #private }
Service >> checkRequiredBindings [

	| missingBindings |
	missingBindings := Set new.
	self requiredBindings do:
		[ :ea |
		(self bindings includesKey: ea) ifFalse: 
			[missingBindings add: ea]].
	missingBindings notEmpty ifTrue:
		[self error: 'service is missing one or more required bindings'.
		^false].
	^true
]

{ #category : #accessing }
Service >> defaultName [

	| title |
	title := self class name.
	^(title first isVowel ifTrue: ['an '] ifFalse: ['a ']), title
]

{ #category : #accessing }
Service >> defaultPriority [

	^self class defaultPriority
]

{ #category : #'initialize-release' }
Service >> initialize [
	self register.
	self initializeBindings.

]

{ #category : #'initialize-release' }
Service >> initializeBindings [
	"Subclasses may wish to establish an isolated set of dynamic
	bindings by overriding this method.  A subclass may also want
	to go ahead and set some dynamic variables.  For example:

		dynamicBindings := DynamicBindings root newChild.
		dynamicBindings at: #example put: 'a value'.

	In this example, the service is assigned a new set of dynamic bindings
	that inherits the bindings of root set of bindings and the variable #example
	is assigned a value. Code that is running in the context of this service can
	then access this variable using the expressions:

		#example binding
		#example binding: aNewValue
	"

	bindings := DynamicBindings root newChild.
]

{ #category : #queries }
Service >> isRunning [

	^process notNil and: [stopSignal isNil]
]

{ #category : #queries }
Service >> isSleeping [

	process ifNil: [^false].
	process suspendedContext ifNotNilDo: 
		[ :suspendedCtx |
		suspendedCtx stackDo: 
			[ :ctx |
			ctx method == self class sleepMethod
				ifTrue: [^true]]].
	^false
]

{ #category : #queries }
Service >> isStopped [

	^process isNil

]

{ #category : #queries }
Service >> isStopping [

	^process notNil and: [stopSignal notNil]
]

{ #category : #'starting and stopping' }
Service >> kill [
	"Forcibly kill the service regardless of whether it is in a state where it is 
	safe to do so.  Use stop unless the service is not responding."

	process ifNotNil: [process terminate].
	self processTerminated.

]

{ #category : #accessing }
Service >> name [

	^name ifNil: [self defaultName]
]

{ #category : #accessing }
Service >> name: aString [

	name := aString.
	process ifNotNil: [process name: aString].
]

{ #category : #'startup and shutdown' }
Service >> prepareForShutdown [
	"The system is about to shutdown"
]

{ #category : #'startup and shutdown' }
Service >> prepareForStartup [
	"The system just started up"
]

{ #category : #printing }
Service >> printOn: aStream [
	aStream nextPutAll: self name.
	self isRunning ifTrue: [aStream nextPutAll: ' [running]'].
	self isStopping ifTrue: [aStream nextPutAll: ' [stopping]'].
	self isStopped ifTrue: [aStream nextPutAll: ' [stopped]']
]

{ #category : #accessing }
Service >> priority [

	^priority ifNil: [self defaultPriority]
]

{ #category : #accessing }
Service >> priority: aNumber [

	priority := aNumber.
	process ifNotNil: [process priority: aNumber].
]

{ #category : #accessing }
Service >> process [

	^process
]

{ #category : #private }
Service >> processTerminated [
	"Private.  Nils out the process inst var (indication that the service is
	stopped and signals any processes that are waiting on the service to 
	stop."

	process := nil.
	self releaseProcessesWaitingForStop.

]

{ #category : #registration }
Service >> register [

	self class addService: self
]

{ #category : #private }
Service >> releaseProcessesWaitingForStop [
	"Private.  Signals any processes that are waiting on the service to stop."

	| tmp |
	stopSignal ifNotNil: 
		[tmp := stopSignal.
		stopSignal := nil.
		tmp do: [ :ea | ea signal]].
]

{ #category : #accessing }
Service >> requiredBindings [
	"Subclasses may wish to override this method to provide a list of objects 
	that the service requires to be registered in its dynamic bindings.  When
	attempting to start a service that has required bindings, if any of the 
	required bindings are missing, an exception will be signaled and the
	service will not start."

	^#()
]

{ #category : #running }
Service >> runWhile: aBlock [
	"subclasses should perform whatever service they provide
	in a loop that doesn't return until aBlock evaluates to true"

	"In this abstract class, we do nothing except wait on a 
	timer.  This is useful during development where we might
	want to create some do nothing services for testing purposes."

	"The two examples below illustrate the difference in using
	the #sleepFor: method and directly using a Delay.  If you 
	use the #sleepFor: method, then stopping the service will
	happen immediately while the service is sleeping; if you
	just use a Delay directly, then graceful shutdown cannot
	happen until after the delay completes.  To test this behavior
	start a service using ComancheService newNamed: 'sleep test' 
	and then use the Star Browser interface to start and stop the service
	(note: you can allow graceful termination during any block of 
	code using Process class>>terminationOkDuring:)."

	[aBlock value] whileTrue: [self sleepFor: 1000]
	"[aBlock value] whileTrue: [(Delay forSeconds: 10) wait]"
]

{ #category : #utility }
Service >> sleepFor: milliseconds [
	"If your service sleeps, use this method as it will indicate that it is
	safe to immediately terminate the process while it is sleeping."

	Process terminationOkDuring:
		[(Delay forMilliseconds: milliseconds) wait].

]

{ #category : #'starting and stopping' }
Service >> start [
	self verifyOkToStart ifFalse: [^self].
	process := 
			[[self runWhile: [stopSignal isNil and: [process == Processor activeProcess]]] 
				ensure: [self processTerminated]] 
					newProcessWithBindings: self bindings.
	(process respondsTo: #name:) ifTrue: [process name: self name].
	process priority: self priority.
	process resume
]

{ #category : #'starting and stopping' }
Service >> stop [
	"Gracefully request the service to stop.  This method returns immediately.  If
	you wish to wait until the service has stopped, follow this method with #waitForStop
	or #waitForStopUntil:."

	stopSignal := OrderedCollection new.
	process ifNotNil: [process okToTerminate ifTrue: [process terminate]].
	process ifNil: [stopSignal := nil].
]

{ #category : #private }
Service >> stopSignal [
	"<Semaphore | nil> Indicates whether the associated process should 
	be in the process of shutting down.  The semaphore will be signaled
	for all waiting process when the service thinks it has stopped (note,
	you should not rely solely on the semaphore signal to determine that
	the service is actually stopped, instead, wait then ask the service
	#isStopped)."

	^stopSignal
]

{ #category : #registration }
Service >> unregister [

	self stop.
	self class removeService: self
]

{ #category : #private }
Service >> verifyOkToStart [

	self isRunning ifTrue: [^false].
	self isStopping ifTrue: 
		[self error: 'Service is in the process of stopping'.
		^false].
	self checkRequiredBindings ifFalse: [^false].
	^true

]

{ #category : #'starting and stopping' }
Service >> waitForStop [
	"Wait until the service is stopped"

	self isStopped ifTrue: [^self].
	self isStopping 
		ifFalse: [^self error: 'service is not in the process of stopping'].
	[self isStopping] whileTrue: [self addStopSignal wait]
]

{ #category : #'starting and stopping' }
Service >> waitForStopUntil: deadline [ 
	"Wait until the service is stopped or the deadline is reached"

	self isStopped ifTrue: [^self].
	self isStopping 
		ifFalse: [^self error: 'service is not in the process of stopping'].
	[self isStopping and: [Time millisecondClockValue < deadline]] whileTrue:
		[self addStopSignal waitTimeoutMSecs: deadline - Time millisecondClockValue]
]

{ #category : #utility }
Service >> withBindingsDo: aBlock [

	^aBlock valueWithBindings: self bindings
]
