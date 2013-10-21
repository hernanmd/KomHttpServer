"
Used for determining the document root for mass virtual hosting (where the virtual server name is incorporated into the document root).  See the class comments for ModVhost for an example of virtual hosting.
"
Class {
	#name : #ModVhostDoc,
	#superclass : #ModDoc,
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
ModVhostDoc >> documentRoot [

	^super documentRoot directoryNamed: ModVhost string
]

{ #category : #validation }
ModVhostDoc >> validateForStack: anArray problems: problems [

	super validateForStack: anArray problems: problems.
	anArray 
		detect: [ :module | module isVhost ]
		ifNone: [self error: 'VhostDoc module requires a Vhost module']
]
