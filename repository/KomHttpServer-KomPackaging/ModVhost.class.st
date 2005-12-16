"
This module exports a string that is created based on a template.  Other modules may access and use the resulting string as they see fit (using ""ModVhost string"").  ModVhostDoc uses the ModVhost string to establish a document root based on the virtual host name.  ModVhostAlias uses the ModVhost string to look for a match when deciding whether or not to process its subModules.  See the examples below for more details.

The format of the template string is designed to be compatible with Apache's virtual hosting support.  The following is adapted from the Apache documentation:

-----
%% inserts a percent
%p inserts the socket port number (as it is known to the client)
%N.M inserts parts of the fully qualified domain name (FQDN, as it is know to the client)

N and M are used to specify substrings of the FQDN. N selects from the dot-separated components of the FQDN, and M selects characters within whatever N has selected. M is optional and defaults to zero if it isn't present; the dot must be present if and only if M  is present. The interpretation is as follows:

0 	the whole name
1 	the first part
2 	the second part
-1 	the last part
-2 	the penultimate part
2+ 	the second and all subsequent parts
-2+ 	the penultimate and all preceding parts
1+ and -1+ 	the same as 0

If N or M is greater than the number of parts available a single underscore is interpolated.
-----

The following is an example configuration for mass virtual hosting of file based content (it uses ModVhostDoc to interpret the host string produced by ModVhost):

	| ma |
	ma _ ModuleAssembly core.
	ma virtualDocumentRoot: (FileDirectory default fullNameFor: '%0') do:
		[ma directoryIndex: 'index.html index.htm'.
		ma serveFiles].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.

In this example, the document root for the web server will be determined using the entire FQDN as the final element in the document root.

Of course, virtual hosting does not need to be restricted to file serving.  Similar to ModAlias, you can use the virtual host name to control which modules get processed.  The following is another example (it uses makes use of ModVhostAlias):

	| ma |
	ma _ ModuleAssembly core.
	ma virtualHost: 'localhost' do:
		[ma addPlug: 
			[ :request |
			HttpResponse fromString: 'You are seeing content for localhost']].
	ma addPlug:
		[ :request |
		HttpResponse fromString: 'You are seeing default content'].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.

In this example, you will see different content depending on whether you access the server using http://localhost:8080 or http://127.0.0.1:8080.  Another example might be hosting Seaside (see http://www.beta4.com/seaside2 for information) applications on a separate host name.

"
Class {
	#name : #ModVhost,
	#superclass : #ComancheModule,
	#instVars : [
		'template'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'instance creation' }
ModVhost class >> pathTemplate: aString [

	^self new 
		pathTemplate: aString; 
		yourself
]

{ #category : #bindings }
ModVhost class >> string [

	^#'ModVhost-String' binding
]

{ #category : #bindings }
ModVhost class >> string: aString [

	#'ModVhost-String' binding: aString
]

{ #category : #'as yet unclassified' }
ModVhost >> getOffsetAt: pos [

	| temp end val |
	temp _ self template.
	end _ pos.
	(temp at: end) == $- ifTrue: [end _ end + 1].
	[val _ temp at: end.
	((val >= $0) and: [val <= $9] and: [temp size > end])] whileTrue: [end _ end + 1].
	((val >= $0) and: [val <= $9]) ifTrue: [end _ end + 1].
	((end <= temp size) and: [(temp at: end) = $+])
		ifTrue: [^temp copyFrom: pos to: end]
		ifFalse: [^temp copyFrom: pos to: (end - 1)]

]

{ #category : #'as yet unclassified' }
ModVhost >> getSubstituteAt: percentPosition host: aHost andDo: aBlock [

	| temp nameIndex nextPos letterIndex sub |
	temp _ self template.

	temp size <= percentPosition ifTrue: 
		[aBlock value: '%'. 
		^percentPosition + 1].

	(temp at: (percentPosition + 1)) = $% ifTrue: 
		[aBlock value: '%'. 
		^percentPosition + 2].

	(temp at: (percentPosition + 1)) = $p ifTrue: 
		[aBlock value: aHost port asString. 
		^percentPosition + 2].

	nameIndex _ self getOffsetAt: (percentPosition + 1).
	nextPos _ percentPosition + 1 + nameIndex size.

	((temp size >= nextPos) and: [(temp at: nextPos) = $.])
		ifTrue: 
			[letterIndex _ self getOffsetAt: (nextPos + 1).
			nextPos _ nextPos + letterIndex size + 1]
		ifFalse: 
			[letterIndex _ '0'].

	[sub _ aHost vhostName: nameIndex letter: letterIndex]
		on: Error do: [ :ex | aBlock value: '%'. ^percentPosition + 1].

	aBlock value: sub.
	^nextPos

]

{ #category : #testing }
ModVhost >> isVhost [

	^true
]

{ #category : #'as yet unclassified' }
ModVhost >> processHttp [

	ModVhost string: (self stringFromHost: ModCore host).
	^self processSubModules

]

{ #category : #'as yet unclassified' }
ModVhost >> stringFromHost: aHost [

	| pos temp done nextPercent |
	pos _ 1.
	temp _ self template.
	done _ false.

	^String streamContents: [ :strm |
		[done] whileFalse: 
			[nextPercent _ temp indexOf: $% startingAt: pos.
			nextPercent = 0 
				ifTrue:
					[strm nextPutAll: (temp copyFrom: pos to: temp size).
					done _ true.]
				ifFalse: 
					[strm nextPutAll: (temp copyFrom: pos to: (nextPercent - 1)).
					pos _ self 
						getSubstituteAt: nextPercent 
						host: aHost
						andDo: [ :sub | strm nextPutAll: sub ].
					pos > temp size ifTrue: [done _ true]]]].
]

{ #category : #'as yet unclassified' }
ModVhost >> template [

	^template ifNil: [template _ '%0']
]

{ #category : #'as yet unclassified' }
ModVhost >> template: aString [

	template _ aString
]

{ #category : #validation }
ModVhost >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :module | module isCore ]
		ifNone: [problems add: 'Vhost module requires a Core module']
]
