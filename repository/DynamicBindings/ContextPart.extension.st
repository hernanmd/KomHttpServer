Extension { #name : #ContextPart }

{ #category : #'*DynamicBindings' }
ContextPart >> bindings [
	"Answers the Dynamic Bindings that are currently visible in the receiver's context.  This is kind of a hack...we could do a better job of this if we used the exception handling primitives directly, however, this implementation has the benefit of being slightly more portable."
	
	| oldSender answer |
	oldSender _ thisContext swapSender: self.
	answer _ BindingsLocator signal.
	thisContext swapSender: oldSender.
	^answer 

	
]
