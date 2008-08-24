Extension { #name : #SocketStream }

{ #category : #'*KomHttpServer-stream in' }
SocketStream >> upToAll: aStringOrByteArray bufferSize: maxSize do: aBlock [
	"A variant of #upToAll: that executes a block chunk wise for the result instead of
	returning the result as a collection. See #upToAll: for details."

	| index sz result lastRecentlyRead searchedSoFar insz |
	sz _ aStringOrByteArray size.
	searchedSoFar _ 0.
	lastRecentlyRead _ 0.
	index _ 0.
	[self atEnd not and: [
		insz := self inBufferSize.
		((lastRecentlyRead = 0 and: [self isInBufferEmpty not]) or: [insz > maxSize]) ifTrue: [
			"Data begins at lastRead + 1."
			index _ inBuffer indexOfSubCollection: aStringOrByteArray startingAt: lastRead + 1.
			searchedSoFar _ insz.
			(index > 0 and: [(index + sz) > inNextToWrite]) ifTrue: [
				"Oops, hit partially or completely in dead buffer area.
				This is probably due to old data, so we ignore it.
				No point in cleaning the dead area to avoid hits - it will still search it."
				index _ 0].
			index = 0 ifTrue: ["Just searched and did not find it, we only consume most of inBuffer to create overlap"
				aBlock value: (self nextInBuffer: (searchedSoFar - sz)) ].
			].
		index = 0]]
				whileTrue: [
					recentlyRead = 0
						ifTrue: ["blocking call for now, we don't want to poll"
							self receiveData]
						ifFalse: [
							self receiveAvailableData].
					lastRecentlyRead _ recentlyRead].
	index > 0
		ifTrue: ["found it"
			result _ self nextInBuffer: index - lastRead - 1.
			self skip: sz.
			^aBlock value: result]
		ifFalse: ["atEnd"
			^aBlock value: self nextAllInBuffer]
]

{ #category : #'*KomHttpServer-stream in' }
SocketStream >> upToAll: aStringOrByteArray bufferSize: maxSize inBufferDo: aBlock [
	"Yet another variant of #upToAll: that executes a 3-arg block which is given
	direct access to the inBuffer (for zero copy chunk wise reading) and start, stop indexes.
	See #upToAll: for details."

	| index sz result lastRecentlyRead searchedSoFar insz |
	sz _ aStringOrByteArray size.
	searchedSoFar _ 0.
	lastRecentlyRead _ 0.
	index _ 0.
	[self atEnd not and: [
		insz := self inBufferSize.
		((lastRecentlyRead = 0 and: [self isInBufferEmpty not]) or: [insz > maxSize]) ifTrue: [
			"Data begins at lastRead + 1."
			index _ inBuffer indexOfSubCollection: aStringOrByteArray startingAt: lastRead + 1.
			searchedSoFar _ insz.
			(index > 0 and: [(index + sz) > inNextToWrite]) ifTrue: [
				"Oops, hit partially or completely in dead buffer area.
				This is probably due to old data, so we ignore it.
				No point in cleaning the dead area to avoid hits - it will still search it."
				index _ 0].
			index = 0 ifTrue: ["Just searched and did not find it, we only consume most of inBuffer to create overlap"
				self nextInBuffer: (searchedSoFar - sz) do: aBlock ].
			].
		index = 0]]
				whileTrue: [
					recentlyRead = 0
						ifTrue: ["blocking call for now, we don't want to poll"
							self receiveData]
						ifFalse: [
							self receiveAvailableData].
					lastRecentlyRead _ recentlyRead].
	index > 0
		ifTrue: ["found it"
			result _ self nextInBuffer: index - lastRead - 1 do: aBlock.
			self skip: sz.
			^result]
		ifFalse: ["atEnd"
			^self nextAllInBufferDo: aBlock]
]
