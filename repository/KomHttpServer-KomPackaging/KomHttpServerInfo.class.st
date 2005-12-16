"
KomHttpServer is the Comanche web server package.  To get a simple web server running, install this package and evaluate the code below.  A simple file serving web server will be started and will serve the files in your default directory.

	| ma |
	ma := ModuleAssembly core.
	ma serverRoot: FileDirectory default fullName.
	ma documentRoot: FileDirectory default fullName.
	ma directoryIndex: 'index.html index.htm'.
	ma serveFiles.
	(HttpService startOn: 8080 named: 'httpd') plug: ma rootModule

After starting the server, point your web browser to http://localhost:8080/

If you have loaded Seaside, you can start a web server that serves Seaside based applications using the following configuration:

	| ma seaside |
	seaside := WAKom default.
	ma := ModuleAssembly core.
	ma serverRoot: FileDirectory default fullName.
	ma alias: '/seaside' to: [ma addPlug: [:request | seaside process: request]].
	ma documentRoot: FileDirectory default fullName.
	ma directoryIndex: 'index.html index.htm'.
	ma serveFiles.
	(HttpService startOn: 8080 named: 'httpd') plug: ma rootModule

See the class comments of the various subclasses of ComancheModule for documentation and usage examples.

===== Release History =====
Version 6.2:
	- Added support for Squeak 3.6
	- Now uses SocketStream from the network rewrite

Version 6.1:
	- (build #41) Fixes various issues for running on Mac OSX
	- Packaged using KomPackaging (Squeak version only)
	- Separated the services framework into a separate package called KomServices
	- Added a module framework
	- The following modules have been added (see the individual classes for details):
		- ModCore - this is the core module and designed to be the root of a module assembly, it extracts basic information from the request and makes it available to sub-modules, it also handles http TRACE and OPTIONS methods
		- ModMulti - this is a module designed only to wrap submodules into a single entity
		- ModAlias - for mapping url prefixes to sub modules
		- ModAuth - for authentication
			- KomAuthDb - a very basic user and password database
		- ModAutoIndex - for generating directory listings
		- ModDir - for directory processing (including redirects to fix the trailing slash problem)
		- ModDoc - for file location processing in a file server
		- ModVhost - for name based virtual hosting
			- ModVhostDoc - for document serving based on virtual host name
			- ModVhostAlias - for module routing based on the virtual host name
		- ModFile - for serving files
		- ModLog - for logging http requests (not yet usable)
			- KomLogger - writes out a log in CLF format
			- KomTracer - writes out a detailed trace of http request/response pairs
		- ModNotFound - if reached will generate a not found response
		- ModSession - for client session handling
			- KomSession - the session class used by ModSession (by default)
	- Added ModuleAssembly to help in creating module assemblies
	- Renamed classes:
		- ComancheHttpService -> HttpService
	- Removed classes
		- BoundedStream
		- HttpBadRequest
		- HttpParser
		- NetworkProtocolAdaptor
		- NetworkRequest

Version 6.0.1:
	- Adds pluggability to ComancheHttpService (see class comments).

Version 6.0:
	- Initial ComancheNG release

===== Future Enhancement Plans =====

- add WebDAV server capability (in a separate package)
- synchronize with the network rewrite project
- separate some of the http protocol support into a separate package and provide an Http/WebDAV client implementation (separate package)
- rework the handling of chunked responses (using the SharedStreams package)
- rework the handling of document uploads (via multipart/form-data) using the SharedStreams package
- support chunked transfer encoding for incoming requests
- Reify cookies and make them easier to work with
- Slim down HttpRequest and HttpResponse such that they are only responsible for constructing requests and responses (currently, these classes are heavily overloaded)
"
Class {
	#name : #KomHttpServerInfo,
	#superclass : #KomPackageInfo,
	#category : #'KomHttpServer-Kernel'
}

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> conditionalChangeSets [

	^#(
		('SystemVersion current highestUpdate > 5180' 'SocketAndSocketStreamFixes.cs')
		('SystemVersion current highestUpdate <= 5180' 'SocketStream.cs')
	)

]

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> maturity [

	^#beta
]

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> optionalPackages [

^#(

('KomSBHttpServer' 'sqpkg://SBHttpServer.kom:1.0'
'SBKomHttpServer provides a nice user interface for managing HTTP services
using the StarBrowser.  The StarBrowser will be installed in your image
if it is not already.  Would you like to load this package now?')

('Seaside' 'sqmap://Seaside:2.3b'
'Seaside is a great framework for building dynamic web based applications.
Would you like to install it now?')

)

]

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> preloadChangeSetNames [

	^#('KomHttpServer-preload.cs')

]

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> prerequisites [

	^#(
		('KomServices' 'sqpkg://services.kom:1.0')
	)

]

{ #category : #'as yet unclassified' }
KomHttpServerInfo >> releaseName [

	^HttpService version
]
