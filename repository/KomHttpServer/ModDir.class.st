"
This module provides basic directory handling (including redirects to handle the trailing slash problem).

Required Bindings:

	HttpRequest current
	ModDoc fullFilePath

Exported Bindings:

	ModDir serverDirectory

The following is an example:

	| ma |
	ma := ModuleAssembly core.
	ma documentRoot: FileSystem disk workingDirectory fullName.
	ma directoryIndex: 'index.html index.htm'.
	ma serveFiles.
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule

This example just starts a file server on your default directory.  Any directories (that don't have an index file) will be rendered as listings by ModAutoIndex.
"
Class {
	#name : #ModDir,
	#superclass : #ComancheModule,
	#instVars : [
		'directoryIndex'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #tests }
ModDir class >> directoryExists: fileReference [

	^ fileReference exists and: [ fileReference isDirectory ]

	
]

{ #category : #accessing }
ModDir class >> fullFilePath [
	^ModDoc fullFilePath
]

{ #category : #bindings }
ModDir class >> serverDirectory [

	^#'ModDir-ServerDirectory' binding
]

{ #category : #bindings }
ModDir class >> serverDirectory: aFileDirectory [

	#'ModDir-ServerDirectory' binding: aFileDirectory
]

{ #category : #processing }
ModDir >> directoryIndex [

	^directoryIndex ifNil: [directoryIndex := OrderedCollection new]
]

{ #category : #processing }
ModDir >> directoryIndex: aCollectionOrString [ 
	directoryIndex := aCollectionOrString isString 
		ifTrue: [aCollectionOrString findTokens: ' ']
		ifFalse: [aCollectionOrString]
]

{ #category : #processing }
ModDir >> directoryIndexExists: dir [ 
	| fname |
	
	fname := self directoryIndex 
					detect: [ : ea | (dir asFileReference / ea) exists ]
					ifNone: [ ^ false ].
	"Our directory exists, set the full file name so that
	ModFile will detect and serve the index file (note, if no ModFile
	gets processed after this module, then a doc not found will be returned)"
	
	ModDoc relativeFilePath: ModDoc relativeFilePath , fname.
	^ true
]

{ #category : #testing }
ModDir >> isDir [

	^true
]

{ #category : #processing }
ModDir >> processHttp [
	| filePath dir request |
	
	request := HttpRequest current.
	filePath := self class fullFilePath.
	(self class directoryExists: (dir := filePath asFileReference)) 
		ifFalse: [ ^ false ].
	"If the url does not end in a slash, then redirect to add the slash"
	request url last ~= $/ 
		ifTrue: [ self redirectWithTrailingSlash: request.
			^ true].
	(self directoryIndexExists: dir) ifTrue: [ ^ false ].
	self class serverDirectory: dir.
	^ self processSubModules 
]

{ #category : #processing }
ModDir >> redirectWithTrailingSlash: request [

	| location |
	location := request url, '/'.
	HttpResponse current: 
		((HttpResponse
			status: #tempMoved
			contents: 'Temporarily moved to: <A HREF="', location, '">', location, '</A>')
		fieldAt: 'Location' put: location;
		fieldAt: 'URI' put: location;
		yourself)
]

{ #category : #validation }
ModDir >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :ea | ea isDoc ] 
		ifNone: [problems add: 'Dir module requires a Doc module']
]
