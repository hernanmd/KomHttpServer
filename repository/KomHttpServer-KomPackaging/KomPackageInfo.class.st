Class {
	#name : #KomPackageInfo,
	#superclass : #PackageInfo,
	#instVars : [
		'buildNumber',
		'buildDirectory',
		'snapshotDirectory',
		'publishDirectory'
	],
	#classVars : [
		'RootBuildDirectory'
	],
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #'as yet unclassified' }
KomPackageInfo class >> browsePrereq: prereqName [

	MessageSet 
		openMessageList:
			(OrderedCollection with:
				(MethodReference new
					setClass: self
					methodSymbol: #prerequisites
					stringVersion: ''))
		name: (self class name, '>>prerequisites')
		autoSelect: prereqName

	
]

{ #category : #'as yet unclassified' }
KomPackageInfo class >> rootBuildDirectory [

	^RootBuildDirectory ifNil: [RootBuildDirectory := FileDirectory default]
]

{ #category : #'as yet unclassified' }
KomPackageInfo class >> rootBuildDirectory: aFileDirectory [
	"Sets the rootBuildDirectory...evaluate the following
	code to change the root build directory using a GUI"

	"(FileList2 modalFolderSelector: self rootBuildDirectory) 
		ifNotNilDo: [:dir | self rootBuildDirectory: dir ]"

	RootBuildDirectory := aFileDirectory
]

{ #category : #'as yet unclassified' }
KomPackageInfo class >> runTestCases [

	self default runTestCases
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> assureExistenceOfBuildDirectory [

	self buildDirectory assureExistence


]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildDirectory [

	^buildDirectory

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildDirectory: aFileDirectoryOrString [

	buildDirectory := aFileDirectoryOrString isString
			ifTrue: [FileDirectory on: aFileDirectoryOrString]
			ifFalse: [aFileDirectoryOrString]

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildFileName [

	^self buildFileNameFor: self buildNumber

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildFileNameFor: aVersionNumber [

	^self buildDirectory fullNameFor: 
		(self packageName, '-bld', aVersionNumber versionString, '.sar')
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildHistory [

	| in |
	^VersionHistory fromCollection:
		((self buildDirectory fileNamesMatching: (self packageName, '-bld*.sar'))
			collect: 
				[ :ea | 
				in := ea indexOfSubCollection: '-bld' startingAt: 1.
				(ea copyFrom: (in + 4) to: (ea size - 4)) asVersion]).

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildNumber [

	^buildNumber
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildNumber: aVersionNumber [

	buildNumber := aVersionNumber
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> buildNumberString [

	^(self buildNumber ifNil: [^'0']) versionString
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> classes [
	| answer |
	answer := self systemCategories gather:
		[:cat |
		(SystemOrganization listAtCategoryNamed: cat)
			collect: [:className | Smalltalk at: className]].
	Smalltalk at: #TestCase ifPresent: 
		[ :tcClass |
		^answer select: [ :cls | (cls inheritsFrom: tcClass) not]].
	^answer

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> conditionalChangeSets [
	"Subclass to answer an array of two item arrays.  The first item is a string
	of valid Smalltalk code that should evaluate to a boolean.  The second item is 
	a string that specifies a change set name.  The change sets specified may either
	reside in the image, or as a file in the default directory."

	^#()
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> definition [

	^String streamContents: 
		[ :strm |
		strm nextPutAll: self class name.
		strm nextPutAll: ' default'.
		strm cr.
		strm nextPutAll: '	buildDirectory: '.
		strm nextPutAll: self buildDirectory fullName printString.
		strm cr.
		strm nextPutAll: '	publishDirectory: '.
		strm nextPutAll: self publishDirectory fullName printString.
		strm cr.
		strm nextPutAll: '	releaseName: '.
		strm nextPutAll: self releaseName printString.
		strm cr.
		strm nextPutAll: '	maturity: '.
		strm nextPutAll: self maturity printString.
		strm cr.
		strm nextPutAll: '	prerequisites: '.
		strm nextPutAll: self prerequisites printString].
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> fileOutOnStream: strm [

	super fileOutOnStream: strm.
	strm nextChunkPut: 
		('Smalltalk at: #FilePackageManager ifPresent: [ :p | p registerPackage: ', self packageName printString, '].').
	strm cr.
	strm nextChunkPut:
		('Smalltalk at: #KomPackageInfo ifPresent: [ :p | (p named: ', self packageName printString, ') buildNumber: ', self buildNumber printString, '].').

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> fileOutSunitOnStream: aStream [
	
	(ChangeSet superclassOrder: self sunitClassesAndMetaClasses)
		do: [:class | aStream nextChunkPut: class definition; cr; cr]
		displayingProgress: 'Filing out classes...'.
	
	self sunitClasses do:
		[:class |
		class organization classComment isEmpty
			ifFalse: [class organization putCommentOnFile: aStream numbered: 0 moveSource: false forClass: class]].
		
	(self sunitMethods sortBy:
		[:a :b | a methodSymbol < b methodSymbol or: [a methodSymbol = b methodSymbol and: [a classSymbol <= b classSymbol]]])
			do: [:ref | ref actualClass
							printMethodChunk: ref methodSymbol
							withPreamble: true
							on: aStream
							moveSource: false toFile: 0]
			displayingProgress: 'Filing out methods...'.
	
	(self sunitClasses select: [:c | c class includesSelector: #initialize])
		do: [:class | aStream nextChunkPut: class name, ' initialize'; cr].
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> incrementBuildNumber [

	buildNumber ifNil: [buildNumber := '1' asVersion. ^self].
	buildNumber := self buildHistory addNewVersionBasedOn: buildNumber
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> isKomPackagingPackage [

	^false
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> isStable [

	^self maturity == #stable
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> isUnstable [

	^self maturity ~~ #stable
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> manager [

	^PackageManager named: self packageName
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> maturity [
	"<#alpha | #beta | #gamma | #stable> Answers a symbol indicating the maturity
	of the package...packages listed as #stable indicate that no further builds of that
	release name should be allowed (attempts to build or publish #stable packages will
	fail).  Instead, change the release name and mark the package as something other
	than #stable.  Additionally, if a package is marked #stable, then validating 
	prerequisites will validate that all pre-requisite packages are also marked #stable.

	By default, packages are considered to be #alpha."

	^#alpha
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> optionalPackages [

	^#()
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> packageName [

	(self class == (Smalltalk at: #KomPackageInfo)) ifTrue: [^'ABSTRACT'].
	^packageName ifNil: [packageName _ (self categoryName copyUpTo: $-) ]
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> preloadChangeSetNames [

	^#()
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> preloadChangeSets [

	^self preloadChangeSetNames collect: 
		[ :nm |
		(ChangeSorter changeSetNamed: nm) 
			ifNil: [self error: 'missing preload change set']]
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> prerequisiteNames [

	^self prerequisites collect: [ :ea | ea first ]
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> prerequisites [

	^#()
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> publish [

	| srcName destName |

	"First copy the latest version"
	(self buildHistory includesVersion: self buildNumber)
		ifFalse: [^self inform: 'no build file matching the package in memory'].
	srcName := self buildFileName.
	destName := self publishFileName.
	FileDirectory default copyFileNamed: srcName toFileNamed: destName.

	"Now copy the readme.txt"
	srcName := self buildDirectory fullNameFor: (self packageName, '.txt').
	(FileStream isAFileNamed: srcName) ifFalse: [^self].
	destName := self publishDirectory fullNameFor: (self packageName, '-', self releaseName, '.txt').
	FileDirectory default copyFileNamed: srcName toFileNamed: destName.

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> publishDeveloperSnapshot [

	| latestVersion srcName destName |
	latestVersion := self buildHistory latestMainLineVersion.
	srcName := self buildFileNameFor: latestVersion.
	destName := self snapshotFileName.
	FileDirectory default copyFileNamed: srcName toFileNamed: destName.
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> publishDirectory [
	"Need to refactor to remove GUI code"

	| initialSelection |
	initialSelection := self buildDirectory.
	snapshotDirectory ifNotNil: [initialSelection := snapshotDirectory].
	publishDirectory ifNil: 
		[(FileList2 modalFolderSelector: initialSelection) 
			ifNotNilDo: [:dir | publishDirectory := dir ]].
	^publishDirectory
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> publishFileName [

	^self publishDirectory fullNameFor: 
		(self packageName, '-', self releaseName, '.sar')
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> readmeFileName [

	^self buildDirectory fullNameFor: 
		(self packageName, '-bld', self buildNumber versionString, '.txt')
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> readmeText [

	^self class comment asString

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> releaseName [
	"Subclasses should override this method to provide their
	own release names"

	^'1.0'
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> runTestCases [
	"This method is designed to be run at package install time"

	| suite testResults |
	(Smalltalk includesKey: #TestSuite) ifFalse: 
		[^self error: 'SUnit does not appear to be installed'].
	InstallOptions log: (self packageName, ': running SUnit tests (').
	suite := (Smalltalk at: #TestSuite) new.
	self sunitClasses do: [ :testClass | suite addTests: testClass suite tests].
	testResults _ suite run.
	InstallOptions log: testResults printString.
	(testResults errorCount > 0 or: [testResults failureCount > 0])
		ifTrue: 
			[InstallOptions log: (') FAILED!', String cr)]
		ifFalse:
			[InstallOptions log: (') PASSED!', String cr)].
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> snapshotDirectory [
	"Need to refactor to remove GUI code"

	| initialSelection |
	initialSelection := self buildDirectory.
	publishDirectory ifNotNil: [initialSelection := publishDirectory].
	snapshotDirectory ifNil: 
		[(FileList2 modalFolderSelector: initialSelection) 
			ifNotNilDo: [:dir | snapshotDirectory := dir ]].
	^snapshotDirectory
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> snapshotFileName [

	^self snapshotDirectory fullNameFor: 
		(self packageName, '-latest.sar')
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> sunitClasses [
	| answer |
	answer := self systemCategories gather:
		[:cat |
		(SystemOrganization listAtCategoryNamed: cat)
			collect: [:className | Smalltalk at: className]].
	Smalltalk at: #TestCase ifPresent: 
		[ :tcClass |
		^answer select: [ :cls | cls inheritsFrom: tcClass]].
	^#()

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> sunitClassesAndMetaClasses [
	| baseClasses |
	baseClasses := self sunitClasses.
	^baseClasses , (baseClasses collect: [:c | c class])
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> sunitMethods [
	^ self sunitClassesAndMetaClasses gather: [:class | self coreMethodsForClass: class]
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> validatePrerequisites [
	"This checks that the default prerequisite fulfillments match the versions
	that we think are loaded"

	| text item start link end |
	text := '' asText.
	self 
		visitPrerequisites: 
			[ :preRL :pkgInfo |
			item := nil.
			preRL isPresent ifFalse: 
				[item := '- Prerequisite "', preRL name ,'" in ', 
					pkgInfo class name,
					' does not appear to be present in the image', 
					String cr, String cr].
			preRL isWrongVersionPresent ifTrue:
				[item := '- Prerequisite "', preRL name ,'" in ', 
					pkgInfo class name,
					' does not appear to be consistent with the loaded version', 
					String cr, String cr].
			(self isStable and: [preRL isCorrectVersionPresent and: [preRL isStable not]]) 
				ifTrue:
				[item := '- Prerequisite "', preRL name ,'" in ', 
					pkgInfo class name,
					' is present, however its maturity level is marked unstable', 
					String cr, String cr].

			item ifNotNil: 
				[link := TextDoIt new evalString: (pkgInfo class name, 
						' browsePrereq: ', preRL name printString).
				start := text size + 1.
				end := item size + start.
				text append: item.
				text addAttribute: link from: start to: end]]
		visited: Set new.
	text string isEmpty ifTrue: 
		[^self inform: 'All prerequisites are consistent with the versions in memory'].

	StringHolder new
		acceptContents: text;
		openLabel: 'Inconsistent Prerequisites'.

]

{ #category : #'as yet unclassified' }
KomPackageInfo >> versionInfo [

	^self releaseName, ' {', self buildNumberString, '}'
]

{ #category : #'as yet unclassified' }
KomPackageInfo >> visitPrerequisites: aBlock visited: visited [

	| url |
	self prerequisites do:
		[ :arr |
		url := arr second asUrl.
		(visited includes: arr second) ifFalse:
			[visited add: arr second.
			aBlock value: url value: self.
			url installedPackageInfo ifNotNilDo:
				[ :pkgInfo | pkgInfo visitPrerequisites: aBlock visited: visited]]].
]
