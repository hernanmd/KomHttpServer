"
This module serves a file based on the setting of ModCore fullFilePath.

Required Bindings:

	ModDoc documentRoot
	ModDoc relativeFilePath

Exported Bindings:

	<none>

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
	#name : #ModFile,
	#superclass : #ComancheModule,
	#category : #'KomHttpServer-Modules'
}

{ #category : #processing }
ModFile >> processHttp [
	"This method uses StandardFileStream explicitly instead
	of relying on FileStream class>>concreteStream, since in this
	case we just need to return the file 'as is' binary."

	| fullFileRef method |

	method := ModCore method.
	(#(#GET #POST) includes: method) ifFalse: [^false].
	(fullFileRef := ModDoc fullFilePath asFileReference) exists ifFalse: [ ^ false ].
	self processSubModules ifTrue: [^true].
	HttpResponse current: (HttpResponse fromStream: fullFileRef readStream).
	^ true
]

{ #category : #validation }
ModFile >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :ea | ea isDoc ] 
		ifNone: [problems add: 'File module requires a Doc module']
]
