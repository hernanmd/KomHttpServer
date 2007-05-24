"
DynamicBindings for Squeak
by Stephen Pair <stephen@pairhome.net> 

===== Introduction =====

You may create a hierarchy of DynamicBindings and directly manipulate the keys and values of those instances (just as you would any dictionary).  There is a root DynamicBindings that you may use to create new children if you like (but you can also create entirely separate hierarchies).  You can access this root with ""DynamicBindings root"".  To force a process to use one of your sets of DynamicBindings, you write code as follows (note, I only use 'PATH' to highlight the similarity with normal OS environment variables):

	myBindings _ DynamicBindings root newChild.
	myBindings at: #PATH put: '/bin:/usr/bin'.
	myBindings bindDuring: 
		[Bindings at: #PATH.  				""-> '/bin:/usr/bin'""
		Bindings at: #PATH put: ('/usr/local/bin:', (Bindings at: #PATH)).
		Bindings at: #PATH].  				""-> '/usr/local/bin:/bin:/usr/bin'""

For convenience, two methods have been added to Object that enable more direct access to bindings.  The following exampel is equivalent to the first:

	myBindings _ DynamicBindings root newChild.
	myBindings at: #PATH put: '/bin:/usr/bin'.
	myBindings bindDuring: 
		[#PATH binding.  				""-> '/bin:/usr/bin'""
		#PATH binding: ('/usr/local/bin:', (#PATH binding)).
		#PATH binding].  				""-> '/usr/local/bin:/bin:/usr/bin'""


The first line creates a new set of bindings that is a child of the root bindings.  Any variables set in the root bindings are also visible in this new child environment.

The second line sets the dynamic variable ""PATH"".

The third line uses the evaluates the argument block in the context of our new set of bindings.

The fourth line gets the value for the variable ""PATH"" (which we just set).

The fifth line in the above example modifies the environment variable ""PATH"", but only for the duration that the enclosing block is active.

Here is another example:

	#PATH binding: '/bin'.
	Bindings clamp:
		[#PATH binding: '/usr/bin'.
		#PATH binding]. 						""-> '/usr/bin'""
	#PATH binding.								""-> '/bin'""

This example shows the use of the #clamp: method to isolate a our dynamic bindings only for the duration of a block.  After the block finishes execution, the original set of bindings is restored.

Scoping semantics:

A dynamic variables' scope is defined at runtime by an enclosing activation context.  To locate the active lexicon of dynamic variables, the system follows the activation stack until a context is encountered that defines the active DynamicBindings (this lookup is implemented using the exception handling system).  Any changes to the active DynamicBindings are visible in all activation contexts where that set of DynamicBindings are being used (which may include contexts in more than one activation stack).

A bit about how it's implemented:

The bindings for a given method activation context are located using the exception handling mechanism (see BindingsLocator).  If a given stack does not have a handler that answers a set of bindings, then dummy contexts will be added to the top of the stack that will answer the global root set of bindings.

Unlike other implementations, DynamicBindings do not use the activation stack to define the hierarchy of bindings.  Instances of DynamicBindings have their own parent instance variable and will locate enclosing variable scopes by following the chain of parents (*not* by looking for enclosing handlers of BindingsLocator).  Using this design, we are able to accomodate a broader range of usage scenarios.

If you need to isolate the bindings of a given context stack such that future changes in the bindings are not visible to users of the current set of dynamic bindings (ie. if you use continuations), you can send the message #isolate to the BindingsAccessor (ie. use ""Bindings isolate"").

===== Release History =====

Version 1.1:
	- Packaged using KomPackaging (Squeak version only)
	- Made Object>>binding: answer its argument
	- Cleaned up a few obsolete methods from the old RuntimeEnvironments implementation

Version 1.0:
	- Initial release
"
Class {
	#name : #DynamicBindingsInfo,
	#superclass : #ProtoObject,
	#category : #'DynamicBindings-Core'
}

{ #category : #'as yet unclassified' }
DynamicBindingsInfo >> preambleText [
	"Executed first to load the package"

	^'"' , self packageName , '"', String cr, 'Smalltalk at: #Bindings put: nil'
]

{ #category : #'as yet unclassified' }
DynamicBindingsInfo >> releaseName [

	^'1.1'
]
