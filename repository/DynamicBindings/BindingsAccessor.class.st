"
I enable access to the current dynamic bindings.  My class initialization adds my default instance to the system dictionary as #Bindings.  This enables access to the active runtime environment using syntax like the following:

   Bindings at: #AProcessLocalVariable put: aValue
   Bindings at: #AProcessLocalVariable

I also allow for the creation of new DynamicBindings as follows:

   Bindings new.   ""Creates a new empty DynamicBindings instance""
   Bindings clamp: [].  ""Creates new bindings that inherit from the current bindings""


"
Class {
	#name : #BindingsAccessor,
	#superclass : #Object,
	#classVars : [
		'Default'
	],
	#category : #DynamicBindings
}

{ #category : #'class initialization' }
BindingsAccessor class >> default [

	^Default ifNil: [Default := self new]
]

{ #category : #'class initialization' }
BindingsAccessor class >> initialize [
	"self initialize"

	Smalltalk at: #Bindings put: self default.

]

{ #category : #'variable accessing' }
BindingsAccessor >> associationsDo: aBlock [

	^self pvtBindings associationsDo: aBlock
]

{ #category : #'variable accessing' }
BindingsAccessor >> at: aSymbol [

	^self pvtBindings at: aSymbol
]

{ #category : #'variable accessing' }
BindingsAccessor >> at: aSymbol ifAbsent: absBlock [

	^self pvtBindings at: aSymbol ifAbsent: absBlock
]

{ #category : #'variable accessing' }
BindingsAccessor >> at: aSymbol ifAbsentPut: absBlock [

	^self pvtBindings at: aSymbol ifAbsentPut: absBlock value
]

{ #category : #'variable accessing' }
BindingsAccessor >> at: aSymbol ifPresent: presentBlock [

	^self pvtBindings at: aSymbol ifPresent: presentBlock
]

{ #category : #'variable accessing' }
BindingsAccessor >> at: aSymbol put: obj [

	^self pvtBindings at: aSymbol put: obj
]

{ #category : #'variable accessing' }
BindingsAccessor >> bind: anObject to: anotherObject [

	^self pvtBindings bind: anObject to: anotherObject
]

{ #category : #'variable accessing' }
BindingsAccessor >> bindingFor: anObject ifNotBound: absBlock [

	^self pvtBindings at: anObject ifAbsent: absBlock
]

{ #category : #'environment control' }
BindingsAccessor >> clamp: aBlock [
"Ensures that any environment modifications that occur during the evaluation of aBlock will happen in an isolated environment and that the original environment will be restored after evaluation completes.  Concurrent changes in the parent bindings are visible while executing aBlock."

	^aBlock valueWithBindings: self pvtBindings newChild

]

{ #category : #'variable accessing' }
BindingsAccessor >> do: aBlock [

	^self pvtBindings do: aBlock
]

{ #category : #'environment accessing' }
BindingsAccessor >> explore [
	"This is just a handy way to allow you to directly explore the 
	global symbol 'Bindings'"

	self get explore
]

{ #category : #'environment accessing' }
BindingsAccessor >> get [

	^self pvtBindings
]

{ #category : #'variable accessing' }
BindingsAccessor >> includesKey: anObject [

	^self pvtBindings includesKey: anObject
]

{ #category : #'environment accessing' }
BindingsAccessor >> inspect [
	"This is just a handy way to allow you to directly inspect the 
	global symbol 'Bindings'"

	self get inspect
]

{ #category : #'variable accessing' }
BindingsAccessor >> isBound: anObject [

	^self pvtBindings isBound: anObject
]

{ #category : #'environment control' }
BindingsAccessor >> isolate [
	"Isolates the bindings of the active context such that changes to the 
	active bindings are not visible anywhere except that portion of the active
	stack for which the active bindings are assigned."

	| ctx |
	ctx := self pvtContext.
	ctx tempAt: 1 put: (ctx tempAt: 1) copy.
]

{ #category : #'environment control' }
BindingsAccessor >> isolate: aBlock [
"Ensures that any environment modifications that occur during the evaluation of aBlock will happen in an isolated environment and that the original environment will be restored after evaluation completes.  Concurrent changes in the parent bindings are visible while executing aBlock."

	^aBlock valueWithBindings: self pvtBindings copy

]

{ #category : #'variable accessing' }
BindingsAccessor >> keys [

	^self pvtBindings keys
]

{ #category : #'environment creation' }
BindingsAccessor >> new [
	"Creates a new runtime environment that is empty."

	^DynamicBindings new.
]

{ #category : #'environment creation' }
BindingsAccessor >> newChild [
	"Creates a new runtime environment that inherits from the current environment."

	^self get newChild

]

{ #category : #'environment accessing' }
BindingsAccessor >> parent [

	^self get parent
]

{ #category : #private }
BindingsAccessor >> pvtBindings [

	^self pvtContext tempAt: 1
]

{ #category : #private }
BindingsAccessor >> pvtContext [

	^BindingsLocator signal
]

{ #category : #'variable accessing' }
BindingsAccessor >> removeKey: aSymbol [

	^self pvtBindings removeKey: aSymbol
]

{ #category : #'variable accessing' }
BindingsAccessor >> removeKey: aSymbol ifAbsent: absBlock [

	^self pvtBindings removeKey: aSymbol ifAbsent: absBlock
]

{ #category : #'environment accessing' }
BindingsAccessor >> root [

	^self get root
]

{ #category : #'variable accessing' }
BindingsAccessor >> values [

	^self pvtBindings values
]
