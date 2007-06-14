"
kom/4.12 (Comanche/4.12)

MultipartChunkHeader (kom/4.8; bolot 4/2/2001 18:52)
- in kom49 (or kom50) this will be used only for internal purposes
-- applications will access multipart form fields through regular fieldAt: technique

Comment from kom46:
- this is a hack (bolot 10/25/2000 17:17)
- store a part's (from a multipart message) header information:
-- header (raw)
-- properties (extracted and converted info, such as file-name, content-length, etc.)
"
Class {
	#name : #MultipartChunk,
	#superclass : #Object,
	#instVars : [
		'properties',
		'multipartBoundary',
		'stream'
	],
	#category : #'KomHttpServer-Protocol'
}

{ #category : #'instance creation' }
MultipartChunk class >> from: aDictionary [
	aDictionary isEmptyOrNil
		ifTrue: [^nil].
	^self new initializeFrom: aDictionary
]

{ #category : #accessing }
MultipartChunk >> contentType [
	^properties at: #contentType
]

{ #category : #accessing }
MultipartChunk >> fieldName [
	^properties at: #fieldName
]

{ #category : #accessing }
MultipartChunk >> fileName [
	^properties at: #fileName
]

{ #category : #accessing }
MultipartChunk >> fileName: aString [
	properties at: #fileName put: aString
]

{ #category : #'initialize-release' }
MultipartChunk >> initializeFrom: aDictionary [
	| header str fileName fieldName idx contentType |
	"PRE: all keys in aDictionary are low-case"
	header := aDictionary.
	properties := Dictionary new.
self flag: #todo.
	"parse the header, pick out: filename, etc."

	str := (header at: 'content-disposition' ifAbsent: ['']).
	fileName := fieldName := ''.

	idx := str findString: 'filename='.
	idx > 0 ifTrue:
		[fileName := str copyFrom: idx + 10 to: (str indexOf: $" startingAt: idx+10) - 1].
	properties at: #fileName put: fileName.

	idx := str findString: 'name='.
	idx > 0 ifTrue:
		[fieldName := str copyFrom: idx + 6 to: (str indexOf: $" startingAt: idx+6) - 1].
	properties at: #fieldName put: fieldName.

	contentType := header at: 'content-type' ifAbsent: [MIMEDocument defaultContentType].
	properties at: #contentType put: contentType.

"Transcript show: 'field=', fieldName; cr; show: 'file=', fileName; cr;
	show: 'content-type=', contentType; cr."

]

{ #category : #testing }
MultipartChunk >> isSaved [
	^(properties at: #isSaved ifAbsent: [false])
]

{ #category : #accessing }
MultipartChunk >> multipartBoundary [
	^multipartBoundary
]

{ #category : #'initialize-release' }
MultipartChunk >> multipartBoundary: aString [
	multipartBoundary := aString
]

{ #category : #accessing }
MultipartChunk >> saveToStream: outStream [ 
	"This method is really dumb, it reads the entire body of the 
	chunk before writing it onto outStream.  In the future, this will
	change to a better streaming mechanism to allow very large amounts
	of data to be read without requiring everything to fit into memory."

	| body origFileName boundary |
	self setSavedFlag.
	origFileName := self fileName.
	boundary := String crlf , self multipartBoundary.
	body := self stream upToAll: boundary.

	"IE4 for Mac appends 128 bytes of Mac file system info - must remove"
	body size >= 128 
		ifTrue: 
			[(body first asciiValue = 0 and: 
					[body second asciiValue = origFileName size 
						and: [(body copyFrom: 3 to: origFileName size + 2) = origFileName]]) 
				ifTrue: [body := body copyFrom: 129 to: body size]].
	outStream nextPutAll: body
]

{ #category : #accessing }
MultipartChunk >> setSavedFlag [
	properties at: #isSaved put: true
]

{ #category : #accessing }
MultipartChunk >> stream [

	^stream
]

{ #category : #accessing }
MultipartChunk >> stream: aReadableStream [

	stream := aReadableStream
]
