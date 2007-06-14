"
I am a very basic authentication database.  My passwords instvar is a dictionary whose keys are user names and values are hexadecimal encodings of passwords.  Subclasses could override the encode: and decode:using: methods to provide a better ""encryption"" of the passwords.  That wasn't done in this class because it would add a dependency on the cryptography package.  I am designed to be used with ModAuth, which sends us the message #verifyPassword:forUser: to validate user ids and passwords.
"
Class {
	#name : #KomAuthDb,
	#superclass : #Object,
	#instVars : [
		'passwords'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'instance creation' }
KomAuthDb class >> new [

	^super new initialize
]

{ #category : #accessing }
KomAuthDb >> addUser: aString withPassword: password [

	self passwords at: aString put: (self encode: password)
]

{ #category : #'encode-decode' }
KomAuthDb >> decode: encodedPassword using: aPassword [

	^String streamContents: 
		[ :strm |
		1 to: encodedPassword size by: 2 do: 
			[ :in |
			strm nextPut: 
				(Character value: 
					(((('0123456789ABCDEF' indexOf: (encodedPassword at: in)) - 1) * 16) +
					(('0123456789ABCDEF' indexOf: (encodedPassword at: (in + 1))) - 1)))]]

]

{ #category : #'encode-decode' }
KomAuthDb >> encode: password [

	^String streamContents: 
		[ :strm |
		password do: [ :ea | strm nextPutAll: ea hex]]
]

{ #category : #accessing }
KomAuthDb >> includesUser: userName [

	^self passwords includesKey: userName
]

{ #category : #'initialize-release' }
KomAuthDb >> initialize [
	super initialize.
	passwords := Dictionary new
]

{ #category : #accessing }
KomAuthDb >> passwords [

	^passwords
]

{ #category : #accessing }
KomAuthDb >> removeUser: userName [

	^self passwords removeKey: userName
]

{ #category : #'password verification' }
KomAuthDb >> verifyPassword: aPassword forUser: userName [

	(self includesUser: userName) ifFalse: [^false].
	^(self decode: (self passwords at: userName) using: aPassword) = aPassword

]
