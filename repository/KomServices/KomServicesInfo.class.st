"
KomServices provides a framework for the creation and management of background processes.  A generic Service class is provided for this purpose.  Additionally, TcpService is provided for creating services that response to inbound TCP connections.

===== Release History =====

Version 1.0:
	- build #59 adds support for the new Squeak 3.6 networking changes
	- initial version, this package is bourne out of KomHttpServer and renames a few classes:
		- ComancheService -> Service
		- ComancheNetService -> TcpService
	- the old ConnectionHandler is dropped in favor of a cleaner TcpListener.
"
Class {
	#name : #KomServicesInfo,
	#superclass : #KomPackageInfo,
	#category : #KomServices
}

{ #category : #'as yet unclassified' }
KomServicesInfo >> optionalPackages [

^#(
('KomSBServices' 'sqpkg://SBServices.kom:1.0'
'SBKomServices provides a nice user interface for managins services
using the StarBrowser.  The StarBrowser will be installed in your image
if it is not already.  Would you like to load this package now?')
)

]

{ #category : #'as yet unclassified' }
KomServicesInfo >> preambleText [
	"Add Socket>>waitForAcceptFor:ifTimedOut: if it does not already exist (this is for
	compatibility with Squeak versions prior to 3.6)."

	^'"' , self packageName , '"', String cr, 
'(Socket methodDictionary includesKey: #waitForAcceptFor:ifTimedOut:) ifFalse:
	[Socket compile: 
''waitForAcceptFor: timeout ifTimedOut: timedOutBlock
	"Wait and accept an incoming connection"
	| deadline |
	deadline := Socket deadlineSecs: timeout.
	self waitForConnectionUntil: deadline.
	^self isConnected
		ifTrue:[self accept]
		ifFalse:[timedOutBlock value]''
		classified: ''waiting''
		withStamp: ''svp 08/20/2003 01:00''
		notifying: nil]'
]

{ #category : #'as yet unclassified' }
KomServicesInfo >> prerequisites [

	^#(
		('DynamicBindings' 'sqpkg://DynamicBindings.svp:1.1')
		('NamedProcess' 'sqmap://Named Process:1.2')
	)

]

{ #category : #'as yet unclassified' }
KomServicesInfo >> releaseName [

	^'1.0'
]
