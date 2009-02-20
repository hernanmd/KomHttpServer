"
This module simply processes its subModules.  It is handy when you'd like to wrap some modules together a work with them as a unit.

Example:

In the following example, a ModuleAssembly instantiated with #new will have a ModMulti instance as the root of the module stack.  Adding further modules to the assembly results in those modules being added to the ModMulti instance.  In this example, we create an assembly that could be used as the standard document server in a number of places in our main module assembly.  In this manner, we can reuse module assemblies.  Changes to our standard document server assembly would affect the behavior every where we refer to that assembly (also, direct manipulation of the module instances after construction will affect the behavior everywhere an assembly is refered...this may even eliminate the need to rebuild your module assembly).

	| stdDocs ma |

	""Create a stdDocs assembly""
	stdDocs := ModuleAssembly new.
	stdDocs directoryIndex: 'index.html index.htm'.
	stdDocs serveFiles.
	stdDocs notFound.

	""Now create our main assembly""
	ma := ModuleAssembly core.
	ma alias: '/one' to: 
		[ma documentRoot: (FileDirectory default directoryNamed: 'one').
		ma addAssembly: stdDocs].
	ma alias: '/two' to:
		[ma documentRoot: (FileDirectory default directoryNamed: 'two').
		ma addAssembly: stdDocs].
	ma addPlug: 
		[:request | HttpResponse fromString: 
			'<a href=""one"">go to one</a> <a href=""two"">go to two</a>'].
	(HttpService startOn: 8080 named: 'Example') module: ma rootModule.


"
Class {
	#name : #ModMulti,
	#superclass : #ComancheModule,
	#category : #'KomHttpServer-Modules'
}

{ #category : #processing }
ModMulti >> processHttp [

	^self processSubModules
]
