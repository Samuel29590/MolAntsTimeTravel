Class {
	#name : #MolComponentStep,
	#superclass : #Object,
	#instVars : [
		'mementos',
		'creationsAndDeletions',
		'events'
	],
	#category : #MolTimeTravel
}

{ #category : #accessing }
MolComponentStep >> creationsAndDeletions [

	^ creationsAndDeletions
]

{ #category : #accessing }
MolComponentStep >> events [

	^ events
]

{ #category : #initialization }
MolComponentStep >> initialize [

	super initialize.
	mementos := OrderedCollection new.
	events := OrderedCollection new.
	creationsAndDeletions := OrderedCollection new
]

{ #category : #initialization }
MolComponentStep >> isANewStep [

	(mementos size > 0)|(creationsAndDeletions size > 0)|(events size > 0) ifTrue: [ ^ false ].
	
	^ true.
]

{ #category : #accessing }
MolComponentStep >> mementos [

	^ mementos
]

{ #category : #initialization }
MolComponentStep >> save: aComponentMemento [

	mementos add: aComponentMemento 
]

{ #category : #initialization }
MolComponentStep >> saveCreationOrDeletionOf: aComponentMemento [

	creationsAndDeletions add: aComponentMemento
]

{ #category : #initialization }
MolComponentStep >> saveEvent: aComponentMemento [

	events add: aComponentMemento
]

{ #category : #initialization }
MolComponentStep >> stepAlreadyContains: aComponentMemento [

	| class name |
	class := aComponentMemento componentReference componentClass.
	name := aComponentMemento componentReference componentName.

	mementos do: [ :memento | 
		name = memento componentReference componentName ifTrue: [ 
			class = memento componentReference componentClass ifTrue: [ ^ true.  ] ] ].

	^ false
]
