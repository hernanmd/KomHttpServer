"
KomPackaging provides a number of utilities for managing PackageInfo (DVS) / SAR based packages.  It enables single click building and publishing, pre-requisite management,  pre-requisite auto installation, headles installation, optional installation of SUnit based test classes, install time unit test execution, and optional package installation, package registry, url based package addressing, generation of release notes (i.e. what you're reading right now), and many other things.  Not much time was spent developing a robust UI for all of these capabilities however.

Package URLs:

This package adds support for two types of urls, package and squeakmap...they take the forms:

	sqpkg://httpserver.kom:6.1
	sqmap://Named Process:1.1

You can do interesting things with these URLs, such as install them:

	'sqpkg://httpserver.kom:6.1' asUrl install

or, query whether or not a version of the package is currently installed:

	'sqpkg://httpserver.kom:6.1' asUrl isPresent

Version 1.0:
	- initial version
"
Class {
	#name : #KomPackagingInfo,
	#superclass : #KomPackageInfo,
	#category : #'KomHttpServer-KomPackaging'
}

{ #category : #'as yet unclassified' }
KomPackagingInfo >> isKomPackagingPackage [

	^true
]

{ #category : #'as yet unclassified' }
KomPackagingInfo >> optionalPackages [

^#(
('KomPackageBuilder' 'sqpkg://packageBuilder.kom:1.0'
'KomPackageBuilder is a useful package if you would like to use the
Comanche packaging system to build your own packages.  Would you
like to load this package now?')
)

]

{ #category : #'as yet unclassified' }
KomPackagingInfo >> preloadChangeSetNames [

	^#('KomPackaging-preload.cs')
]

{ #category : #'as yet unclassified' }
KomPackagingInfo >> releaseName [

	^'1.0'
]
