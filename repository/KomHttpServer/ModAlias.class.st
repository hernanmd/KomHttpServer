"
This module will attempt to match a prefix to the URL of a request.  If a match is made, its subModules will be processed.  If not, then its subModules are not processed.  The following is an example:

	| ma |
	ma := ModuleAssembly core.
	ma alias: '/hello' to: [ ma addPlug: [ :request |
			HttpResponse fromString: 'This is the aliased content' ] ].
	ma addPlug: [ : request | HttpResponse fromString: 'This is the default content'].
	(HttpService startOn: 8080 named: 'Example') plug: ma rootModule

In this example, the urls http://localhost:8080/hello and http://localhost:8080/hello/some/more/path will show the aliased content while any url where the path does not begin with '/hello' will show the default content.
"
Class {
	#name : #ModAlias,
	#superclass : #ComancheModule,
	#instVars : [
		'pathPrefix'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #accessing }
ModAlias >> pathPrefix [

	^pathPrefix
]

{ #category : #accessing }
ModAlias >> pathPrefix: aString [

	pathPrefix := aString
]

{ #category : #processing }
ModAlias >> processHttp [

	| path |
	path := ModCore path.
	"check if our prefix matches"
	((path beginsWith: pathPrefix) and: 
	[path size = pathPrefix size or: [(path at: (pathPrefix size + 1)) = $/]])
		ifTrue: 
			[ModCore path: (path copyFrom: pathPrefix size + 1 to: path size).
			self processSubModules ifTrue: 
				[ModCore path: path.
				^true]].

	"otherwise, reset the path to it's original setting and indicate 
	to the caller that we have no response and ."
	ModCore path: path.
	^false
]
