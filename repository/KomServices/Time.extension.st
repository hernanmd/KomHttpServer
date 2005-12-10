Extension { #name : #Time }

{ #category : #'*KomServices' }
Time class >> deadlineSecs: secs [
	"Return a deadline time the given number of seconds from now."
	"SVP: copied here from Socket because I think it's more appropriate here"

	^ self millisecondClockValue + (secs * 1000)

]
