"
See the class comments for ModVhost for using Comanche's virtual hosting features.
"
Class {
	#name : #ModVhostAlias,
	#superclass : #ComancheModule,
	#instVars : [
		'host'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #accessing }
ModVhostAlias >> host [

	^host
]

{ #category : #accessing }
ModVhostAlias >> host: aString [

	host := aString
]

{ #category : #accessing }
ModVhostAlias >> processHttp [
	"Get the host string and if we match, then process
	our subModules."

	| hostString |
	hostString := ModVhost string.
	host = hostString ifTrue:
		[self processSubModules ifTrue: [^true]].
	^false

]

{ #category : #accessing }
ModVhostAlias >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :module | module isVhost ]
		ifNone: [self error: 'VhostAlias module requires a Vhost module']
]
