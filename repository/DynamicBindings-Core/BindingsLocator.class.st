"
I am used to find the runtime environment of a given ContextPart.  If no suitable handler is found, then I will install dummy contexts at the top of the stack that include a handler that returns the default bindings for the system (ie. ""DynamicBindings root"").
"
Class {
	#name : #BindingsLocator,
	#superclass : #Notification,
	#classVars : [
		'Default'
	],
	#category : #'DynamicBindings-Core'
}

{ #category : #exceptionDescription }
BindingsLocator >> defaultAction [
	"Finds the root context for the active stack, then installs a new
	handler context that will answer the context containing the root 
	environment.  This method depends on the implementation of
	#valueWithBindings:."

	| tmp defaultActionCtx |
	tmp _ thisContext.
	[tmp sender notNil] whileTrue: [tmp _ tmp sender].

	defaultActionCtx _ thisContext.
	[	
		tmp swapSender: thisContext sender.
		thisContext sender sender sender swapSender: nil.
		thisContext swapSender: defaultActionCtx.
	] valueWithBindings: DynamicBindings root.

	^tmp sender sender sender

]
