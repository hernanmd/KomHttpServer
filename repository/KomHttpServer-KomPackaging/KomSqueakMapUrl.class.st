Class {
	#name : #KomSqueakMapUrl,
	#superclass : #KomPackageUrl,
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #packaging }
KomSqueakMapUrl >> install [

	SMSqueakMap default 
		installPackageNamed: self name.
	self smCard ifNotNilDo: 
		[ :card |
		(SMSqueakMap default installedVersionOf: card) = self version ifFalse:
			[self inform: ('Warning: prerequisite specified version ', 
				self version,'\',	'of ', card name,
				' but version ', card currentVersion,' is currently\',
				'registered on SqueakMap.  Incompatibilities\',
				'might exist and cause problems.') withCRs]]
]

{ #category : #packaging }
KomSqueakMapUrl >> installedVersion [

	| ourCard |
	(ourCard := self smCard) ifNil: [^nil].
	^SMSqueakMap default installedVersionOf: ourCard
]

{ #category : #packaging }
KomSqueakMapUrl >> isPresent [

	^(self smCard ifNil: [^false]) isInstalled
]

{ #category : #packaging }
KomSqueakMapUrl >> isStable [
	"Assume that any non KomPackageInfo is stable"
 
	^true
]

{ #category : #packaging }
KomSqueakMapUrl >> packageName [

	^self name
]

{ #category : #packaging }
KomSqueakMapUrl >> pkgInstalledPackageInfo [

	^nil
]

{ #category : #packaging }
KomSqueakMapUrl >> schemeName [
	^'sqmap'
]

{ #category : #packaging }
KomSqueakMapUrl >> smCard [

	^SMSqueakMap default cardWithNameBeginning: self name
]

{ #category : #printing }
KomSqueakMapUrl >> toText [

	^String streamContents: [ :strm | self printOn: strm]
]
