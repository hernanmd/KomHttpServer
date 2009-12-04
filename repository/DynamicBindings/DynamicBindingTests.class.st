"
I test the DynamicBindings subsystem.
"
Class {
	#name : #DynamicBindingTests,
	#superclass : #TestCase,
	#category : #DynamicBindings
}

{ #category : #'as yet unclassified' }
DynamicBindingTests >> testAccessor1 [

	| val test1 |
	Bindings clamp:
		[#test binding: (val := 'Test Value').
		test1 := (#test binding == val).
		#test removeBinding].

	self assert: test1.
]

{ #category : #'as yet unclassified' }
DynamicBindingTests >> testAccessor2 [

	| val test1 test2 |
	Bindings clamp:
		[#test binding: (val := 'Test Value').
		test1 := (#test binding == val).
		#test removeBinding.
		test2 := ((Bindings at: #test ifAbsent: [ 'absent' ]) = 'absent')].

	self assert: test1.
	self assert: test2.
]

{ #category : #'as yet unclassified' }
DynamicBindingTests >> testFork [
	"In this test, we examine the isolation behavior when forking a process.  We are
	checking to ensure that changes made to the environment in the forked process do
	not impact the calling process.  We also check to make sure that the forked process
	gets the current environment from the calling process at the time of the fork."

	| sem test1 test2 test3 |
	Bindings clamp:
		[#test binding: 'Testing'.
		sem := Semaphore new.
			[#test2 binding: 'Testing2'.
			test1 := (#test binding = 'Testing').
			test2 := (#test2 binding = 'Testing2').
			#test binding: 'Testing3'.
			test3 := #test binding = 'Testing3'.
			sem signal] forkWithIsolatedBindings.
		sem wait.
		self assert: test1.
		self assert: test2.
		self assert: test3.
		self assert: (#test binding = 'Testing').
		self assert: (#test2 hasBinding not)].

	self assert: (#test hasBinding not).
	self assert: (#test2 hasBinding not).
]

{ #category : #'as yet unclassified' }
DynamicBindingTests >> testSharedRuntimeEnvironment [
	"In this test, we examine the isolation behavior when forking processes and when those
	processes share a runtime environment.  We are checking to ensure that both forked
	processes see the changes made to the shared runtime environment even when their
	own environments are isoldated from each other by a modification."

	| test1 test2 test3 bindings sem1 sem2 isolateSem1 isolateSem2 modSem1 modSem2 test4 |

	bindings := DynamicBindings root newChild.
	bindings at: #sharedVar put: 'Shared Value'.
	sem1 := Semaphore new.
	sem2 := Semaphore new.
	isolateSem1 := Semaphore new.
	isolateSem2 := Semaphore new.
	modSem1 := Semaphore new.
	modSem2 := Semaphore new.

	bindings forkClamped: 
		[test1 := #sharedVar binding = 'Shared Value'.
		#forceIsolation binding: 'testing'.
		isolateSem1 signal.
		modSem1 wait.
		test2 := #sharedVar binding = 'Shared Value 2'.
		sem1 signal].

	bindings forkClamped:
		[test3 := #sharedVar binding = 'Shared Value'.
		#forceIsolation binding: 'testing'.
		isolateSem2 signal.
		modSem2 wait.
		test4 := #sharedVar binding = 'Shared Value 2'.
		sem2 signal].

	isolateSem1 wait.
	isolateSem2 wait.
	bindings at: #sharedVar put: 'Shared Value 2'.
	modSem1 signal.
	modSem2 signal.
	sem1 wait.
	sem2 wait.

	self assert: test1.
	self assert: test2.
	self assert: test3.
	self assert: test4.


]
