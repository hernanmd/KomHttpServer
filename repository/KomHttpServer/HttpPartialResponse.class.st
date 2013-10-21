"
kom/4.12 (Comanche/4.12)

HttpPartialResponse (bolot 4/2/2001 18:49)
- not a very accurate name
- a subclass of HttpResponse
-- allows for long-execution modules to write directly to the client

"
Class {
	#name : #HttpPartialResponse,
	#superclass : #HttpResponse,
	#instVars : [
		'producerBlock'
	],
	#category : #'KomHttpServer-Protocol'
}

{ #category : #accessing }
HttpPartialResponse >> producerBlock: aBlock [
	producerBlock := aBlock
]

{ #category : #responding }
HttpPartialResponse >> pvtWriteContentLengthOn: aStream [
	"do nothing, since the length is not known yet"
	self flag: #todo. "in HTTP/1.1, can set chunking"
]

{ #category : #responding }
HttpPartialResponse >> pvtWriteContentsOn: aStream [
	producerBlock value: aStream
]
