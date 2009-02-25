"
kom/4.12 (Comanche/4.12)
bolot 2/20/2002 13:55
- cookies support
- defaultChunkSize delegates to Kom5Preferences

HttpResponse (bolot 4/2/2001 18:52)

Comment from kom46:
I am a response to an HttpRequest.  I can formulate an HTTP response and send it out over a socket.  An HttpAdapter will accept an HttpRequest, dispatch a method call to an HttpPlug (which will result in a stream or an error), and then formulat an instance of me to deliver the response to the client.
"
Class {
	#name : #HttpResponse,
	#superclass : #Object,
	#instVars : [
		'status',
		'contents',
		'contentType',
		'contentLength',
		'fields',
		'cookies'
	],
	#classVars : [
		'StatusSymbols',
		'StatusCodes'
	],
	#category : #'KomHttpServer-Protocol'
}

{ #category : #bindings }
HttpResponse class >> current [

	^#'HttpResponse-Current' binding
]

{ #category : #bindings }
HttpResponse class >> current: anHttpResponse [

	#'HttpResponse-Current' binding: anHttpResponse
]

{ #category : #'instance creation' }
HttpResponse class >> fromFileStream: aStream [

	^self basicNew
		status: #ok;
		"fieldAt: 'Expires' put: 'Thu, 15 Apr 2010 20:00:00 GMT';"
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: aStream contentType;
		contents: aStream;
		yourself

	
]

{ #category : #'instance creation' }
HttpResponse class >> fromMIMEDocument: aMIMEDoc [
	| content |

	content := aMIMEDoc content.
	content isString ifTrue:
		[content := ReadStream on: content].
	^self basicNew
		status: #ok;
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: aMIMEDoc contentType;
		contents: content;
		yourself

	
]

{ #category : #'instance creation' }
HttpResponse class >> fromStream: aStream [

	^self basicNew
		status: #ok;
		"fieldAt: 'Expires' put: 'Thu, 15 Apr 2010 20:00:00 GMT';"
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: aStream contentType;
		contents: aStream;
		yourself

	
]

{ #category : #'instance creation' }
HttpResponse class >> fromStream: aStream contentType: mimeTypeString [

	^self basicNew
		status: #ok;
		"fieldAt: 'Expires' put: 'Thu, 15 Apr 2010 20:00:00 GMT';"
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: mimeTypeString;
		contents: aStream;
		yourself

	
]

{ #category : #'instance creation' }
HttpResponse class >> fromString: aString [

	^self basicNew
		status: #ok;
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: MIMEDocument contentTypeHtml;
		contents: (ReadStream on: aString);
		yourself
]

{ #category : #'instance creation' }
HttpResponse class >> fromString: aString contentType: contentTypeString [

	^self basicNew
		status: #ok;
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: contentTypeString;
		contents: (ReadStream on: aString);
		yourself
]

{ #category : #'instance creation' }
HttpResponse class >> fromUrl: aUrl [
	^self basicNew
		status: #tempMoved;
		fieldAt: 'Location' put: aUrl asString;
		contentType: MIMEDocument contentTypeHtml;
		contents: (ReadStream on: '<head><title>Object moved</title></head>
<body><h1>Object Moved</h1>This object may be found <a HREF="', aUrl asString,'">here</a>.</body>');
		yourself
]

{ #category : #initialization }
HttpResponse class >> initialize [
	"  HttpResponse initialize  "

	self initializeStatusCodes.
]

{ #category : #initialization }
HttpResponse class >> initializeStatusCodes [
	"  HttpResponse initializeStatusCodes  "

	StatusCodes := IdentityDictionary new
		"1xx: Meta status codes"
		at: #continue				put: ('100' -> 'Continue');
		at: #switchingProtocols	put: ('101' -> 'Switching Protocols');
		at: #processing			put: ('102' -> 'Processing'); "WebDav RFC: 2518"
		"2xx: Success status codes"
		at: #ok								put: ('200' -> 'OK');
		at: #created							put: ('201' -> 'Created');
		at: #accepted							put: ('202' -> 'Accepted');
		at: #nonAuthoritativeInformation 	put: ('203' -> 'Non-Authoritative Information');
		at: #noContent						put: ('204' -> 'No Content');
		at: #resetContent	 					put: ('205' -> 'Reset Content');
		at: #partialContent					put: ('206' -> 'Partial Content');
		at: #multiStatus						put: ('207' -> 'Multi-Status'); "WebDav RFC: 2518"
		"3xx: Redirection status codes"
		at: #multipleChoices		put: ('300' -> 'Multiple Choices');
		at: #permMoved			put: ('301' -> 'Moved Permanently'); "kept for compatibility"
		at: #permanentlyMoved	put: ('301' -> 'Moved Permanently');
		at: #found					put: ('302' -> 'Found');
		at: #seeOther				put: ('303' -> 'See Other');								
		at: #notModified			put: ('304' -> 'Not Modified');
		at: #useProxy				put: ('305' -> 'Use Proxy');
		at: #temporaryRedirect	put: ('307' -> 'Temporary Redirect');
		at: #tempMoved			put: ('307' -> 'Temporary Redirect'); "kept for compatibility"
		"4xx: Client-Side Error status code"
		at: #badRequest				put: ('400' -> 'Bad Request');
		at: #unauthorized				put: ('401' -> 'Unauthorized');
		at: #payment					put: ('402' -> 'Payment Required');
		at: #forbidden				put: ('403' -> 'Forbidden');
		at: #notFound					put: ('404' -> 'Not Found');
		at: #notAllowed				put: ('405' -> 'Method Not Allowed');
		at: #notAcceptable			put: ('406' -> 'Not Acceptable');
		at: #proxyAuthRequired		put: ('407' -> 'Proxy Authentication Required');
		at: #requestTimeout			put: ('408' -> 'Request Timeout');
		at: #conflict					put: ('409' -> 'Conflict');
		at: #gone						put: ('410' -> 'Gone');
		at: #lenghtRequired			put: ('411' -> 'Lenght Required');
		at: #preconditionFailed		put: ('412' -> 'Precondition Failed');
		at: #entityTooLarge			put: ('413' -> 'Request Entity Too Large');
		at: #uriTooLong				put: ('414' -> 'Request-URI Too Long');
		at: #unsupportedMediaType	put: ('415' -> 'Unsupported Media Type');
		at: #rangeNotSatisfiable	put: ('416' -> 'Requested Range Not Satisfiable');
		at: #expectationFailed		put: ('417' -> 'Expectation Failed');
		at: #unprocessableEntity	put: ('422' -> 'Unprocessable Entity'); "WebDav RFC: 2518"
		at: #locked					put: ('423' -> 'Locked'); "WebDav RFC: 2518"
		at: #failedDependency		put: ('424' -> 'Failed Dependency'); "WebDav RFC: 2518"
		"5xx: Server-Side Error status codes"
		at: #serverError				put: ('500' -> 'Internal Server Error');
		at: #notImplemented			put: ('501' -> 'Not Implemented');
		at: #badGateway				put: ('502' -> 'Bad Gateway');
		at: #serviceUnavailable		put: ('503' -> 'Service Unavailable');
		at: #gatewayTimeout			put: ('504' -> 'Gateway Timeout');
		at: #versionNotSupported	put: ('505' -> 'HTTP Version Not Supported');
		at: #InsufficientStorage	put: ('507' -> 'Insufficient Storage'); 	"WebDav RFC: 2518"
 		yourself.

	"Initialize an inverse mapping to lookup a symbol based on the numeric code"
	StatusSymbols := Dictionary new.
	StatusCodes associationsDo: 
		[ :assn |
		StatusSymbols at: assn value key asNumber put: assn key].
]

{ #category : #'instance creation' }
HttpResponse class >> new [

	^self basicNew
		status: #ok;
		"fieldAt: 'Cache-Control' put: 'max-age=86400';"
		contentType: MIMEDocument contentTypeHtml;
		contents: (ReadStream on: 'This is a simple HttpResponse');
		yourself
]

{ #category : #'instance creation' }
HttpResponse class >> redirectTo: url [
	"Create a redirection response."

	^(HttpResponse
			status: #seeOther
			contents: 'Temporarily moved to: <A HREF="', url, '">', url, '</A>')
		fieldAt: 'Location' put: url;
		fieldAt: 'URI' put: url; yourself
]

{ #category : #preferences }
HttpResponse class >> responseChunkSize [
	"This is the maximum number of bytes of the content stream that are written 
	to the output stream during each iteration of the writing loop."

	^#'HttpResponse-responseChunkSize' binding ifNil: [131072]
]

{ #category : #preferences }
HttpResponse class >> responseChunkSize: anInteger [

	^#'HttpResponse-responseChunkSize' binding: anInteger
]

{ #category : #'instance creation' }
HttpResponse class >> status: aSymbol contents: aString [

	^self basicNew
		status: aSymbol;
		contentType: MIMEDocument contentTypeHtml;
		contents: (ReadStream on: aString);
		yourself

]

{ #category : #accessing }
HttpResponse class >> statusCodeFor: aSymbol [

	^(StatusCodes at: aSymbol) key
]

{ #category : #accessing }
HttpResponse class >> statusDescriptionFor: aSymbol [

	^(StatusCodes at: aSymbol) value
]

{ #category : #accessing }
HttpResponse class >> statusSymbolFor: aCode [

	^StatusSymbols at: aCode asNumber ifAbsent: [#serverError]

]

{ #category : #'accessing-cookies' }
HttpResponse >> addCookies: newCookies [
	
	self cookies addAll: newCookies.

]

{ #category : #'comanche processing' }
HttpResponse >> asHttpPartialResponseBlock: aBlock [
	^(self as: HttpPartialResponse)
		producerBlock: aBlock;
		yourself
]

{ #category : #'comanche processing' }
HttpResponse >> asHttpResponseTo: aRequest [
	^self
]

{ #category : #accessing }
HttpResponse >> contentLength [

	^contentLength
]

{ #category : #accessing }
HttpResponse >> contentType [

	^contentType
]

{ #category : #accessing }
HttpResponse >> contentType: aMimeType [

	contentType := aMimeType
]

{ #category : #accessing }
HttpResponse >> contents [

	^contents
]

{ #category : #accessing }
HttpResponse >> contents: aStream [

	contents := aStream.
	contentLength := aStream size.
]

{ #category : #'accessing-cookies' }
HttpResponse >> cookies [
^ cookies ifNil:[cookies := OrderedCollection new]
]

{ #category : #defaults }
HttpResponse >> defaultContentType [

	^MIMEDocument contentTypeHtml
]

{ #category : #'initialize-release' }
HttpResponse >> destroy [

	self contents close.

]

{ #category : #accessing }
HttpResponse >> fieldAt: aString [

	^self fields at: aString
]

{ #category : #accessing }
HttpResponse >> fieldAt: aString ifAbsent: absBlock [

	^self fields at: aString ifAbsent: absBlock
]

{ #category : #accessing }
HttpResponse >> fieldAt: aString ifAbsentPut: absBlock [

	^self fields at: aString ifAbsentPut: absBlock
]

{ #category : #accessing }
HttpResponse >> fieldAt: aString put: aValue [

	self fields at: aString put: aValue
]

{ #category : #accessing }
HttpResponse >> fields [

	^fields ifNil: [fields := Dictionary new]
]

{ #category : #authentication }
HttpResponse >> hashPassword: aPassword [
	^HttpRequest hashPassword: aPassword
]

{ #category : #accessing }
HttpResponse >> httpVersion [

	^'HTTP/1.1'
]

{ #category : #accessing }
HttpResponse >> isPersistent [

	^(self fieldAt: 'Connection') = 'Keep-Alive'
]

{ #category : #responding }
HttpResponse >> pvtWriteContentLengthOn: aStream [

	self contentLength ifNotNilDo:
		[ :length |
		aStream
			nextPutAll: 'Content-length: ';
			nextPutAll: length asString;
			nextPutAll: String crlf]
]

{ #category : #responding }
HttpResponse >> pvtWriteContentTypeOn: aStream [
	aStream
		nextPutAll: 'Content-type: ';
		nextPutAll: self contentType;
		nextPutAll: String crlf
]

{ #category : #responding }
HttpResponse >> pvtWriteContentsOn: aStream [
	| chunkSize cnts |
	chunkSize := self responseChunkSize.
	cnts := self contents.

	[cnts atEnd] whileFalse: 
		[aStream nextPutAll: (cnts next: chunkSize); flush]
]

{ #category : #responding }
HttpResponse >> pvtWriteCookiesOn: aStream [ 

	self cookies
		do: [:cookie | aStream nextPutAll: 'Set-Cookie: ';
				 nextPutAll: cookie;
				 nextPutAll: String crlf]
]

{ #category : #responding }
HttpResponse >> pvtWriteFieldsOn: aStream [

	fields isEmptyOrNil ifTrue: [ ^self ].

	fields keysAndValuesDo: [ :k :v |
		aStream
			nextPutAll: k;
			nextPutAll: ': ';
			nextPutAll: v;
			nextPutAll: String crlf
	]
]

{ #category : #responding }
HttpResponse >> pvtWriteStatusOn: aStream [
	aStream
		nextPutAll: self httpVersion;
		nextPut: $ ;
		nextPutAll: self statusCodeAndReason;
		nextPutAll: String crlf
]

{ #category : #accessing }
HttpResponse >> responseChunkSize [

	^self class responseChunkSize
]

{ #category : #authentication }
HttpResponse >> secretWord [
	^HttpRequest secretWord
]

{ #category : #'accessing-cookies' }
HttpResponse >> setCookieName: nameString value: valueString expiresDate: expiresDate expiresTime: expiresTime path: pathString domain: domainString secure: secureBoolean [ 
	"set a cookie in the Response"
	| temp |
	temp := String new writeStream.
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
	self cookies add: temp contents
]

{ #category : #'accessing-cookies' }
HttpResponse >> setCookieName: nameString value: valueString path: pathString [ 
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

{ #category : #authentication }
HttpResponse >> setUsername: aUsername [
	"save the username in a cookie"
	self
		setCookieName: #ComancheUsername
		value: aUsername
		path: '/'.

	self flag: #todo.
	"allow for multiple usernames"
]

{ #category : #authentication }
HttpResponse >> setUsername: aUsername password: aPassword [
	"save the username/password in cookies"
	| pwHash |
	self setUsername: aUsername.
	pwHash := self hashPassword: aPassword.
	self
		setCookieName: #ComanchePassword
		value: pwHash asString
		path: '/'.

	self flag: #todo.
	"allow for multiple usernames"
]

{ #category : #accessing }
HttpResponse >> status [

	^status
]

{ #category : #accessing }
HttpResponse >> status: aSymbol [

	status := aSymbol
]

{ #category : #accessing }
HttpResponse >> statusCode [

	^(StatusCodes at: self status) key.

]

{ #category : #accessing }
HttpResponse >> statusCodeAndReason [
	| tmp |

	tmp := StatusCodes at: self status.
	^tmp key, ' ', tmp value.
]

{ #category : #responding }
HttpResponse >> writeHeadersOn: aStream [

	| tmp |
	"Header"

	tmp := WriteStream on: ''.
	self pvtWriteStatusOn: tmp.
	self pvtWriteFieldsOn: tmp.
	self pvtWriteCookiesOn: tmp.
	self pvtWriteContentTypeOn: tmp.
	self pvtWriteContentLengthOn: tmp.
	tmp nextPutAll: String crlf.
	aStream nextPutAll: tmp contents; flush.


]

{ #category : #responding }
HttpResponse >> writeOn: aStream [
	self writeHeadersOn: aStream.
	self pvtWriteContentsOn: aStream.

]
