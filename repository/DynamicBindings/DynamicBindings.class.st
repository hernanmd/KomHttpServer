"
DynamicBindings for Squeak
by Stephen Pair <spair@pairhome.net>

I am a dictionary with an added property that I can inherit associations from other instances (via the parent inst var).  I am intended to be used as a set of variable bindings that can be local to a process or shared among a group of processes.  I am an abstract class and should never be instantiated.  

Here's how DynamicBindings work:

You may create a hierarchy of DynamicBindings and directly manipulate the keys and values of those instances (just as you would any dictionary).  There is a root DynamicBindings that you may use to create new children if you like (but you can also create entirely separate hierarchies).  You can access this root with ""DynamicBindings root"".  To force a process to use one of your sets of DynamicBindings, you write code as follows (note, I only use 'PATH' to highlight the similarity with normal OS environment variables):

	myBindings _ DynamicBindings root newChild.
	myBindings at: #PATH put: '/bin:/usr/bin'.
	myBindings bindDuring: 
		[Bindings at: #PATH.  				""-> '/bin:/usr/bin'""
		Bindings at: #PATH put: ('/usr/local/bin:', (Bindings at: #PATH)).
		Bindings at: #PATH].  				""-> '/usr/local/bin:/bin:/usr/bin'""

For convenience, two methods have been added to Object that enable more direct access to bindings.  The following exampel is equivalent to the first:

	myBindings _ DynamicBindings root newChild.
	myBindings at: #PATH put: '/bin:/usr/bin'.
	myBindings bindDuring: 
		[#PATH binding.  				""-> '/bin:/usr/bin'""
		#PATH binding: ('/usr/local/bin:', (#PATH binding)).
		#PATH binding].  				""-> '/usr/local/bin:/bin:/usr/bin'""


The first line creates a new set of bindings that is a child of the root bindings.  Any variables set in the root bindings are also visible in this new child environment.

The second line sets the dynamic variable ""PATH"".

The third line uses the evaluates the argument block in the context of our new set of bindings.

The fourth line gets the value for the variable ""PATH"" (which we just set).

The fifth line in the above example modifies the environment variable ""PATH"", but only for the duration that the enclosing block is active.

Here is another example:

	#PATH binding: '/bin'.
	Bindings clamp:
		[#PATH binding: '/usr/bin'.
		#PATH binding]. 						""-> '/usr/bin'""
	#PATH binding.								""-> '/bin'""

This example shows the use of the #clamp: method to isolate a our dynamic bindings only for the duration of a block.  After the block finishes execution, the original set of bindings is restored.

Scoping semantics:

A dynamic variables' scope is defined at runtime by an enclosing activation context.  To locate the active lexicon of dynamic variables, the system follows the activation stack until a context is encountered that defines the active DynamicBindings (this lookup is implemented using the exception handling system).  Any changes to the active DynamicBindings are visible in all activation contexts where that set of DynamicBindings are being used (which may include contexts in more than one activation stack).

A bit about how it's implemented:

The bindings for a given method activation context are located using the exception handling mechanism (see BindingsLocator).  If a given stack does not have a handler that answers a set of bindings, then dummy contexts will be added to the top of the stack that will answer the global root set of bindings.

Unlike other implementations, DynamicBindings do not use the activation stack to define the hierarchy of bindings.  Instances of DynamicBindings have their own parent instance variable and will locate enclosing variable scopes by following the chain of parents (*not* by looking for enclosing handlers of BindingsLocator).  Using this design, we are able to accomodate a broader range of usage scenarios.

If you need to isolate the bindings of a given context stack such that future changes in the bindings are not visible to users of the current set of dynamic bindings (ie. if you use continuations), you can send the message #isolate to the BindingsAccessor (ie. use ""Bindings isolate"").

"
Class {
	#name : #DynamicBindings,
	#superclass : #IdentityDictionary,
	#instVars : [
		'parent'
	],
	#classVars : [
		'Root'
	],
	#category : #'DynamicBindings-Core'
}

{ #category : #accessing }
DynamicBindings class >> example [
	" DynamicBindings example "

	| sem1 sem2 proc1 proc2 |
	sem1 := Semaphore new.
	sem2 := Semaphore new.

	proc1 := [
		Bindings clamp: [
			#Test binding: 'Test #1'.

			"Wait here to demonstrate that we indeed have two
			different sets of bindings with two different 
			and concurrent values for #Test."
			sem1 wait.

			Transcript show: ('Proc1: ', #Test binding); cr.
		].
	] newProcess.

	proc2 := [
		Bindings clamp: [
			#Test binding: 'Test #2'.

			"Wait here to demonstrate that we indeed have two
			different sets of bindings with two different 
			and concurrent values for #Test."
			sem2 wait.

			Transcript show: ('Proc2: ', #Test binding); cr.
		]
	] newProcess.

	proc1 resume.
	proc2 resume.
	sem1 signal.
	sem2 signal.

]

{ #category : #'class initialization' }
DynamicBindings class >> initialize [
	"self initialize"

	Root 
		ifNil: [Root := DynamicBindings new]
		ifNotNil: [Root := DynamicBindings newFrom: Root].

]

{ #category : #'instance creation' }
DynamicBindings class >> newFrom: anotherRuntimeEnvironment [

	| answer |
	answer := self new.
	anotherRuntimeEnvironment associationsDo: [ :assn | answer add: assn].
	^answer
]

{ #category : #accessing }
DynamicBindings class >> root [

	^Root
]

{ #category : #accessing }
DynamicBindings >> at: key ifAbsent: aBlock [

	| assoc tmp |
	tmp := self.
	[(assoc := tmp array at: (tmp findElementOrNil: key)) == nil] 
		whileTrue: [(tmp := tmp parent) ifNil: [^aBlock value]].
	^assoc value

]

{ #category : #accessing }
DynamicBindings >> atThisLevel: key ifAbsent: aBlock [

	^super at: key ifAbsent: aBlock
]

{ #category : #accessing }
DynamicBindings >> bind: anObject to: anotherObject [

	^self at: anObject put: anotherObject
]

{ #category : #scheduling }
DynamicBindings >> bindDuring: aBlock [

	^aBlock valueWithBindings: self
]

{ #category : #accessing }
DynamicBindings >> bindingFor: anObject [

	^self at: anObject ifAbsent: [self error: 'binding not found']
]

{ #category : #accessing }
DynamicBindings >> bindingFor: anObject ifNotBound: aBlock [

	^self at: anObject ifAbsent: aBlock
]

{ #category : #scheduling }
DynamicBindings >> fork: aBlock [

	^aBlock forkWithBindings: self
]

{ #category : #scheduling }
DynamicBindings >> forkClamped: aBlock [

	^aBlock forkWithClampedBindings: self
]

{ #category : #scheduling }
DynamicBindings >> forkIsolated: aBlock [

	^aBlock forkWithIsolatedBindings: self
]

{ #category : #scheduling }
DynamicBindings >> isBound: anObject [

	^self includesKey: anObject
]

{ #category : #accessing }
DynamicBindings >> level [

	| tmp level |
	tmp := self.
	level := 0.
	[tmp == nil] whileFalse:
		[tmp := tmp parent.
		level := level + 1].
	^level
]

{ #category : #isolation }
DynamicBindings >> newChild [

	^self species new
		parent: self;
		yourself

]

{ #category : #accessing }
DynamicBindings >> parent [

	^parent
]

{ #category : #accessing }
DynamicBindings >> parent: aDynamicBindings [

	parent := aDynamicBindings
]

{ #category : #accessing }
DynamicBindings >> root [

	| tmp |
	tmp := self.
	[tmp parent notNil] whileTrue:
		[tmp := tmp parent].
	^tmp
]
