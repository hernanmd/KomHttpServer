"
kom/4.12 (Comanche/4.12)
bolot 2/20/2002 13:53
- rawUrl = the entire request string
- url = rawUrl up to ?
- queryString = rawUrl after the first ?
- rawUrl == url?queryString

HttpRequest (bolot 4/2/2001 18:51)
- HTTP request object wrapper
- handles details of HTTP
-- headers, formats, etc.
- as of kom47, handles multipart posts
- in kom49 (or kom50) a minor refactoring will happen
"
Class {
	#name : #HttpRequest,
	#superclass : #Object,
	#instVars : [
		'url',
		'stream',
		'header',
		'rawUrl',
		'properties'
	],
	#classVars : [
		'EndOfRequestHeaderMarker'
	],
	#category : #'KomHttpServer-Protocol'
}

{ #category : #parsing }
HttpRequest class >> addKey: key value: value toForm: dict multipleValues: boolean [
	boolean
		ifTrue: [dict at: key put: value]
		ifFalse: [(dict includesKey: key)
			ifFalse: [dict at: key put: value]
			ifTrue: [dict at: key modify: [:oldValue | oldValue, value]]]
]

{ #category : #bindings }
HttpRequest class >> current [

	^#'HttpRequest-Current' binding
]

{ #category : #bindings }
HttpRequest class >> current: anHttpRequest [

	#'HttpRequest-Current' binding: anHttpRequest
]

{ #category : #parsing }
HttpRequest class >> decodeUrlEncodedForm: string [
	^self decodeUrlEncodedForm: string multipleValues: false
]

{ #category : #parsing }
HttpRequest class >> decodeUrlEncodedForm: string multipleValues: boolean [
	| dict key value start end eqSignPos more |
	dict _ boolean ifTrue: [HttpFormDictionary new] ifFalse: [Dictionary new].
	string isEmptyOrNil ifTrue: [^dict].
	more _ true.
	start _ 1.
	[end _ string indexOf: $& startingAt: start.
	end == 0
		ifTrue: [end _ string size. more _ false]
		ifFalse: [end _ end - 1].
	eqSignPos _ string indexOf: $= startingAt: start.
	(eqSignPos > end or: [eqSignPos == 0])
		ifTrue: [key _ (key _ string copyFrom: start to: end) unescapePercents.
			value _ '']
		ifFalse: [key _ (key _ string copyFrom: start to: eqSignPos-1) unescapePercents.
			value _ (value _ string copyFrom: eqSignPos+1 to: end) unescapePercents].
	self addKey: key value: value toForm: dict multipleValues: boolean.
	start _ end + 2.
	more] whileTrue.

	^dict
]

{ #category : #defaults }
HttpRequest class >> defaultContentType [

	^MIMEDocument defaultContentType
]

{ #category : #defaults }
HttpRequest class >> defaultMethod [

	^'GET'
]

{ #category : #defaults }
HttpRequest class >> defaultProtocol [

	^'HTTP/1.0'
]

{ #category : #defaults }
HttpRequest class >> defaultUrl [

	^''
]

{ #category : #accessing }
HttpRequest class >> endOfRequestHeaderMarker [
	"This marks the end of an HTTP request (two consecutive CR-LFs)"

	^EndOfRequestHeaderMarker
]

{ #category : #authentication }
HttpRequest class >> hashPassword: aPassword [
	^SecureHashAlgorithm new hashMessage:
		(aPassword, ':', self secretWord)
]

{ #category : #'initialize-release' }
HttpRequest class >> initialize [
	EndOfRequestHeaderMarker _ String crlf, String crlf
]

{ #category : #parsing }
HttpRequest class >> parseHttpHeader: string [
	| dict key value start end more colonPos fieldDelims lastKey keyValueDelim |
	dict _ Dictionary new.
	string isEmptyOrNil ifTrue: [^dict].
	fieldDelims _ String crlf asCharacterSet.
	keyValueDelim _ $:.
	more _ true.
	start _ end _ 1.
	lastKey _ ''.
	[end _ string indexOfAnyOf: fieldDelims startingAt: start.
	end == 0
		ifTrue: [end _ string size. more _ false]
		ifFalse: [end _ end - 1].
	(end >= start and: [start < string size])
		ifTrue: [
			(string at: start) isSeparator
				ifTrue:
					[dict
						at: lastKey
						modify: [:item | item, (string copyFrom: start to: end)]]
				ifFalse:
					[colonPos _ string indexOf: keyValueDelim startingAt: start.
					(colonPos > end or: [colonPos == 0])
						ifTrue:
							[key _ (string copyFrom: start to: end) asLowercase.
							value _ '']
						ifFalse:
							[key _ (string copyFrom: start to: colonPos-1) asLowercase.
							value _ (string copyFrom: colonPos+1 to: end) withBlanksTrimmed]].
			key isEmpty
				ifFalse: [dict at: key put: value.
					lastKey _ key.
					key _ ''].
			start _ string skipDelimiters: String crlf startingAt: end+1].
	more] whileTrue.

	^dict
]

{ #category : #'instance creation' }
HttpRequest class >> readFromStream: aStream [

	^self new initializeFromStream: aStream
]

{ #category : #authentication }
HttpRequest class >> secretWord [
	"a string used in hashing passwords"
	^'ab74uihagAS'
]

{ #category : #'user authentication' }
HttpRequest >> clearPassword [
	self setCookieName: #ComanchePassword
		value: 'x'
		path: '/'
]

{ #category : #accessing }
HttpRequest >> contentLength [

	^self propertyAt: #contentLength ifAbsentPut: [
		(header at: 'content-length' ifAbsent: [0]) asNumber
	]
]

{ #category : #accessing }
HttpRequest >> contentType [
	| i contentType |
	^self propertyAt: #contentType ifAbsentPut: [
		contentType _ self header at: 'content-type' ifAbsent: [self defaultContentType].
		contentType ifNotNil: [i _ contentType indexOf: $;. "get rid of charset field"
			i > 0 ifTrue: [contentType _ contentType copyFrom: 1 to: i-1]].
		contentType asLowercase]
]

{ #category : #accessing }
HttpRequest >> cookies [
	"answer a dictionary with the cookies in the request"
	^ self
		propertyAt: #cookies
		ifAbsentPut: [self
				parseCookies: (self header
						at: 'cookie'
						ifAbsent: [''])]
]

{ #category : #defaults }
HttpRequest >> defaultContentType [

	^self class defaultContentType
]

{ #category : #defaults }
HttpRequest >> defaultMethod [

	^self class defaultMethod
]

{ #category : #defaults }
HttpRequest >> defaultProtocol [

	^self class defaultProtocol
]

{ #category : #defaults }
HttpRequest >> defaultUrl [

	^self class defaultUrl
]

{ #category : #'initialize-release' }
HttpRequest >> destroy [
	stream close.
	stream _ nil
]

{ #category : #accessing }
HttpRequest >> endOfRequestHeaderMarker [
	^self class endOfRequestHeaderMarker
]

{ #category : #accessing }
HttpRequest >> fields [
	"Answer the fields (post or get) for the given request"

	| tmp |
	^self propertyAt: #fields ifAbsentPut:
		[tmp _ self getFields copy.
		self postFields associationsDo: [ :assn | tmp add: assn].
		tmp]

]

{ #category : #accessing }
HttpRequest >> firstLineOn: strm [

	strm nextPutAll: self method.
	strm nextPut: $ .
	strm nextPutAll: self rawUrl.
	strm nextPut: $ .
	strm nextPutAll: self protocol.

]

{ #category : #accessing }
HttpRequest >> getFields [
	"retrieve fields encoded in the URL: http://aha/ha?a=1&b=2"
	| in |
	^self propertyAt: #getFields ifAbsentPut: [
		((in _ rawUrl indexOf: $?) > 0) ifTrue: [
			self class decodeUrlEncodedForm: 
				(rawUrl copyFrom: (in + 1) to: rawUrl size)
				multipleValues: self multiValueFormFields
		] ifFalse: [
			self multiValueFormFields
				ifTrue: [HttpFormDictionary new]
				ifFalse: [Dictionary new].
		].
	]
]

{ #category : #'user authentication' }
HttpRequest >> getUsername [
	^self cookies at: #ComancheUsername ifAbsent: []
]

{ #category : #'user authentication' }
HttpRequest >> hashPassword: aPassword [ 

	^ self class hashPassword: aPassword
]

{ #category : #accessing }
HttpRequest >> header [
	^header
]

{ #category : #accessing }
HttpRequest >> header: aDict [
	header _ aDict
]

{ #category : #accessing }
HttpRequest >> headerAt: aKey [

	^ header at: aKey
]

{ #category : #accessing }
HttpRequest >> headerAt: aKey ifAbsent: aBlock [

	^ header at: aKey ifAbsent: aBlock
]

{ #category : #accessing }
HttpRequest >> host [
	^self propertyAt: #host ifAbsentPut: [self header at: 'host' ifAbsent: []]
]

{ #category : #'initialize-release' }
HttpRequest >> initRemoteAddress [
	self remoteAddress: stream socket remoteAddress
]

{ #category : #'initialize-release' }
HttpRequest >> initStatusString: aString [ 
	| statusLine |
	statusLine := aString findTokens: ' '.
	(statusLine size between: 2 and: 3) 
		ifTrue: 
			[self method: statusLine first.
			rawUrl := statusLine second.
			url := (rawUrl copyUpTo: $?) unescapePercents.
			url size + 1 < rawUrl size 
				ifTrue: [self queryString: (rawUrl copyFrom: url size + 2 to: rawUrl size)].
			self protocol: statusLine third asUppercase]
		ifFalse: [^self error: 'invalid http status line']
]

{ #category : #'initialize-release' }
HttpRequest >> initialize [
	super initialize.
	properties := IdentityDictionary new
]

{ #category : #'initialize-release' }
HttpRequest >> initializeFromStream: aStream [
	stream _ aStream.
	self initRemoteAddress.
	self timestamp: Time totalSeconds.
	self readRequestHeaderFrom: stream.
]

{ #category : #testing }
HttpRequest >> isGetRequest [

	^self method = 'GET'
]

{ #category : #testing }
HttpRequest >> isHeaderRequest [

	^self method = 'HEAD'
]

{ #category : #testing }
HttpRequest >> isPersistent [
	| proto answer |

	self propertyAt: #persistentConnection ifPresent: [ :x | ^x ].
	proto _ self protocol.

	"If we can't figure out the protocol, default to non-persistent connections"
	answer _ false.

	"For HTTP/1.0, the default is non-persistent connections"
	proto = 'HTTP/1.0' ifTrue:
		[answer _ (self header at: 'connection' ifAbsent: ['']) 
			asLowercase = 'keep-alive'].

	"For HTTP/1.1, the default is persistent connections"
	proto = 'HTTP/1.1' ifTrue:
		[answer _ (self header at: 'connection' ifAbsent: ['']) 
			asLowercase ~= 'close'].

	self propertyAt: #persistentConnection put: answer.
	^answer

]

{ #category : #testing }
HttpRequest >> isPostMultipart [
	"Is this request a POST with multipart form data?"

	^self isPostRequest and: [self contentType = MIMEDocument contentTypeMultipart]
]

{ #category : #testing }
HttpRequest >> isPostRequest [

	^self method = 'POST'
]

{ #category : #'user authentication' }
HttpRequest >> isUsername: aUsername password: aPassword [
	| pwHash cookieUsername cookiePassword |
	cookieUsername _ self cookies at: #ComancheUsername ifAbsent: [^false].
	cookieUsername = aUsername ifFalse: [^false].

	cookiePassword _ self cookies at: #ComanchePassword ifAbsent: [^false].
	pwHash _ self hashPassword: aPassword.
	^cookiePassword = pwHash asString
]

{ #category : #accessing }
HttpRequest >> localAddress [
	"Answer the address of the request originator"

	^self propertyAt: #localAddress
		ifAbsentPut: 
			[stream socket localAddress]

]

{ #category : #accessing }
HttpRequest >> localPort [
	"Answer the address of the request originator"

	^self propertyAt: #localPort
		ifAbsentPut: 
			[stream socket localPort]

]

{ #category : #accessing }
HttpRequest >> method [
	^self propertyAt: #method ifAbsent: ['GET']
]

{ #category : #accessing }
HttpRequest >> method: aString [
	self propertyAt: #method put: aString
]

{ #category : #accessing }
HttpRequest >> multiValueFormFields [
	^self propertyAt: #multiValueFormFields ifAbsent: [false]
]

{ #category : #accessing }
HttpRequest >> multiValueFormFieldsDisable [
	"disable use of multi-value form fields"
	"thus, if the status changed, need to expunge GET/POST fields if already parsed"
	self multiValueFormFields
		ifTrue: [self propertyAt: #multiValueFormFields put: false.
			self removePropertyAt: #getFields ifAbsent: [].
			self removePropertyAt: #postFields ifAbsent: [].			
			]
]

{ #category : #accessing }
HttpRequest >> multiValueFormFieldsEnable [
	"enable use of multi-value form fields"
	"thus, if the status changed, need to expunge GET/POST fields if already parsed"
	self multiValueFormFields
		ifFalse: [self propertyAt: #multiValueFormFields put: true.
			self removePropertyAt: #getFields ifAbsent: [].
			self removePropertyAt: #postFields ifAbsent: [].			
			]
]

{ #category : #'multipart forms' }
HttpRequest >> multipartBoundary [
	| str idx |
	"boundary specification in the HTTP header looks like:
	Content-Type: multipart/form-data; boundary=BOUNDARY "

	^self propertyAt: #multipartBoundary ifAbsentPut:
		[(self contentType beginsWith: MIMEDocument contentTypeMultipart)
			ifTrue: ["contentType gets lowercased, so access the raw header"
				str _ header at: 'content-type' ifAbsent: [ '' ].
				idx _ str indexOf: $=.
				'--', (str copyFrom: idx + 1 to: str size)]
			ifFalse: [ nil ]]
]

{ #category : #'multipart forms' }
HttpRequest >> multipartFormFieldsDo: aBlock [
	"USAGE:
	request multipartFormFieldsDo: 
		[:chunk |
		chunk saveToStream: aStream]."
	"NOTE: if the chunk is not saved, save it after aBlock"

	| mChunk aFieldValue |
	(self method = 'POST' and: [self contentType = MIMEDocument contentTypeMultipart])
		ifFalse: [^nil].

	stream peekForAll: self multipartBoundary.
	[stream atEnd or: [stream peekForAll: '--']] whileFalse:
		[stream next: 2.  "Advance over CRLF"
		mChunk := self nextChunkHeader.
		aBlock value: mChunk.
		mChunk isSaved ifFalse: 
			[mChunk fileName isEmptyOrNil
			ifFalse: [mChunk saveToStream: (DummyStream on: String new)]
			ifTrue:
				[aFieldValue := String streamContents: 
					[:aStream |
					mChunk saveToStream: aStream].
				self postFields at: mChunk fieldName put: aFieldValue]]]
]

{ #category : #accessing }
HttpRequest >> networkHost [

	^self propertyAt: #networkHost ifAbsentPut: 
		[NetworkHost fromString: self host].


]

{ #category : #'multipart forms' }
HttpRequest >> nextChunkHeader [
	"Read the next multipart data chunk's header"

	| string dict mChunk |
	string _ stream upToAll: self endOfRequestHeaderMarker.
	dict _ self class parseHttpHeader: string.
	mChunk _ MultipartChunk from: dict.
	mChunk stream: self stream.
	mChunk multipartBoundary: self multipartBoundary.
	^mChunk
]

{ #category : #private }
HttpRequest >> parseCookies: aString [ 
	"PRIVATE: Parse a string in the format:  
	Cookie: NAME1=OPAQUE_STRING1; NAME2=OPAQUE_STRING2 ..."

	| dict |
	dict := Dictionary new.
	(aString findTokens: ';') do: 
			[:pairStr | 
			| pair |
			pair := pairStr findTokens: '='.
			pair size = 2 
				ifTrue: 
					[| key value |
					key := pair first withBlanksTrimmed asSymbol.
					value := pair second withBlanksTrimmed.
					dict at: key put: value]
				ifFalse: 
					["self log: 'Cookie invalid pair format: ''' , pairStr , ''''"

					]].
	^dict
]

{ #category : #'as yet unclassified' }
HttpRequest >> pathParts [

	^self url findTokens: '/'
]

{ #category : #accessing }
HttpRequest >> postFields [
	"Answer the multipart fields for a post request (if in fact this is a
	POST request"

	^self propertyAt: #postFields ifAbsentPut: [
		" parse POST fields in the body of request, if it's standard form data "

		(self isPostRequest and: [ 
			self contentType = MIMEDocument contentTypeFormData 
		]) ifTrue: [
			self class
				decodeUrlEncodedForm: self rawPostFields
				multipleValues: true.
		] ifFalse: [
			Dictionary new
		].
	]
]

{ #category : #printing }
HttpRequest >> printOn: printStream [
	printStream nextPutAll: self class name;
		nextPutAll: ' (URL=', self url asString;
		nextPutAll: '; protocol=', self protocol asString;
		nextPutAll: '; header=', self header asString;
		nextPutAll: '; getFields=', self getFields asString;
		nextPutAll: '; postFields=', self postFields asString;
		nextPutAll: ')'
]

{ #category : #properties }
HttpRequest >> propertyAt: aSymbol [

	^properties at: aSymbol
]

{ #category : #properties }
HttpRequest >> propertyAt: aSymbol ifAbsent: absentBlock [

	^properties at: aSymbol ifAbsent: absentBlock
]

{ #category : #properties }
HttpRequest >> propertyAt: aSymbol ifAbsentPut: absentBlock [

	^properties at: aSymbol ifAbsentPut: absentBlock
]

{ #category : #properties }
HttpRequest >> propertyAt: aSymbol ifPresent: presentBlock [

	^properties at: aSymbol ifPresent: presentBlock
]

{ #category : #properties }
HttpRequest >> propertyAt: aSymbol put: anObject [

	properties at: aSymbol put: anObject
]

{ #category : #accessing }
HttpRequest >> protocol [
	^self propertyAt: #protocol ifAbsent: [self defaultProtocol]
]

{ #category : #accessing }
HttpRequest >> protocol: aString [
	^self propertyAt: #protocol put: aString
]

{ #category : #accessing }
HttpRequest >> queryString [

	^self propertyAt: #queryString ifAbsent: [ nil ]
]

{ #category : #accessing }
HttpRequest >> queryString: aString [

	^self propertyAt: #queryString put: aString
]

{ #category : #accessing }
HttpRequest >> rawPostFields [
	"save the POST form fields as is, for future processing, see #postFields"
	"reasons: 1) lazy form processing;
		2) allow the app to specify whether it wants multiple values for fields"

	^self propertyAt: #rawPostFields ifAbsentPut: [

		(self isPostRequest and: [ 
			self contentType = MIMEDocument contentTypeFormData 
		]) ifTrue: [
			stream next: self contentLength
		] ifFalse: [
			''
		].
	]
]

{ #category : #accessing }
HttpRequest >> rawUrl [
	^rawUrl
]

{ #category : #'initialize-release' }
HttpRequest >> readRequestHeaderFrom: aStream [
	| reqHeader |
	reqHeader _ ReadStream on: 
		(aStream upToAll: self endOfRequestHeaderMarker).
	self initStatusString: (reqHeader upToAll: String crlf).
	self header: (self class parseHttpHeader: reqHeader upToEnd).
	self rawPostFields. "force reading/parsing post fields"
]

{ #category : #accessing }
HttpRequest >> referer [
	^self propertyAt: #referer ifAbsentPut: [
		header at: 'referer' ifAbsent: [ nil ]
	]
]

{ #category : #accessing }
HttpRequest >> remoteAddress [
	^self propertyAt: #remoteAddress ifAbsent: [nil]
]

{ #category : #accessing }
HttpRequest >> remoteAddress: aRemoteAddress [
	self propertyAt: #remoteAddress put: aRemoteAddress
]

{ #category : #properties }
HttpRequest >> removePropertyAt: aSymbol [

	properties removeKey: aSymbol
]

{ #category : #properties }
HttpRequest >> removePropertyAt: aSymbol ifAbsent: aBlock [

	^properties removeKey: aSymbol ifAbsent: aBlock
]

{ #category : #'response cookies' }
HttpRequest >> responseCookies [
	"cookies that need to be set"
	^self propertyAt: #responseCookies ifAbsentPut: [OrderedCollection new]
]

{ #category : #'user authentication' }
HttpRequest >> secretWord [
	^ self class secretWord
]

{ #category : #'user authentication' }
HttpRequest >> session [

	^ KomSession current
]

{ #category : #'response cookies' }
HttpRequest >> setCookieName: nameString value: valueString expiresDate: expiresDate expiresTime: expiresTime path: pathString domain: domainString secure: secureBoolean [ 
	"set a cookie in the Response"
	| temp |
	temp _ String new writeStream.
	"NAME=VALUE"
	temp nextPutAll: nameString;
		 nextPut: $=;
		 nextPutAll: valueString.
	"; expires=Wdy, DD-Mon-YYYY HH:MM:SS GMT"
	(expiresDate notNil and:[ expiresTime notNil])
		ifTrue: [temp nextPutAll: '; expires=';
				 nextPutAll: expiresDate weekday;
				 nextPutAll: ', '.
			expiresDate printOn: temp format: #(1 2 3 $- 2 2 2 ).
			temp nextPutAll: ' ';
				 nextPutAll: expiresTime print24;
				 nextPutAll: ' GMT'].
	"; path=PATH"
	pathString notNil
		ifTrue: [temp nextPutAll: '; path=';
				 nextPutAll: pathString].
	"; domain=DOMAIN"
	domainString notNil
		ifTrue: [temp nextPutAll: '; domain=';
				 nextPutAll: domainString].
	"; secure"
	(secureBoolean notNil
			and: [secureBoolean])
		ifTrue: [temp nextPutAll: '; secure'].
	""
	self responseCookies add: temp contents
]

{ #category : #'response cookies' }
HttpRequest >> setCookieName: nameString value: valueString path: pathString [ 
	"set a cookie in the Response"
	self
		setCookieName: nameString
		value: valueString
		expiresDate: nil
		expiresTime: nil
		path: pathString
		domain: nil
		secure: nil
]

{ #category : #'user authentication' }
HttpRequest >> setUsername: aUsername [
	"save the username in a cookie"
	"make it expire very far into the future"
	self
		setCookieName: #ComancheUsername
		value: aUsername
		expiresDate: (Date today addDays: 1000)
		expiresTime: Time now
		path: '/'
		domain: nil
		secure: nil.

	self flag: #todo.
	"allow for multiple usernames"
]

{ #category : #'user authentication' }
HttpRequest >> setUsername: aUsername password: aPassword [
	"save the username/password in cookies"
	| pwHash |
	self setUsername: aUsername.
	pwHash _ self hashPassword: aPassword.
	self
		setCookieName: #ComanchePassword
		value: pwHash asString
		expiresDate: (Date today addDays: 1000)
		expiresTime: Time now
		path: '/'
		domain: nil
		secure: nil.

	self flag: #todo.
	"allow for multiple usernames"
]

{ #category : #accessing }
HttpRequest >> stream [
	^stream
]

{ #category : #accessing }
HttpRequest >> timestamp [

	^self propertyAt: #timestamp ifAbsent: [ nil ]
]

{ #category : #accessing }
HttpRequest >> timestamp: aTimestamp [

	self propertyAt: #timestamp put: aTimestamp
]

{ #category : #accessing }
HttpRequest >> url [
	^url
]

{ #category : #accessing }
HttpRequest >> url: aUrl [
	url _ aUrl
]

{ #category : #accessing }
HttpRequest >> user [
	"currently, only basic authentication is supported"

	| userID i |
	userID := self header at: 'authorization' ifAbsent: [^nil].
	userID := (userID notNil and: [(i := userID findString: 'Basic ') > 0]) 
		ifTrue: [userID copyFrom: i + 6 to: userID size]
		ifFalse: [nil].
	^userID
]

{ #category : #'user authentication' }
HttpRequest >> userObject: anObject [
	^self session ifNotNil: [self session userObject: anObject]
]

{ #category : #printing }
HttpRequest >> writeOn: aStream [
	"this can be used to form a client-side request and send it over network"
	aStream nextPutAll: self method, ' ', self url, ' ', self protocol, String crlf.
	self header keysAndValuesDo: [:key :value |
		aStream nextPutAll: key, ': ', value, String crlf].
	aStream nextPutAll: String crlf.
	"aStream nextPutAll: self body asString"
]