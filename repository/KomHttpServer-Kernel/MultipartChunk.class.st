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
MultipartChunk >> saveToAsyncFile: asyncFile [
	"This method is no longer dumb. It streams data chunk wise so it doesn't have to fit
	into memory all at once. Answers the number of bytes written to the stream.
	The logic for stripping 128 bytes from IE4/Mac is what makes it look complex."

	| boundary size firstBuffer origFileName sz time |
	self setSavedFlag.
time := (Time millisecondsToRun: [
	origFileName := self fileName.
	boundary := String crlf, self multipartBoundary.
	size := 0.
	firstBuffer := ''.

	self stream 
		upToAll: boundary
		bufferSize: 1000000 inBufferDo: [:buffer :start :stop |
			firstBuffer
				ifNil: [
					sz := stop - start + 1.
					asyncFile primWriteStart: asyncFile fileHandle
						fPosition: size fromBuffer: buffer at: start count: sz.
					size := size + sz]
				ifNotNil: [
					"IE4 for Mac appends 128 bytes of Mac file system info - must remove"
					firstBuffer := firstBuffer, (buffer copyFrom: start to: stop).
					firstBuffer size >= 128 ifTrue: [
						(firstBuffer first asciiValue = 0 and: 
							[firstBuffer second asciiValue = origFileName size 
								and: [(firstBuffer copyFrom: 3 to: origFileName size + 2) = origFileName]]) 
							ifTrue: [
								firstBuffer := firstBuffer copyFrom: 129 to: firstBuffer size].
						size := size + firstBuffer size.
						asyncFile primWriteStart: asyncFile fileHandle
							fPosition: 0 fromBuffer: firstBuffer at: 1 count: firstBuffer size.
						firstBuffer := nil]]].

	firstBuffer ifNotNil: [
		size := size + firstBuffer size.
		asyncFile primWriteStart: asyncFile fileHandle
				fPosition: 0 fromBuffer: firstBuffer at: 1 count: firstBuffer size].
]) / 1000.0.
	time > 0 ifTrue: [
	Transcript show: 'Time: ', time asString, ' Size: ', size asString, ' MB/s: ', ((size / (1024*1024)) /time) asString;cr ].
	^ size
]

{ #category : #accessing }
MultipartChunk >> saveToStream: outStream [
	"This method is no longer dumb. It streams data chunk wise so it doesn't have to fit
	into memory all at once. Answers the number of bytes written to the stream.
	The logic for stripping 128 bytes from IE4/Mac is what makes it look complex."

	| boundary size firstBuffer origFileName sz time |
	self setSavedFlag.
time := (Time millisecondsToRun: [
	origFileName := self fileName.
	boundary := String crlf, self multipartBoundary.
	size := 0.
	firstBuffer := ''.

	self stream 
		upToAll: boundary
		bufferSize: 1000000 inBufferDo: [:buffer :start :stop |
			firstBuffer
				ifNil: [
					sz := stop - start + 1.
					size := size + sz.
					outStream next: sz putAll: buffer startingAt: start]
				ifNotNil: [
					"IE4 for Mac appends 128 bytes of Mac file system info - must remove"
					firstBuffer := firstBuffer, (buffer copyFrom: start to: stop).
					firstBuffer size >= 128 ifTrue: [
						(firstBuffer first asciiValue = 0 and: 
							[firstBuffer second asciiValue = origFileName size 
								and: [(firstBuffer copyFrom: 3 to: origFileName size + 2) = origFileName]]) 
							ifTrue: [
								firstBuffer := firstBuffer copyFrom: 129 to: firstBuffer size].
						size := size + firstBuffer size.
						outStream nextPutAll: firstBuffer.
						firstBuffer := nil]]].

	firstBuffer ifNotNil: [
		size := size + firstBuffer size.
		outStream nextPutAll: firstBuffer].
]) / 1000.0.
	time > 0 ifTrue: [
	Transcript show: 'Time: ', time asString, ' Size: ', size asString, ' MB/s: ', ((size / (1024*1024)) /time) asString; cr].
	^ size
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
