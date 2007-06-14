"
kom/4.10 (Comanche beta 4.10)
HttpFormDictionary
bolot 6/22/2001 12:09

- use this instead of plain Dictionary for GET and POST forms
- maintains multiple values for the same field
-- but is backwards compatible, #at: returns the first value (?)
-- so do #booleanAt:, #numberAt:
- to access the actual value at key, use #rawAt:
-- returns an OrderedCollection

TODO:
- file upload support
-- idea: first value is file name, second is FileStream?

Koubo 3/19/2002 12:25
fixed #at: and #at:ifAbsent: returns a String when the value had only one item. however, they returns a copied Collection of the value when it had multiple items.

"
Class {
	#name : #HttpFormDictionary,
	#superclass : #Dictionary,
	#category : #'KomHttpServer-Protocol'
}

{ #category : #accessing }
HttpFormDictionary >> at: key [
	^ self at: key ifAbsent: [self errorKeyNotFound]
]

{ #category : #accessing }
HttpFormDictionary >> at: key ifAbsent: aBlock [ 
	| value valueSize |
	value := super at: key ifAbsent: [^aBlock value].
	valueSize := value size.
	0 = valueSize 
		ifTrue: 
			["is this not absent?"

			value := aBlock value].
	value := (1 = valueSize) ifTrue: [value first] ifFalse: [value copy].
	^value
]

{ #category : #accessing }
HttpFormDictionary >> at: key put: value [
	(self includesKey: key)
		ifFalse: [super at: key put: (OrderedCollection new)].

	(self rawAt: key) add: value.

	^value
]

{ #category : #accessing }
HttpFormDictionary >> booleanAt: key [
	^(self rawAt: key) first = 'true'
]

{ #category : #accessing }
HttpFormDictionary >> booleansAt: key [
	^(self rawAt: key) collect: [:value | value == 'true']
]

{ #category : #accessing }
HttpFormDictionary >> numberAt: key [
	^[(self rawAt: key) first asNumber]
		ifError: [:err :rcvr | Float nan]
]

{ #category : #accessing }
HttpFormDictionary >> numbersAt: key [
	^(self rawAt: key) collect: [:value |
		[value asNumber] ifError: [:err :rcvr | Float nan]]
]

{ #category : #printing }
HttpFormDictionary >> printElementsOn: aStream [
	aStream nextPut: $(.
	self keysSortedSafely do:
		[:key | aStream print: key; nextPutAll: '->'; print: (self rawAt: key); space].
	aStream nextPut: $)
]

{ #category : #accessing }
HttpFormDictionary >> rawAt: key [
	^super at: key ifAbsent: [self errorKeyNotFound]
]

{ #category : #accessing }
HttpFormDictionary >> rawAt: key ifAbsent: aBlock [
	^super at: key ifAbsent: aBlock
]

{ #category : #accessing }
HttpFormDictionary >> stringAt: key [
	^(self rawAt: key) first
]

{ #category : #accessing }
HttpFormDictionary >> stringsAt: key [
	^(self rawAt: key) copy
]
