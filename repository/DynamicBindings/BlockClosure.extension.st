Extension { #name : #BlockClosure }

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithBindings [
	"Create and schedule a new process that has the same 
	dynamic bindings as the active process"

	^self newProcessWithBindings resume

]

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithBindings: dynamicBindings [
	"Create and schedule a new process with the given dynamic bindings"

	^(self newProcessWithBindings: dynamicBindings) resume
]

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithClampedBindings [

	^self newProcessWithClampedBindings resume

]

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithClampedBindings: dynamicBindings [

	^(self newProcessWithClampedBindings: dynamicBindings) resume

]

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithIsolatedBindings [

	^self newProcessWithIsolatedBindings resume

]

{ #category : #'*DynamicBindings' }
BlockClosure >> forkWithIsolatedBindings: dynamicBindings [

	^(self newProcessWithIsolatedBindings: dynamicBindings) resume

]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithBindings [
	"Create a new process that has the same dynamic bindings
	as the active process"

	^self newProcessWithBindings: Bindings get
]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithBindings: dynamicBindings [
	"Create a new process with the given dynamic bindings"

	^[self valueWithBindings: dynamicBindings] newProcess
]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithClampedBindings [
	"Create a new process with a nested set of the dynamicBindings of 
	the active process"

	^self newProcessWithClampedBindings: Bindings get


]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithClampedBindings: dynamicBindings [
	"Create a new process with a nested set of the given dynamicBindings"

	^[Bindings clamp: self] newProcessWithBindings: dynamicBindings

]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithIsolatedBindings [
	"Create a new process with a copy of the dynamicBindings of the 
	acitve process"

	^self newProcessWithIsolatedBindings: Bindings get


]

{ #category : #'*DynamicBindings' }
BlockClosure >> newProcessWithIsolatedBindings: dynamicBindings [
	"Create a new process with a copy of the given dynamicBindings"

	^[Bindings isolate: self] newProcessWithBindings: dynamicBindings

]

{ #category : #'*DynamicBindings' }
BlockClosure >> valueWithBindings: dynamicBindings [
	"Evaluate the receiver in the context of the given dynamicBindings"

	^self valueWithBindingsContext: thisContext

]

{ #category : #'*DynamicBindings' }
BlockClosure >> valueWithBindingsContext: aContext [
	"Private. Evaluate the receiver in the context of the 
	given dynamicBindings context"

	^self
		on: BindingsLocator
		do: [ :n | n resume: aContext]
]
