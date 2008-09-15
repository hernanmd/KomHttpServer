"
I am a simple module that if reached will generate a not found response.  This is useful if you do not wish to continue processing modules add some point in your module assembly.

The following is a simple example using the #notFound message of ModuleAssembly:

	| ma |
	ma := ModuleAssembly core.
	ma alias: '/one' to: 
		[ma documentRoot: (FileDirectory default directoryNamed: 'one').
		ma directoryIndex: 'index.html index.htm'.
		ma serveFiles.
		ma notFound].
	ma addPlug: 
		[:request | HttpResponse fromString: 
			('<a href=""one"">go to one</a> If the path begins with',
			' ""/one"" we should never end up here')].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.

By contrast, the following example will end up in our default response if no matching file is found.

	| ma |
	ma := ModuleAssembly core.
	ma alias: '/one' to: 
		[ma documentRoot: (FileDirectory default directoryNamed: 'one').
		ma directoryIndex: 'index.html index.htm'.
		ma serveFiles].
	ma addPlug: 
		[:request | HttpResponse fromString: '<a href=""one"">go to one</a>'].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.

"
Class {
	#name : #ModNotFound,
	#superclass : #ComancheModule,
	#category : 'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ModNotFound >> processHttp [

	HttpResponse current: 
		(HttpAdaptor current notFoundResponseFor: HttpRequest current).
	^true
]
