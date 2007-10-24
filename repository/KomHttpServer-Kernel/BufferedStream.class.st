"
From Comanche 4.8 beta
bolot 4/2/2001 18:43

BufferStream

Comment in Com46:
- is-a ReadWriteStream on a String
- like a queue
  removeNext:/nextPutAll: protocol
"
Class {
	#name : #BufferedStream,
	#superclass : #Stream,
	#instVars : [
		'buffer',
		'startPos',
		'endPos'
	],
	#category : #'KomHttpServer-Kernel'
}

{ #category : #'instance creation' }
BufferedStream class >> on: aString [
	^self basicNew on: aString
]

{ #category : #accessing }
BufferedStream >> contents [
	"return contents, non-destructive"
	^buffer copyFrom: startPos to: endPos
]

{ #category : #testing }
BufferedStream >> includes: aChar [
	"answer whether buffer includes aChar within bounds"
	| tmp |
	tmp := buffer indexOf: aChar startingAt: startPos.
	^(tmp >= startPos) and: [tmp <= endPos]
]

{ #category : #testing }
BufferedStream >> includesAll: aString [
	"answer whether the buffer contains aString"
	| tmp |
	tmp := buffer findString: aString startingAt: startPos.
	^(tmp >= startPos) and: [tmp <= endPos]
]

{ #category : #testing }
BufferedStream >> isEmpty [
	^self size <= 0
]

{ #category : #accessing }
BufferedStream >> match: aString [
	self size < aString size
		ifTrue: [^false].
	(self next: aString size) = aString
		ifTrue: [^true]
		ifFalse: [self on: aString, self upToEnd].
	^false
]

{ #category : #accessing }
BufferedStream >> next [
	"return the next character"
	"consume it"
	^buffer at: (startPos := startPos + 1) - 1
]

{ #category : #accessing }
BufferedStream >> next: anInteger [
	"return next anInteger characters"
	"consumes them"
	^buffer copyFrom: startPos to: (startPos := startPos + anInteger) - 1
]

{ #category : #accessing }
BufferedStream >> nextPutAll: aString [
	buffer := (buffer copyFrom: startPos to: endPos), aString.
	startPos := 1.
	endPos := buffer size
]

{ #category : #'initialize-release' }
BufferedStream >> on: aString [
	buffer := aString.
	startPos := 1.
	endPos := buffer size
]

{ #category : #accessing }
BufferedStream >> peek [
	"return the next character without consuming it"
	"consume it"
	^buffer at: startPos
]

{ #category : #printing }
BufferedStream >> printOn: aStream [
	super printOn: aStream.
	aStream nextPutAll: '(', self size asString, ')'
]

{ #category : #'initialize-release' }
BufferedStream >> reset [
	"hack"
	self on: ''
]

{ #category : #accessing }
BufferedStream >> size [
	^endPos - startPos + 1
]

{ #category : #accessing }
BufferedStream >> upTo: aChar [
	"return String up to aChar, but not including"
	"consumes the returned string"
	| i |
	i := buffer indexOf: aChar startingAt: startPos.
	(i <= 0 or: [i > endPos])
		ifTrue: [^self upToEnd].
	^self next: (i-startPos)
]

{ #category : #accessing }
BufferedStream >> upToAll: aString [
	"return a string before the occurence of aString, if any"
	"consume it"
	| i |
	i := buffer findString: aString startingAt: startPos.
	(i <= 0 or: [i > endPos])
		ifTrue: [^self upToEnd].
	^self next: (i-startPos)
]

{ #category : #accessing }
BufferedStream >> upToEnd [
	"return buffer contents,
	consume all my buffer"
	| string |
	string := self contents.
	self reset.
	^string
]
