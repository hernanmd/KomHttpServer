Extension { #name : #BlockContext }

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithBindings [
	"Create and schedule a new process that has the same 
	dynamic bindings as the active process"

	^self newProcessWithBindings resume

]

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithBindings: dynamicBindings [
	"Create and schedule a new process with the given dynamic bindings"

	^(self newProcessWithBindings: dynamicBindings) resume
]

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithClampedBindings [

	^self newProcessWithClampedBindings resume

]

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithClampedBindings: dynamicBindings [

	^(self newProcessWithClampedBindings: dynamicBindings) resume

]

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithIsolatedBindings [

	^self newProcessWithIsolatedBindings resume

]

{ #category : #'*DynamicBindings' }
BlockContext >> forkWithIsolatedBindings: dynamicBindings [

	^(self newProcessWithIsolatedBindings: dynamicBindings) resume

]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithBindings [
	"Create a new process that has the same dynamic bindings
	as the active process"

	^self newProcessWithBindings: Bindings get
]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithBindings: dynamicBindings [
	"Create a new process with the given dynamic bindings"

	^[self valueWithBindings: dynamicBindings] newProcess
]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithClampedBindings [
	"Create a new process with a nested set of the dynamicBindings of 
	the active process"

	^self newProcessWithClampedBindings: Bindings get


]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithClampedBindings: dynamicBindings [
	"Create a new process with a nested set of the given dynamicBindings"

	^[Bindings clamp: self] newProcessWithBindings: dynamicBindings

]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithIsolatedBindings [
	"Create a new process with a copy of the dynamicBindings of the 
	acitve process"

	^self newProcessWithIsolatedBindings: Bindings get


]

{ #category : #'*DynamicBindings' }
BlockContext >> newProcessWithIsolatedBindings: dynamicBindings [
	"Create a new process with a copy of the given dynamicBindings"

	^[Bindings isolate: self] newProcessWithBindings: dynamicBindings

]

{ #category : #'*DynamicBindings' }
BlockContext >> valueWithBindings: dynamicBindings [
	"Evaluate the receiver in the context of the given dynamicBindings"

	^self valueWithBindingsContext: thisContext

]

{ #category : #'*DynamicBindings' }
BlockContext >> valueWithBindingsContext: aContext [
	"Private. Evaluate the receiver in the context of the 
	given dynamicBindings context"

	^self
		on: BindingsLocator
		do: [ :n | n resume: aContext]
]
