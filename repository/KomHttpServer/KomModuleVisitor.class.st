Class {
	#name : #KomModuleVisitor,
	#superclass : #Object,
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
KomModuleVisitor >> doBlock: aBlock [

	aBlock numArgs = 1 ifTrue: [self doMonadicValuable: aBlock].
	aBlock numArgs = 1 ifTrue: [self doDyadicValuable: aBlock]

]

{ #category : #'as yet unclassified' }
KomModuleVisitor >> doComancheModule: aComancheModule [
	"For visiting a module hierarchy"

]

{ #category : #'as yet unclassified' }
KomModuleVisitor >> doDyadicValuable: aDyadicValuable [
	"By default, do nothing since these aren't really modules"

]

{ #category : #'as yet unclassified' }
KomModuleVisitor >> doMessageSend: aMessageSend [

	aMessageSend arguments size = 1 ifTrue: [^self doMonadicValuable: aMessageSend].
	aMessageSend arguments size = 2 ifTrue: [^self doDyadicValuable: aMessageSend]
]

{ #category : #'as yet unclassified' }
KomModuleVisitor >> doMonadicValuable: aMonadicValuable [
	"By default, do nothing since these aren't really modules"

]
