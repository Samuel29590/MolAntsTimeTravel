Class {
	#name : #MolTimeTravel,
	#superclass : #Object,
	#traits : 'MolComponentImpl + TimeTravelType + TimeTravelServices',
	#classTraits : 'MolComponentImpl classTrait + TimeTravelType classTrait + TimeTravelServices classTrait',
	#instVars : [
		'history',
		'currentStep',
		'lastStep',
		'isSaving',
		'isRestoring',
		'isReplaying',
		'isPlayingBackward',
		'timeTravelLoop',
		'mySpace',
		'currentStepView',
		'buttonStartTimeTravel',
		'buttonStopTimeTravel',
		'buttonOneStepBefore',
		'buttonOneStepAfter',
		'buttonPlayBackward',
		'buttonReplay',
		'timeTravelPanel',
		'panelLoop',
		'inspector',
		'currentStepText',
		'buttonStop',
		'lastStepText',
		'lastStepView',
		'logsView',
		'logsText'
	],
	#category : #MolTimeTravel
}

{ #category : #'life cycle' }
MolTimeTravel >> componentInitialize [

	"here write the code corresponding to component initialisation phase"

	isSaving := true.
	isRestoring := false.
	isReplaying := false.
	isPlayingBackward := false.
	timeTravelLoop := nil.
	lastStep := 2.
	currentStep := 2.
	history := OrderedCollection new.
	history add: MolComponentStep new.
	history add: MolComponentStep new.

	self createTimeTravelPanel.

	inspector := MolComponentManager default homeServices
		             deployedComponents inspect.

	mySpace show
]

{ #category : #'life cycle' }
MolTimeTravel >> componentRemove [

	"here write the code corresponding to component remove phase"

	self stopTimeTravelPanelLoop.

	inspector ifNotNil: [ inspector close ].
	mySpace ifNotNil: [ mySpace close ].

	history := nil.
	lastStep := nil.
	currentStep := nil.
	isSaving := nil.
	isRestoring := nil.
	isReplaying := nil.
	isPlayingBackward := nil.
	timeTravelLoop := nil.
	mySpace := nil.
	timeTravelPanel := nil.
	inspector := nil
]

{ #category : #'life cycle' }
MolTimeTravel >> createTimeTravelPanel [

	| labelText label |
	mySpace := BlSpace new
		           extent: 800 @ 300;
		           title: 'TimeTravel Panel'.

	timeTravelPanel := BlElement new
		                   background: Color gray;
		                   constraintsDo: [ :c | 
			                   c horizontal matchParent.
			                   c vertical matchParent ].
	mySpace addChild: timeTravelPanel.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding returningStep to the panel."

	lastStepText := (BlTextElement new background: Color transparent) 
		                text: 'Last Step :' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ lastStepText relocate: timeTravelPanel size x / 10 @ 20 ].
	timeTravelPanel addChild: lastStepText.
	lastStepView := BlTextElement new
		                background: Color transparent;
		                text: '000' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ lastStepView relocate: timeTravelPanel size x / 10 @ 40 ].
	timeTravelPanel addChild: lastStepView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding currentStep to the panel."

	currentStepText := BlTextElement new
		                   background: Color transparent;
		                   text: 'Current Step :' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		currentStepText relocate: timeTravelPanel size x / 10 * 5 @ 20 ].
	timeTravelPanel addChild: currentStepText.
	currentStepView := BlTextElement new
		                   background: Color transparent;
		                   text: '000' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		currentStepView relocate: timeTravelPanel size x / 10 * 5 @ 40 ].
	timeTravelPanel addChild: currentStepView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding the Start time trave button"
	buttonStartTimeTravel := BlElement new
		                         background: Color white;
		                         geometry:
			                         (BlRoundedRectangleGeometry cornerRadius:
					                          2);
		                         padding: (BlInsets
				                          top: 8
				                          right: 16
				                          bottom: 8
				                          left: 16);
		                         layout: BlLinearLayout horizontal;
		                         effect: (BlGaussianShadowEffect
				                          color: (Color black alpha: 0.3)
				                          width: 1
				                          offset: 0 @ 2);
		                         constraintsDo: [ :c | 
			                         c horizontal fitContent.
			                         c vertical fitContent ];
		                         addEventHandler: (BlEventHandler
				                          on: BlClickEvent
				                          do: [ :anEvent | 
					                          buttonStartTimeTravel isVisible 
						                          ifTrue: [ self startTimeTravel ].
					                          anEvent consumed: true ]).
	labelText := 'Start time travel' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonStartTimeTravel addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		buttonStartTimeTravel relocate: timeTravelPanel size x / 10 @ 80 ].
	timeTravelPanel addChild: buttonStartTimeTravel.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding the Stop time trave button"
	buttonStopTimeTravel := BlElement new
		                        background: Color white;
		                        geometry:
			                        (BlRoundedRectangleGeometry cornerRadius: 2);
		                        padding: (BlInsets
				                         top: 8
				                         right: 16
				                         bottom: 8
				                         left: 16);
		                        layout: BlLinearLayout horizontal;
		                        effect: (BlGaussianShadowEffect
				                         color: (Color black alpha: 0.3)
				                         width: 1
				                         offset: 0 @ 2);
		                        constraintsDo: [ :c | 
			                        c horizontal fitContent.
			                        c vertical fitContent ];
		                        addEventHandler: (BlEventHandler
				                         on: BlClickEvent
				                         do: [ :anEvent | 
					                         buttonStopTimeTravel isVisible ifTrue: [ 
							                         self stopTimeTravel ].
					                         anEvent consumed: true ]).
	labelText := 'Stop time travel' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonStopTimeTravel addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		buttonStopTimeTravel relocate: timeTravelPanel size x / 10 * 3 @ 80 ].
	timeTravelPanel addChild: buttonStopTimeTravel.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding One Step before button"
	buttonOneStepBefore := BlElement new
		                       background: Color white;
		                       geometry:
			                       (BlRoundedRectangleGeometry cornerRadius: 2);
		                       padding: (BlInsets
				                        top: 8
				                        right: 16
				                        bottom: 8
				                        left: 16);
		                       layout: BlLinearLayout horizontal;
		                       effect: (BlGaussianShadowEffect
				                        color: (Color black alpha: 0.3)
				                        width: 1
				                        offset: 0 @ 2);
		                       constraintsDo: [ :c | 
			                       c horizontal fitContent.
			                       c vertical fitContent ];
		                       addEventHandler: (BlEventHandler
				                        on: BlClickEvent
				                        do: [ :anEvent | 
					                        buttonOneStepBefore isVisible ifTrue: [ 
							                        self restoreOneStepBefore ].
					                        anEvent consumed: true ]).
	labelText := 'One step before' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonOneStepBefore addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		buttonOneStepBefore relocate: timeTravelPanel size x / 10 * 5 @ 80 ].
	timeTravelPanel addChild: buttonOneStepBefore.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding One Step after button"
	buttonOneStepAfter := BlElement new
		                      background: Color white;
		                      geometry:
			                      (BlRoundedRectangleGeometry cornerRadius: 2);
		                      padding: (BlInsets
				                       top: 8
				                       right: 16
				                       bottom: 8
				                       left: 16);
		                      layout: BlLinearLayout horizontal;
		                      effect: (BlGaussianShadowEffect
				                       color: (Color black alpha: 0.3)
				                       width: 1
				                       offset: 0 @ 2);
		                      constraintsDo: [ :c | 
			                      c horizontal fitContent.
			                      c vertical fitContent ];
		                      addEventHandler: (BlEventHandler
				                       on: BlClickEvent
				                       do: [ :anEvent | 
					                       buttonOneStepAfter isVisible ifTrue: [ 
							                       self restoreOneStepAfter ].
					                       anEvent consumed: true ]).
	labelText := 'One step after' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonOneStepAfter addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		buttonOneStepAfter relocate: timeTravelPanel size x / 10 * 7 @ 80 ].
	timeTravelPanel addChild: buttonOneStepAfter.


	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding playing backward button"
	buttonPlayBackward := BlElement new
		                      background: Color white;
		                      geometry:
			                      (BlRoundedRectangleGeometry cornerRadius: 2);
		                      padding: (BlInsets
				                       top: 8
				                       right: 16
				                       bottom: 8
				                       left: 16);
		                      layout: BlLinearLayout horizontal;
		                      effect: (BlGaussianShadowEffect
				                       color: (Color black alpha: 0.3)
				                       width: 1
				                       offset: 0 @ 2);
		                      constraintsDo: [ :c | 
			                      c horizontal fitContent.
			                      c vertical fitContent ];
		                      addEventHandler: (BlEventHandler
				                       on: BlClickEvent
				                       do: [ :anEvent | 
					                       buttonPlayBackward isVisible ifTrue: [ 
							                       self playBackward ].
					                       anEvent consumed: true ]).
	labelText := 'Play Backward' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonPlayBackward addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
		buttonPlayBackward relocate: timeTravelPanel size x / 10 * 3 @ 130 ].
	timeTravelPanel addChild: buttonPlayBackward.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding replay button"
	buttonReplay := BlElement new
		                background: Color white;
		                geometry:
			                (BlRoundedRectangleGeometry cornerRadius: 2);
		                padding: (BlInsets
				                 top: 8
				                 right: 16
				                 bottom: 8
				                 left: 16);
		                layout: BlLinearLayout horizontal;
		                effect: (BlGaussianShadowEffect
				                 color: (Color black alpha: 0.3)
				                 width: 1
				                 offset: 0 @ 2);
		                constraintsDo: [ :c | 
			                c horizontal fitContent.
			                c vertical fitContent ];
		                addEventHandler: (BlEventHandler
				                 on: BlClickEvent
				                 do: [ :anEvent | 
					                 buttonReplay isVisible ifTrue: [ self replay ].
					                 anEvent consumed: true ]).
	labelText := 'Relay' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonReplay addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ buttonReplay relocate: timeTravelPanel size x / 10 * 5 @ 130 ].
	timeTravelPanel addChild: buttonReplay.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Stop button"
	buttonStop := BlElement new
		              background: Color red;
		              geometry: (BlRoundedRectangleGeometry cornerRadius: 2);
		              padding: (BlInsets
				               top: 8
				               right: 16
				               bottom: 8
				               left: 16);
		              layout: BlLinearLayout horizontal;
		              effect: (BlGaussianShadowEffect
				               color: (Color black alpha: 0.3)
				               width: 1
				               offset: 0 @ 2);
		              constraintsDo: [ :c | 
			              c horizontal fitContent.
			              c vertical fitContent ];
		              addEventHandler: (BlEventHandler
				               on: BlClickEvent
				               do: [ :anEvent | 
					               buttonStop isVisible ifTrue: [ 
							               self stopTimeTravel.
							               self class stop: self componentName ].
					               anEvent consumed: true ]).
	labelText := 'Stop' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	buttonStop addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
			buttonStop relocate:
				timeTravelPanel size x - buttonStop size x - 5 @ 5 ].
	timeTravelPanel addChild: buttonStop.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"White space"

	logsView := BlElement new
		            background: Color white;
		            relocate: 5 @ 200.
	labelText := '...' asRopedText.
	logsText := BlTextElement new
		         text: labelText;
		         relocate: 5 @ 5.
	logsView addChild: logsText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
			logsView size:
				timeTravelPanel size x - 10 @ (timeTravelPanel size y - 205) ].
	mySpace addChild: logsView.


	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	self startTimeTravelPanelLoop
]

