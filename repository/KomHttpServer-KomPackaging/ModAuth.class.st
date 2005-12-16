"
This module, when present, requires that a request has user authentication info.  It does not authenticate the supplied user id and password.  I send the message #verifyPassword:forUser: to my authDb instance variable to validate user ids and passwords.  You may supply your own user management object.  A very simple authentication database is provided by the KomAuthDb class.  Currently, this module only supports Basic authentication.

Here is an example of a simple configuration that authentications users:

	| ma authdb |
	authdb := KomAuthDb new.
	authdb addUser: 'admin' withPassword: 'password'.
	ma := ModuleAssembly core.
	ma authenticate: authdb realm: 'Demo'.
	ma addPlug:
		[ :request |
		HttpResponse fromString: 'Hello world!'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule. 

Future enhancement ideas:

- add support for more types of authentication
"
Class {
	#name : #ModAuth,
	#superclass : #ComancheModule,
	#instVars : [
		'realm',
		'authDb'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #bindings }
ModAuth class >> user [

	^#'ModAuth-user' binding
]

{ #category : #bindings }
ModAuth class >> user: userName [

	^#'ModAuth-user' binding: userName
]

{ #category : #accessing }
ModAuth >> authDb [

	^authDb
]

{ #category : #accessing }
ModAuth >> authDb: anAuthDb [

	authDb := anAuthDb
]

{ #category : #accessing }
ModAuth >> authorizationResponse [

	| answer |
	answer _ HttpResponse
		status: #unauthorized
		contents: 'Authentication Required'.
	answer fieldAt: 'WWW-Authenticate' put: 'Basic realm="', self realm,'"'.
	^answer
]

{ #category : #processing }
ModAuth >> decodeAuthorization: aString [

	^(Base64MimeConverter mimeDecodeToChars:
		(ReadStream on: (aString findTokens: ' ') last))
			contents
]

{ #category : #processing }
ModAuth >> extractAuthInfo: request andDo: aBlock [ 

	| authHeader user pass |
	(authHeader _ self extractAuthorization: request) ifNil: [^self].
	user _ self extractUser: authHeader.
	pass _ self extractPassword: authHeader.
	(user isNil or: [pass isNil]) ifTrue: [^self].
	^aBlock value: user value: pass


]

{ #category : #processing }
ModAuth >> extractAuthorization: request [

	^(request headerAt: 'Authorization' ifAbsent: [request headerAt: 'authorization' ifAbsent: []])
		ifNotNilDo: [:auth | self decodeAuthorization: auth]
]

{ #category : #processing }
ModAuth >> extractPassword: auth [

	^auth ifNotNil: [auth copyAfter: $:]
]

{ #category : #processing }
ModAuth >> extractUser: auth [

	^auth ifNotNil: [auth copyUpTo: $:]
]

{ #category : #processing }
ModAuth >> processHttp [

	| request |
	request _ HttpRequest current.
	self extractAuthInfo: request andDo: 
		[ :user :password | 
		(self verifyPassword: password forUser: user)
			ifTrue: 
				[ModAuth user: user.
				^self processSubModules]].
	
	HttpResponse current: self authorizationResponse.
	^true
]

{ #category : #accessing }
ModAuth >> realm [

	^realm ifNil: ['/']
]

{ #category : #accessing }
ModAuth >> realm: aString [

	realm _ aString
]

{ #category : #'as yet unclassified' }
ModAuth >> verifyPassword: aPassword forUser: userName [

	^self authDb verifyPassword: aPassword forUser: userName

]
