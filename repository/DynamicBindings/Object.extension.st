Extension { #name : #Object }

{ #category : #'*DynamicBindings' }
Object >> binding [
	"Answer the DynamicBinding for the receiver (if any)"

	^Bindings bindingFor: self ifNotBound: [nil]
]

{ #category : #'*DynamicBindings' }
Object >> binding: anObject [
	"Set the dynamic binding for the receiver, if anObject is nil, then 
	remove the receiver's dynamic binding (if any)"

	^anObject 
		ifNil: [self removeBinding]
		ifNotNil: [Bindings bind: self to: anObject]
]

{ #category : #'*DynamicBindings' }
Object >> hasBinding [
	"Answer whether or not the receiver has a dynamic binding"

	^Bindings includesKey: self
]

{ #category : #'*DynamicBindings' }
Object >> removeBinding [
	"Remove the dynamic binding associated with the receiver"

	^Bindings removeKey: self ifAbsent: []
]