{ #category : #services }
MolTimeTravel >> creationOf: aComponent [

	| aComponentMemento |
	aComponentMemento := MolComponentCreationMemento new save: aComponent.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].

	(history at: currentStep) saveCreationOrDeletionOf: aComponentMemento.

	self saveTheApplication
]

{ #category : #services }
MolTimeTravel >> deletionOf: aComponent [

	| aComponentMemento |
	aComponentMemento := MolComponentDeletionMemento new save: aComponent.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].
	
	(history at: currentStep) saveCreationOrDeletionOf: aComponentMemento.

	self saveTheApplication
]

{ #category : #'component accessing' }
MolTimeTravel >> getTimeTravelEventsNotifier [
	^self eventsNotifiers at: TimeTravelEvents ifAbsent: [^MolNotFoundEventsNotifier new interface: TimeTravelEvents name: nil].
]

{ #category : #testing }
MolTimeTravel >> isOnTheFirstStep [

	^ currentStep = 1
]

{ #category : #testing }
MolTimeTravel >> isOnTheLastStep [

	^ currentStep = lastStep 
]

{ #category : #services }
MolTimeTravel >> isRestoring [

	^ isRestoring
]

{ #category : #services }
MolTimeTravel >> nextStep [

	currentStep := currentStep + 1.
	lastStep := lastStep + 1.
	history add: MolComponentStep new
]

{ #category : #'life cycle' }
MolTimeTravel >> playBackward [

	isRestoring ifFalse: [ ^ self ].
	isReplaying ifTrue: [ ^ self ].

	isPlayingBackward
		ifTrue: [ 
			isPlayingBackward := false.
			timeTravelLoop ifNil: [ ^ self ].
			timeTravelLoop terminate.
			timeTravelLoop := nil ]
		ifFalse: [ 
			isPlayingBackward := true.
			timeTravelLoop := [ 
			                  [ currentStep > 1 ] whileTrue: [ 
				                  self restoreOneStepBefore.
				                  (Delay forMilliseconds: 1) wait ].
			                  isPlayingBackward := false.
			                  timeTravelLoop ifNil: [ ^ self ].
			                  timeTravelLoop terminate.
			                  timeTravelLoop := nil ] newProcess priority:
				                  Processor userBackgroundPriority.
			timeTravelLoop name: 'Molecule TimeTravelLoop Process'.
			timeTravelLoop resume ]
]

{ #category : #'life cycle' }
MolTimeTravel >> replay [

	isRestoring ifFalse: [ ^ self ].
	isPlayingBackward ifTrue: [ ^ self ].

	isReplaying
		ifTrue: [ 
			isReplaying := false.
			timeTravelLoop ifNil: [ ^ self ].
			timeTravelLoop terminate.
			timeTravelLoop := nil ]
		ifFalse: [ 
			isReplaying := true.
			timeTravelLoop := [ 
			                  [ currentStep < lastStep ] whileTrue: [ 
				                  self restoreOneStepAfter.
				                  (Delay forMilliseconds: 1) wait ].
			                  isReplaying := false.
			                  timeTravelLoop ifNil: [ ^ self ].
			                  timeTravelLoop terminate.
			                  timeTravelLoop := nil ] newProcess priority:
				                  Processor userBackgroundPriority.
			timeTravelLoop name: 'Molecule TimeTravelLoop Process'.
			timeTravelLoop resume ]
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreAtStep: aStep [

	| componentsLifeCycles mementos events |
	isRestoring ifFalse: [ ^ self ].

	currentStep < 1 | (currentStep > lastStep) ifTrue: [ ^ self ].

	"Undo"
	aStep < currentStep ifTrue: [ "Remove or create components"
		componentsLifeCycles := (history at: (aStep + 1)) creationsAndDeletions.
		componentsLifeCycles do: [ :componentLifeCycle | 
			componentLifeCycle undo ].

		"Restoration of the state of components"
		mementos := (history at: aStep) mementos.
		mementos do: [ :memento | memento undo ].

		"events undo"
		events := (history at: aStep) events.
		events do: [ :event | event undo ] ].

	"Redo"
	currentStep < aStep ifTrue: [ "Remove or create components"
		componentsLifeCycles := (history at: aStep) creationsAndDeletions.
		componentsLifeCycles do: [ :componentLifeCycle | 
			componentLifeCycle redo ].

		"Restoration of the state of components"
		mementos := (history at: aStep) mementos.
		mementos do: [ :memento | memento redo ].

		"Replay the events"
		events := (history at: aStep) events.
		events do: [ :event | event redo ] ]
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreOneStepAfter [
 currentStep < lastStep  ifTrue: [ 
	self restoreAtStep: currentStep + 1.
	currentStep := currentStep + 1]
]

{ #category : #'life cycle' }
MolTimeTravel >> restoreOneStepBefore [
 currentStep > 1 ifTrue: [ 
	self restoreAtStep: currentStep - 1.
	currentStep := currentStep - 1]
]

{ #category : #services }
MolTimeTravel >> save: aComponentMemento [

	((history at: currentStep) stepAlreadyContains: aComponentMemento) 
		ifTrue: [ self nextStep ].

	(history at: currentStep) save: aComponentMemento
]

{ #category : #services }
MolTimeTravel >> saveEvent: aMethodName performBy: aComponent withParameters: someParameters [

	| aComponentMemento |
	aComponentMemento := MolComponentEventMemento new
		                     saveEvent: aMethodName
		                     performBy: aComponent
		                     withParameters: someParameters.

	(history at: currentStep) isANewStep ifFalse: [ self nextStep ].

	(history at: currentStep) saveEvent: aComponentMemento.

	self saveTheApplication
]

{ #category : #services }
MolTimeTravel >> saveTheApplication [

	self getTimeTravelEventsNotifier saveForTimeTravel.

	self nextStep
]

{ #category : #'life cycle' }
MolTimeTravel >> startTimeTravel [

	isRestoring ifFalse: [ 
		isSaving := false.
		isRestoring := true.
		self getTimeTravelEventsNotifier startTimeTravel ]
]

{ #category : #'life cycle' }
MolTimeTravel >> startTimeTravelPanelLoop [

	"Starting the time travel panel's view loop."

	panelLoop := [ 
	             [ true ] whileTrue: [ 
		             self updatePanelView.
		             (Delay forMilliseconds:
			              MASimulationManager simulationStepDurationInMs) wait ] ] 
		             forkAt: Processor userBackgroundPriority.
	panelLoop name: 'Molecule ViewLoop Process'.
	panelLoop resume
]

{ #category : #'life cycle' }
MolTimeTravel >> stopTimeTravel [

	isRestoring ifTrue: [ 
		isPlayingBackward ifFalse: [ 
			isReplaying ifFalse: [ 
				isReplaying := true.
				[ currentStep < lastStep ] whileTrue: [ 
					self restoreOneStepAfter  ].
				isReplaying := false.
				isSaving := true.
				isRestoring := false.
				self getTimeTravelEventsNotifier stopTimeTravel ] ] ]
]

{ #category : #'life cycle' }
MolTimeTravel >> stopTimeTravelPanelLoop [

	"Stoping the time travel panel's view loop."


	panelLoop ifNil: [ ^ self ].
	panelLoop terminate.
	panelLoop := nil
]

{ #category : #'life cycle' }
MolTimeTravel >> updatePanelView [

	"Modify each elements of the time travel panel. It permit to keep the view up to date with the simulation."

	| blRopedText memSize creaSize eventSize stringTemp |
	lastStepView text: lastStep asRopedText.
	currentStepView text: currentStep asRopedText.

	isRestoring
		ifTrue: [ 
			buttonStartTimeTravel background: Color gray.
			buttonStopTimeTravel background: Color white.
			buttonOneStepBefore background: Color white.
			buttonOneStepAfter background: Color white.
			buttonPlayBackward background: Color white.
			buttonReplay background: Color white.
			isPlayingBackward ifTrue: [ 
				buttonStopTimeTravel background: Color gray.
				buttonOneStepBefore background: Color gray.
				buttonOneStepAfter background: Color gray.
				buttonReplay background: Color gray ].
			isReplaying ifTrue: [ 
				buttonStopTimeTravel background: Color gray.
				buttonOneStepBefore background: Color gray.
				buttonOneStepAfter background: Color gray.
				buttonPlayBackward background: Color gray ].
			self isOnTheFirstStep ifTrue: [ 
				buttonOneStepBefore background: Color gray.
				buttonPlayBackward background: Color gray ].
			self isOnTheLastStep ifTrue: [ 
				buttonOneStepAfter background: Color gray.
				buttonReplay background: Color gray ] ]
		ifFalse: [ 
			buttonStartTimeTravel background: Color white.
			buttonStopTimeTravel background: Color gray.
			buttonOneStepBefore background: Color gray.
			buttonOneStepAfter background: Color gray.
			buttonPlayBackward background: Color gray.
			buttonReplay background: Color gray ].

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	isSaving
		ifTrue: [ logsText text: 'Is Saving ...' asRopedText ]
		ifFalse: [ 
			stringTemp := ''.
			(history at: currentStep) mementos do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			memSize := ' Mementos: '
			           , (history at: currentStep) mementos size asString
			           , ' [ ' , stringTemp , '] '.

			stringTemp := ''.
			(history at: currentStep) creationsAndDeletions do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			creaSize := ' CreationsOrDeletions: '
			            ,
			            (history at: currentStep) creationsAndDeletions size
				            asString , ' [ ' , stringTemp , '] '.

			stringTemp := ''.
			(history at: currentStep) events do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			eventSize := ' Events '
			             , (history at: currentStep) events size asString
			             , ' [ ' , stringTemp , '] '.

			blRopedText := BlRopedText string: memSize , creaSize , eventSize.

			logsText text: blRopedText ]
]
