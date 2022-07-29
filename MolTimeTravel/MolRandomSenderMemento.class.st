Class {
	#name : #MolRandomSenderMemento,
	#superclass : #MolComponentMemento,
	#category : #MolTimeTravel
}

{ #category : #'undo - undo' }
MolRandomSenderMemento >> redo [

	self restoreValues.
]

{ #category : #'undo - undo' }
MolRandomSenderMemento >> save: aGround [

	componentReference := MolComponentReference newFrom: aGround.
]

{ #category : #'undo - undo' }
MolRandomSenderMemento >> undo [

	self restoreValues
]
