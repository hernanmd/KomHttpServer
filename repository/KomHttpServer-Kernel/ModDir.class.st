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
	ma documentRoot: FileDirectory default fullName.
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
ModDir class >> directoryExists: aFileDirectory [
	"The Mac implementation of FileDirectory>>exists answers true,
	even when the path specified is a file (not a directory) (as of
	22 May 2003)...this differs from the Unix and Windows VMs...so 
	this is a little hack that should work on all platforms...when the
	Mac VM is correct, we should change this code to simply use
	FileDirectory>>exists"

	"Ordinarily, just do:"
	SmalltalkImage current platformName ~= 'Mac OS' ifTrue: [^aFileDirectory exists].

	"But! Because of Mac idiosyncracies, do:"
	^aFileDirectory exists and: 
		[aFileDirectory containingDirectory directoryNames 
			includes: aFileDirectory localName].

	
]

{ #category : #bindings }
ModDir class >> serverDirectory [

	^#'ModDir-ServerDirectory' binding
]

{ #category : #bindings }
ModDir class >> serverDirectory: aFileDirectory [

	#'ModDir-ServerDirectory' binding: aFileDirectory
]

{ #category : #'as yet unclassified' }
ModDir >> directoryIndex [

	^directoryIndex ifNil: [directoryIndex _ OrderedCollection new]
]

{ #category : #'as yet unclassified' }
ModDir >> directoryIndex: aCollectionOrString [ 
	directoryIndex := aCollectionOrString isString 
		ifTrue: [aCollectionOrString findTokens: ' ']
		ifFalse: [aCollectionOrString]
]

{ #category : #'as yet unclassified' }
ModDir >> directoryIndexExists: dir [ 
	| fname |
	
	fname := self directoryIndex detect: [:ea | dir fileExists: ea]
				ifNone: [^false].

	"Our directory exists, set the full file name so that
	ModFile will detect and serve the index file (note, if no ModFile
	gets processed after this module, then a doc not found will be returned)"
	
	ModDoc relativeFilePath: ModDoc relativeFilePath , fname.
	^true
]

{ #category : #testing }
ModDir >> isDir [

	^true
]

{ #category : #'as yet unclassified' }
ModDir >> processHttp [
	| filePath dir request |
	request := HttpRequest current.
	filePath := self class fullFilePath.
	(self class directoryExists: (dir := FileDirectory on: filePath)) 
		ifFalse: [^false].

	"If the url does not end in a slash, then redirect to add the slash"
	request url last ~= $/ 
		ifTrue: 
			[self redirectWithTrailingSlash: request.
			^true].
	(self directoryIndexExists: dir) ifTrue: [^false].
	self class serverDirectory: dir.
	^ self processSubModules 
]

{ #category : #'as yet unclassified' }
ModDir >> redirectWithTrailingSlash: request [

	| location |
	location _ request url, '/'.
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
