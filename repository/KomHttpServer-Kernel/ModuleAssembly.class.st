"
I am a module assembly.  I provide a convienient mechanism for assembling modules into a module hierarchy for use by an HttpService.  The following is a very simple example of how to use a ModuleAssembly:

	| ma |
	ma _ ModuleAssembly core.
	ma addPlug:
		[ :request |
		HttpResponse fromString: 'Hello World!!!'].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.
"
Class {
	#name : #ModuleAssembly,
	#superclass : #Object,
	#instVars : [
		'moduleStack'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ModuleAssembly class >> core [

	^super new 
		initialize;
		basicPushModule: ModCore new;
		yourself
]

{ #category : #'as yet unclassified' }
ModuleAssembly class >> new [

	^super new 
		initialize;
		basicPushModule: ModMulti new;
		yourself
]

{ #category : #construction }
ModuleAssembly >> addAssembly: aModuleAssembly [

	self addModule: aModuleAssembly rootModule
]

{ #category : #construction }
ModuleAssembly >> addModule: aComancheModule [

	aComancheModule validateForStack: self moduleStack.
	self currentModule addSubModule: aComancheModule
]

{ #category : #construction }
ModuleAssembly >> addPlug: aBlockOrMessageSend [
	"Blocks and MessageSends are compatible with the ComancheModule
	protocol, so just add it as a module"

	self addModule: aBlockOrMessageSend
]

{ #category : #construction }
ModuleAssembly >> alias: pathPrefix to: aBlock [

	self 
		pushModule: (ModAlias new pathPrefix: pathPrefix; yourself)
		andDo: aBlock


]

{ #category : #construction }
ModuleAssembly >> authenticate: anAuthDb realm: realmString [ 
	self addModule: ((ModAuth new)
				authDb: anAuthDb;
				realm: realmString; yourself)
]

{ #category : #construction }
ModuleAssembly >> basicPushModule: aModule [

	^self moduleStack addLast: aModule.

]

{ #category : #construction }
ModuleAssembly >> currentModule [

	^self moduleStack last
]

{ #category : #construction }
ModuleAssembly >> directoryIndex: indexFileString [

	self 
		pushModule: (ModDir new directoryIndex: indexFileString; yourself)
		andDo: [self addModule: ModAutoIndex new].

]

{ #category : #construction }
ModuleAssembly >> documentRoot: docRoot [

	self pushModule: (ModDoc new documentRoot: docRoot; yourself).

]

{ #category : #construction }
ModuleAssembly >> documentRoot: docRoot do: aBlock [

	self 
		pushModule: (ModDoc new documentRoot: docRoot; yourself)
		andDo: aBlock

]

{ #category : #construction }
ModuleAssembly >> initialize [
	super initialize.
	
	moduleStack := OrderedCollection new
]

{ #category : #'error handling' }
ModuleAssembly >> invalidContext: message [

	^self error: ('Invalid Context: ', message)
]

{ #category : #construction }
ModuleAssembly >> logTo: aLogger [

	self addModule: (ModLog new logger: aLogger; yourself)
]

{ #category : #private }
ModuleAssembly >> lookupMod: testBlock ifFound: foundBlock ifNotFound: notFoundBlock [

	| thisMod |
	moduleStack size to: 1 by: -1 do: 
		[ :i |
		thisMod _ moduleStack at: i.
		(testBlock value: thisMod)
			ifTrue: [^foundBlock value: thisMod]].
	^notFoundBlock value
]

{ #category : #construction }
ModuleAssembly >> moduleStack [

	^moduleStack
]

{ #category : #construction }
ModuleAssembly >> notFound [

	self addModule: (ModNotFound new)
]

{ #category : #construction }
ModuleAssembly >> popModule [

	self moduleStack removeLast

]

{ #category : #construction }
ModuleAssembly >> pushModule: aModule [

	self addModule: aModule.
	^self basicPushModule: aModule.

]

{ #category : #construction }
ModuleAssembly >> pushModule: aModule andDo: aBlock [
	"Push aModule on our stack and evaluate aBlock, note, this directive 
	protects against an unbalanced stack because certain directives just
	push a new module on the stack without popping it"

	| stackSize |
	stackSize _ moduleStack size.
	self pushModule: aModule.
	aBlock value.
	moduleStack _ moduleStack copyFrom: 1 to: stackSize.


]

{ #category : #construction }
ModuleAssembly >> rootModule [

	^self moduleStack first
]

{ #category : #construction }
ModuleAssembly >> serveFiles [

	self addModule: ModFile new

]

{ #category : #construction }
ModuleAssembly >> serverRoot: aDirectoryPath [

	self lookupMod: [ :mod | mod isCore ]
		ifFound: [ :mod | mod serverRoot: aDirectoryPath ]
		ifNotFound: [ self invalidContext: 'serverRoot directive requires ModCore' ]

]

{ #category : #construction }
ModuleAssembly >> sessionTimeout: minutes [

	self lookupMod: [ :ea | ea isSession ]
		ifFound: [ :module | module secondsToLive: (minutes * 60)]
		ifNotFound: [ self invalidContext: 'sessionTimeout directive requires ModSession']
]

{ #category : #construction }
ModuleAssembly >> sessionTimeoutSeconds: seconds [

	self lookupMod: [ :ea | ea isSession ]
		ifFound: [ :module | module secondsToLive: seconds]
		ifNotFound: [ self invalidContext: 'sessionTimeout directive requires ModSession']
]

{ #category : #construction }
ModuleAssembly >> trackSessions [

	self pushModule: ModSession new
]

{ #category : #construction }
ModuleAssembly >> trackSessions: aBlock [

	self pushModule: ModSession new andDo: aBlock
]

{ #category : #construction }
ModuleAssembly >> virtualDocumentRoot: aTemplateString do: aBlock [

	self pushModule: (ModVhost new template: aTemplateString; yourself) andDo:
		[self pushModule: (ModVhostDoc new documentRoot: ''; yourself) andDo: aBlock]

]

{ #category : #construction }
ModuleAssembly >> virtualHost: hostString do: aBlock [

	self pushModule: (ModVhost new template: '%0'; yourself) andDo:
		[self pushModule: (ModVhostAlias new host: hostString; yourself) andDo: aBlock]

]
