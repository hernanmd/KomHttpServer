Class {
	#name : #ItemMenuKomHttpService,
	#superclass : #ProtoObject,
	#category : #'KomHttpServer-KomSBHttpServer'
}

{ #category : #'as yet unclassified' }
ItemMenuKomHttpService >> debugModeString [

	^selection unwrappedItem isDebugMode
		ifTrue: ['<yes>debug mode']
		ifFalse: ['<no>debug mode']

]

{ #category : #'as yet unclassified' }
ItemMenuKomHttpService >> deploymentModeString [

	^selection unwrappedItem isDeploymentMode
		ifTrue: ['<yes>deployment mode']
		ifFalse: ['<no>deployment mode']

]

{ #category : #'as yet unclassified' }
ItemMenuKomHttpService >> detachTranscripts [

	self loggers do: [ :ea | ea detachTranscripts]
]

{ #category : #'as yet unclassified' }
ItemMenuKomHttpService >> doExtentionalClassification: cls [

	^menu
]

{ #category : #'as yet unclassified' }
ItemMenuKomHttpService >> doKomHttpService: dvsp [

	self doKomTcpService: dvsp.
	menu addLine.
	menu addUpdating: #keepAliveString target: self action: #toggleKeepAlive.
	menu addLine.
	menu addUpdating: #deploymentModeString target: self action: #toggleDeploymentMode.
	menu addUpdating: #verboseModeString target: self action: #toggleVerboseMode.
	menu addUpdating: #debugModeString target: self action: #toggleDebugMode.
	menu addLine.
	menu add: 'follow loggers in system transcript' target: self selector: #followLoggersInTranscript.
	menu add: 'open transcripts for all loggers' target: self selector: #openLogTranscripts.
	menu add: 'detach loggers from transcripts' target: self selector: #detachTranscripts.
	menu add: 'inspect loggers' target: self selector: #inspectLoggers.
	^menu
]
