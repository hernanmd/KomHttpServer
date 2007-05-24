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
