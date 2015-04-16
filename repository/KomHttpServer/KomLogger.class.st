"
I am a very simple http logging facility.  I implement a writable stream interface and expect to recieve arrays containing an HttpRequest (first element) and an HttpResponse (second element).  I then translate the request and response pair into a textual log format and write that onto each stream in my streams instance variable.  Other loggers may choose to write different log formats, or they could simply store the HttpRequest and HttpResponse objects (in an object DB for example).  For convenience, a transcript window can be opened on a logger using #openTranscript.  You Can also use the method #attachTheTranscript to copy the log entries onto the system Transcript.  Use #detachTranscripts to remove all instances of TranscriptStream from the set of streams.

Currently I only support the Commog Log Format (CLF), which many log analysis tools can interpret.  For more information on this format, see:

  http://www.w3.org/Daemon/User/Config/Logging.html#common-logfile-format

For examples, see the class comments for ModLog.


Enhancement ideas:

- support a flexible logging format that uses some type of template string (ala Apache's logging facility) for producing each line in the log file 
- implement a ""multi-streamer"" that implements a writable stream interface and will copy the output to multiple output streams
- implement a unix like tail tool that implement a writable stream interface and will ""follow"" everything that's written to it (similar to the Transcript, but designed to only show the most recent N number of lines or characters)


(KomLogger on: Transcript)  openTranscript

(KomLogger on: Transcript)  detachTranscripts ; attachTheTranscript;
openTranscript
"
Class {
	#name : #KomLogger,
	#superclass : #Stream,
	#instVars : [
		'streams'
	],
	#category : #'KomHttpServer-Modules'
}

{ #category : #'as yet unclassified' }
KomLogger class >> on: aStream [

	^self basicNew
		streams: (Set new add: aStream; yourself);
		yourself
]

{ #category : #accessing }
KomLogger >> addStream: aStream [
	"Add a new output stream to the logger"

	self streams add: aStream.
	^aStream
]

{ #category : #accessing }
KomLogger >> attachTheTranscript [

	^self addStream: Transcript.

]

{ #category : #accessing }
KomLogger >> attachTranscript [
	self detachTheTranscript.
	^(self streams detect: [:ea | ea isTranscriptStream] ifNone: [nil]) 
		ifNil: [self addStream: ThreadSafeTranscript new]
]

{ #category : #accessing }
KomLogger >> detachTheTranscript [

	self removeStream: Transcript.
	^Transcript
]

{ #category : #accessing }
KomLogger >> detachTranscripts [
	(self streams select: [:ea | ea isTranscriptStream]) 
		do: [:ea | self removeStream: ea]
]

{ #category : #accessing }
KomLogger >> logEntryFor: request response: response [
	"This is the Common Log Format (CLF)"

	^String streamContents: 
		[ :strm |
		strm
			nextPutAll: request remoteAddress asIpString;
			nextPutAll: ' - ';  "We don't bother with the ident string"
			nextPutAll: (ModAuth user ifNil: ['-']);
			nextPut: $ .
		(DateAndTime fromSeconds: request timestamp)
			printCLFFormatOn: strm.
		strm nextPutAll: ' "'.
		request firstLineOn: strm.
		strm nextPutAll: '" '.
		strm nextPutAll: response statusCode.
		strm nextPut: $ .
		strm nextPutAll: (response contentLength ifNil: ['-']) asString.
		strm nextPut: Character cr].



]

{ #category : #accessing }
KomLogger >> next [

	self shouldNotImplement
]

{ #category : #accessing }
KomLogger >> nextPut: anArray [ 
	| logEntry |
	logEntry := self logEntryFor: anArray first response: anArray second.
	self streams do: 	[:strm | strm nextPutAll: logEntry; endEntry]
]

{ #category : #accessing }
KomLogger >> openTranscript [

	self attachTranscript openLabel: 'Comanche Logger'
]

{ #category : #accessing }
KomLogger >> removeStream: aStream [
	"Remove an output stream to the logger"

	self streams remove: aStream ifAbsent: [].
	^aStream
]

{ #category : #accessing }
KomLogger >> streams [

	^streams
]

{ #category : #accessing }
KomLogger >> streams: aStream [

	streams := aStream
]
