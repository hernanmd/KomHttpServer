"
This module provides automatically generated listings of directory contents.

Required Bindings:

	HttpRequest current
	ModDir serverDirectory

Exported Bindings:

	<none>

The following is an example:

	| ma |
	ma := ModuleAssembly core.
	ma documentRoot: FileSystem disk workingDirectory fullName.
	ma directoryIndex: 'index.html index.htm'.
	ma serveFiles.
	(HttpService startOn: 8080 named: 'Example') 
		plug: ma rootModule

This example just starts a file server on your default directory.  Any directories (that don't have an index file) will be rendered as listings by ModAutoIndex.
"
Class {
	#name : #ModAutoIndex,
	#superclass : #ComancheModule,
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ModAutoIndex class >> splitPath: fullName to: pathAndNameBlock [
	"Take the file name and convert it to the path name of a directory and a local file name within that directory. FileName must be of the form: <dirPath><delimiter><localName>, where <dirPath><delimiter> is optional. The <dirPath> part may contain delimiters."

	| delimiter i dirName localName tmpName |
	fullName last = $/
		ifTrue: [tmpName := fullName copyFrom: 1 to: fullName size - 1]
		ifFalse: [tmpName := fullName].
	delimiter := $/.
	(i := tmpName findLast: [:c | c = delimiter]) = 0
		ifTrue:
			[dirName := String new.
			localName := tmpName]
		ifFalse:
			[dirName := tmpName copyFrom: 1 to: (i - 1 max: 1).
			localName := tmpName copyFrom: i + 1 to: tmpName size].

	^ pathAndNameBlock value: dirName value: localName
]

{ #category : #'directory listing' }
ModAutoIndex >> dirEntries: entries request: request on: strm padNamesTo: namePad padSizesTo: sizePad [

	request url ~= '/' ifTrue: [self parentEntry: request on: strm].
	entries do: 
		[ :entry |
		self entry: entry on: strm padNamesTo: namePad padSizesTo: sizePad].
]

{ #category : #'directory listing' }
ModAutoIndex >> directoryListing: request directory: dir [

	| entries namePad sizePad |
	entries := dir entries.
	(request fields includesKey: 'S') ifTrue: 
		[entries := entries sortBy: [ :a :b | a fileSize <= b fileSize ]].
	(request fields includesKey: 'M') ifTrue: 
		[entries := entries sortBy: [ :a :b | a modificationTime <= b modificationTime ]].
	(request fields includesKey: 'N') ifTrue: 
		[entries := entries sortBy: [ :a :b | a name <= b name ]].

	namePad := (entries inject: 16 into: [ :max :ea | ea name size max: max ]) + 1.
	sizePad := (entries inject: 4 into: [ :max :ea | ea size printString size max: max ]) + 1.

	^String streamContents: [ :strm |
		strm nextPutAll: '<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">'.
		strm nextPutAll: '<html><head><title>Index of '.
		strm nextPutAll: request url.
		strm nextPutAll: '</title></head><body><h1>Index of '.
		strm nextPutAll: request url.
		strm nextPutAll: '</h1><pre>      <a HREF="?N=A">Name</a>'.
		strm nextPutAll: ((String new: (namePad - 4)) atAllPut: $ ; yourself).
		strm nextPutAll: '<a HREF="?M=A">Last modified</a>    '.
		strm nextPutAll: ((String new: (sizePad - 4)) atAllPut: $ ; yourself).
		strm nextPutAll: '<a HREF="?S=A">Size</a><hr><br>'.
		self 
			dirEntries: entries 
			request: request 
			on: strm 
			padNamesTo: namePad 
			padSizesTo: sizePad.
		strm nextPutAll: '</pre><hr><address>'.
		strm nextPutAll: HttpService current serverDescription.
		strm nextPutAll: '</address></body></html>'].
]

{ #category : #'directory listing' }
ModAutoIndex >> entry: entry on: strm padNamesTo: namePad padSizesTo: sizePad [

	| sizeString |
	sizeString := entry size printString.
	entry isDirectory 
		ifTrue: [strm nextPutAll: '[DIR]']
		ifFalse: [strm nextPutAll: '     '].
	strm nextPutAll: ' <a HREF="'.
	strm nextPutAll: entry name.
	entry isDirectory ifTrue: [strm nextPut: $/].
	strm nextPutAll: '">'.
	strm nextPutAll: entry name.
	strm nextPutAll: '</a>'.
	strm nextPutAll: ((String new: (namePad - entry name size)) atAllPut: $ ; yourself).
	(Date fromSeconds: (entry modificationTime asSeconds)) printOn: strm format: #(1 2 3 $- 2 1 2).
	strm nextPut: $ .
	(Time fromSeconds: entry modificationTime seconds) print24: true showSeconds: false on: strm.
	strm nextPutAll: ((String new: (sizePad - sizeString size)) atAllPut: $ ; yourself).
	strm nextPutAll: sizeString.
	strm nextPutAll: String crlf.

]

{ #category : #'directory listing' }
ModAutoIndex >> parentEntry: request on: strm [

	| tmp parentPath |
	tmp := request url copyFrom: 1 to: (request url size - 1).
	parentPath := self class splitPath: tmp to: [ :path :nm | path].
	parentPath last = $/ ifFalse: [parentPath := parentPath, '/'].

	strm nextPutAll: '[DIR] <a HREF="'.
	strm nextPutAll: parentPath.
	strm nextPutAll: '">Parent Directory</a>'.
	strm nextPutAll: '<br>'.

]

{ #category : #processing }
ModAutoIndex >> processHttp [
	| dir request |
	request := HttpRequest current.
	(#(#GET #POST) includes: request method) ifFalse: [^false].
	dir := ModDir serverDirectory.
	HttpResponse current: (HttpResponse 
				fromString: (self directoryListing: request directory: dir)).
	^true
]

{ #category : #validation }
ModAutoIndex >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :ea | ea isDir ] 
		ifNone: [problems add: 'AutoIndex module requires Dir module']
]
