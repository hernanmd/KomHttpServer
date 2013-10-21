"
The core module for handling traditional web server duties

Required Bindings: 

	ModCore path

Exported Bindings:

	ModDoc documentRoot
	ModDoc relativeFilePath

The following is an example:

	| ma |
	ma := ModuleAssembly core.
	ma documentRoot: FileDirectory default fullName.
	ma directoryIndex: 'index.html index.htm'.
	ma serveFiles.
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule

This example just starts a file server on your default directory.  Any directories (that don't have an index file) will be rendered as listings by ModAutoIndex.

"
Class {
	#name : #ModDoc,
	#superclass : #ComancheModule,
	#instVars : [
		'documentRoot'
	],
	#classVars : [
		'DelimiterTranslation'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #bindings }
ModDoc class >> documentRoot [
	"<FileDirectory> The root of the document tree for the current request"

	^#'ModCore-DocumentRoot' binding
]

{ #category : #bindings }
ModDoc class >> documentRoot: aFileDirectory [

	#'ModCore-DocumentRoot' binding: aFileDirectory
]

{ #category : #bindings }
ModDoc class >> fullFilePath [
	"<String> The full path name to the file or directory on the server
	indicated by the current HttpRequest."

	"Ordinarily, just use the following:"
	(Smalltalk os platformName ~= 'Mac OS')
		ifTrue: [^self documentRoot fullNameFor: self relativeFilePath].

	"But! Because of Mac idiosyncracies, we must do:"
	^((self relativeFilePath findTokens: FileDirectory pathNameDelimiter asString)
		inject: self documentRoot into: 
			[ :dir :pathPart |
			FileDirectory on: (dir fullNameFor: pathPart)]) fullName
			
]

{ #category : #initialization }
ModDoc class >> initialize [
	"self initialize"

	DelimiterTranslation := (0 to: 255) as: ByteArray.
	DelimiterTranslation 
		at: ($/ asciiValue + 1) 
		put: FileSystem disk separator asciiValue.

	"Register this class for startUp notification (in case we are started on a
	platform with a differen path name delimiter"
	Smalltalk addToStartUpList: self.

]

{ #category : #bindings }
ModDoc class >> relativeFilePath [
	"<String> The relative path name to the file or directory on the server
	indicated by the current HttpRequest"

	^#'ModCore-RelativeFilePath' binding 
]

{ #category : #bindings }
ModDoc class >> relativeFilePath: aPathName [

	^#'ModCore-RelativeFilePath' binding: aPathName
]

{ #category : #initialization }
ModDoc class >> startUp [
	"When we start up, force the rebuilding of the DelimiterTranslation
	array (in case we are started on a platform with a different delimiter)."

	self initialize
]

{ #category : #accessing }
ModDoc >> documentRoot [

	^documentRoot
]

{ #category : #accessing }
ModDoc >> documentRoot: aDirectoryOrString [ 
	documentRoot := aDirectoryOrString isString 
		ifTrue: [FileDirectory on: aDirectoryOrString]
		ifFalse: [aDirectoryOrString]
]

{ #category : #testing }
ModDoc >> isDoc [

	^true
]

{ #category : #'error handling' }
ModDoc >> notFoundResponseFor: request [

	^self
		errorResponseStatus: #notFound
		description: ('The requested URL ', request url, ' was not found on this server').

]

{ #category : #printing }
ModDoc >> printOn: strm [

	super printOn: strm.
	strm nextPut: $(.
	self documentRoot pathName printOn: strm.
	strm nextPut: $).
]

{ #category : #accessing }
ModDoc >> processHttp [
	"Examine the path from ModCore and set the bindings for
	document root and relative file path"

	| relativeFilePath path |
	path := ModCore path.
	relativeFilePath := self relativeFilePathFrom: path.
	self class
		documentRoot: self documentRoot;
		relativeFilePath: relativeFilePath.
	^ self processSubModules.
]

{ #category : #accessing }
ModDoc >> relativeFilePathFrom: path [ 
	^((path notEmpty and: [path first = $/]) 
		ifTrue: [path copyFrom: 2 to: path size]
		ifFalse: ['']) translateWith: DelimiterTranslation
]

{ #category : #validation }
ModDoc >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :module | module isCore ]
		ifNone: [problems add: 'Doc module requires a Core module']
]
