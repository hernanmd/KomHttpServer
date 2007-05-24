Class {
	#name : #KomPackageUrl,
	#superclass : #Url,
	#instVars : [
		'name',
		'version'
	],
	#classVars : [
		'LastUpdateDate',
		'Registry'
	],
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #'name resolution' }
KomPackageUrl class >> loadRegistry [

	| lines newReg |
	lines := (self registryUrl retrieveContents contents) findTokens: String crlf.
	lines := lines select: [ :ea | ea withBlanksTrimmed isEmpty not].
	newReg := Dictionary new.
	lines do: 
		[ :line |
		newReg 
			at: (line copyUpTo: $:) withBlanksTrimmed 
			put: (line copyAfter: $:) withBlanksTrimmed].
	LastUpdateDate := Date today.
	^Registry := newReg.

]

{ #category : #'as yet unclassified' }
KomPackageUrl class >> packageName: pkgString version: verString [

	^self new
		packageName: pkgString;
		version: verString;
		yourself
]

{ #category : #'name resolution' }
KomPackageUrl class >> registry [

	(LastUpdateDate ~= Date today or: [Registry isNil]) 
		ifTrue: [self loadRegistry].
	^Registry
]

{ #category : #'name resolution' }
KomPackageUrl class >> registryUrl [

	^'http://people.advantive.com/~spair/squeak/PackageRegistry.txt' asUrl
]

{ #category : #'name resolution' }
KomPackageUrl class >> resetRegistry [
	"self resetRegistry"

	Registry := nil
]

{ #category : #'name resolution' }
KomPackageUrl class >> resolve: aPackageName [
	"Answers another URL that is the home of the package (all versions)"

	^self resolve: aPackageName ifAbsent: [self error: 'no such package']
]

{ #category : #'name resolution' }
KomPackageUrl class >> resolve: aPackageName ifAbsent: absentBlock [
	"Answers another URL that is the home of the package (all versions)"

	^self registry at: aPackageName ifAbsent:
		["Reload the registry and try one more time"
		self loadRegistry.
		self registry at: aPackageName ifAbsent: absentBlock]
	
]

{ #category : #accessing }
KomPackageUrl >> baseUrl [

	^(self class resolve: self name) asUrl
]

{ #category : #accessing }
KomPackageUrl >> categoryName [

	^self installedPackageInfo 
		ifNotNilDo: [ :pi | pi packageName]
]

{ #category : #accessing }
KomPackageUrl >> downloadUrl [

	| tmp |
	tmp := self baseUrl.
	tmp path at: tmp path size put: (tmp path last, '-', self version, '.sar').
	^tmp

]

{ #category : #accessing }
KomPackageUrl >> errorWrongVersion [

	"We need to add mechanisms for loading package configurations (until then, don't
	worry about wrong versions of pre-reqs"

	"self error: ('version ', self installedVersion, ' of ', self packageName, 
		'is installed, but version ', self version, ' is required')"
]

{ #category : #accessing }
KomPackageUrl >> ifNotPresent: notPresentBlock ifWrongVersion: wrongVersionBlock [

	self isWrongVersionPresent ifTrue: [^wrongVersionBlock value].
	self isPresent ifFalse: [^notPresentBlock value].
]

{ #category : #accessing }
KomPackageUrl >> infoClass [

	Smalltalk 
		at: (self packageName, 'Info') asSymbol
		ifPresent: 
			[ :infoClass | ^infoClass ].
	^nil
]

{ #category : #accessing }
KomPackageUrl >> install [

	SARInstaller installSARFromUrl: self downloadUrl
]

{ #category : #accessing }
KomPackageUrl >> installedPackageInfo [

	^self infoClass ifNotNilDo: [ :ic | ic default ]
]

{ #category : #accessing }
KomPackageUrl >> installedVersion [

	^self installedPackageInfo ifNotNilDo: [ :pi | pi releaseName ]
]

{ #category : #accessing }
KomPackageUrl >> isCorrectVersionPresent [

	^self isPresent and: [self isWrongVersionPresent not]
]

{ #category : #accessing }
KomPackageUrl >> isPresent [

	^Smalltalk includesKey: (self packageName, 'Info') asSymbol
]

{ #category : #accessing }
KomPackageUrl >> isStable [

	self isPresent ifFalse: [^self error: 'Package is not loaded'].
	^self installedPackageInfo isStable.

]

{ #category : #accessing }
KomPackageUrl >> isWrongVersionPresent [

	| iv |
	(iv := self installedVersion) ifNil: [^false].
	^iv ~= self version

]

{ #category : #accessing }
KomPackageUrl >> name [

	^name
]

{ #category : #accessing }
KomPackageUrl >> name: aString [

	name := aString
]

{ #category : #accessing }
KomPackageUrl >> packageName [

	^self baseUrl path last
]

{ #category : #printing }
KomPackageUrl >> printOn: strm [

	strm 
		nextPutAll: self schemeName;
		nextPutAll: '://';
		nextPutAll: self name;
		nextPut: $:;
		nextPutAll: self version
]

{ #category : #private }
KomPackageUrl >> privateInitializeFromText: aString [

	| remainder ind schemeName |
	remainder := aString.

	schemeName := Url schemeNameForString: remainder.
	schemeName ifNotNil: [ 
		remainder := remainder copyFrom: (schemeName size+2) to: remainder size ].

	"remove leading // if it's there"
	(remainder beginsWith: '//') ifTrue: [
		remainder := remainder copyFrom: 3 to: remainder size ].

	"get the name"
	ind := remainder indexOf: $/.
	ind > 0 ifTrue: [
		ind = 1 ifTrue: [ name := '' ] ifFalse: [
			name := remainder copyFrom: 1 to: ind-1.
			remainder := remainder copyFrom: ind+1 to: remainder size. ] ]
	ifFalse: [
		name := remainder.
		remainder := ''. ].

	"Extract the version"
	(name includes: $:)
		ifTrue: [
			version := (name copyFrom: (name indexOf: $:) + 1 to: name size).
			name := name copyUpTo: $:].

]

{ #category : #accessing }
KomPackageUrl >> schemeName [
	^'sqpkg'
]

{ #category : #accessing }
KomPackageUrl >> toText [

	^String streamContents: [ :strm | self printOn: strm]
]

{ #category : #accessing }
KomPackageUrl >> version [

	^version
]

{ #category : #accessing }
KomPackageUrl >> version: aString [

	version := aString
]
