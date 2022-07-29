Class {
	#name : #MolTimeTravelView,
	#superclass : #Object,
	#instVars : [
		'timeTravel',
		'mySpace',
		'timeTravelPanel',
		'panelLoop',
		'inspector',
		'currentStepView',
		'buttonStartTimeTravel',
		'buttonStopTimeTravel',
		'buttonOneStepBefore',
		'buttonOneStepAfter',
		'buttonPlayBackward',
		'buttonReplay',
		'currentStepText',
		'buttonStop',
		'lastStepText',
		'lastStepView',
		'logsView',
		'logsText',
		'button0',
		'button1',
		'button5',
		'button10',
		'button20',
		'button50',
		'button100',
		'replaySpeedText',
		'inMsText',
		'isRunning'
	],
	#category : #MolTimeTravel
}

{ #category : #'life cycle' }
MolTimeTravelView >> createTimeTravelPanel [

	| labelText label |
	inspector := MolComponentManager default homeServices
		             deployedComponents inspect.

	mySpace := BlSpace new
		           extent: 800 @ 350;
		           title: 'TimeTravel Panel'.
		mySpace show.

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
						                          ifTrue: [ timeTravel startTimeTravel ].
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
							                         timeTravel stopTimeTravel ].
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
							                        timeTravel restoreOneStepBefore ].
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
							                       timeTravel restoreOneStepAfter ].
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
							                       timeTravel playBackward ].
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
					                 buttonReplay isVisible ifTrue: [ 
							                 timeTravel replay ].
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
							               self stopTimeTravelPanelLoop.
							               timeTravel stopTimeTravel.
							               timeTravel class stop: timeTravel componentName ].
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
	"Adding Replay Speed : to the panel."
	replaySpeedText := BlTextElement new
		                   background: Color transparent;
		                   text: 'Replay Speed :' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ replaySpeedText relocate: timeTravelPanel size x / 20 @ 190 ].
	timeTravelPanel addChild: replaySpeedText.

	"---------------------------------------------	-----------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 0"
	button0 := BlElement new
		           background: Color white;
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
					            button0 isVisible ifTrue: [ 
							            timeTravel replaySpeed: 0 ].
					            anEvent consumed: true ]).
	labelText := '0' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button0 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button0 relocate: timeTravelPanel size x / 10 * 2 @ 180 ].
	timeTravelPanel addChild: button0.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 1"
	button1 := BlElement new
		           background: Color white;
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
					            button1 isVisible ifTrue: [ 
							            timeTravel replaySpeed: 1 ].
					            anEvent consumed: true ]).
	labelText := '1' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button1 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button1 relocate: timeTravelPanel size x / 10 * 3 @ 180 ].
	timeTravelPanel addChild: button1.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 5"
	button5 := BlElement new
		           background: Color white;
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
					            button5 isVisible ifTrue: [ 
							            timeTravel replaySpeed: 5 ].
					            anEvent consumed: true ]).
	labelText := '5' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button5 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button5 relocate: timeTravelPanel size x / 10 * 4 @ 180 ].
	timeTravelPanel addChild: button5.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 10"
	button10 := BlElement new
		            background: Color white;
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
					             button10 isVisible ifTrue: [ 
							             timeTravel replaySpeed: 10 ].
					             anEvent consumed: true ]).
	labelText := '10' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button10 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button10 relocate: timeTravelPanel size x / 10 * 5 @ 180 ].
	timeTravelPanel addChild: button10.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 20"
	button20 := BlElement new
		            background: Color white;
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
					             button20 isVisible ifTrue: [ 
							             timeTravel replaySpeed: 20 ].
					             anEvent consumed: true ]).
	labelText := '20' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button20 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button20 relocate: timeTravelPanel size x / 10 * 6 @ 180 ].
	timeTravelPanel addChild: button20.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 50"
	button50 := BlElement new
		            background: Color white;
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
					             button50 isVisible ifTrue: [ 
							             timeTravel replaySpeed: 50 ].
					             anEvent consumed: true ]).
	labelText := '50' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button50 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button50 relocate: timeTravelPanel size x / 10 * 7 @ 180 ].
	timeTravelPanel addChild: button50.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding button 100"
	button100 := BlElement new
		             background: Color white;
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
					              button100 isVisible ifTrue: [ 
							              timeTravel replaySpeed: 100 ].
					              anEvent consumed: true ]).
	labelText := '100' asRopedText.
	label := BlTextElement new.
	label text: labelText.
	button100 addChild: label.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ button100 relocate: timeTravelPanel size x / 10 * 8 @ 180 ].
	timeTravelPanel addChild: button100.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"Adding Replay Speed : to the panel."
	inMsText := BlTextElement new
		            background: Color transparent;
		            text: 'ms' asRopedText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ inMsText relocate: timeTravelPanel size x / 10 * 9 @ 190 ].
	timeTravelPanel addChild: inMsText.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"White space"
	logsView := BlElement new
		            background: Color white;
		            relocate: 5 @ 250.
	labelText := '...' asRopedText.
	logsText := BlTextElement new
		            text: labelText;
		            relocate: 5 @ 5.
	logsView addChild: logsText.
	timeTravelPanel
		addEventHandlerOn: BlElementExtentChangedEvent
		do: [ 
			logsView size:
				timeTravelPanel size x - 10 @ (timeTravelPanel size y - 255) ].
	mySpace addChild: logsView.

	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	self startTimeTravelPanelLoop
]

{ #category : #initialization }
MolTimeTravelView >> setTimeTravel: aTimeTravelComponent [

	timeTravel := aTimeTravelComponent
]

{ #category : #'life cycle' }
MolTimeTravelView >> start [
	isRunning := true.
	self createTimeTravelPanel.
	self startTimeTravelPanelLoop
]

{ #category : #'life cycle' }
MolTimeTravelView >> startTimeTravelPanelLoop [

	"Starting the time travel panel's view loop."

	panelLoop := [ 
	             [ true ] whileTrue: [ 
		
	isRunning ifTrue:[
		             self updatePanelView.
		             (Delay forMilliseconds: 50) wait ] ]] forkAt:
		             Processor userBackgroundPriority.
	panelLoop name: 'Molecule ViewLoop Process'.
	panelLoop resume
]

{ #category : #'life cycle' }
MolTimeTravelView >> stop [

	isRunning := false.
	mySpace close.
	inspector close.

	self stopTimeTravelPanelLoop
]

{ #category : #initialization }
MolTimeTravelView >> stopTimeTravelPanelLoop [

	"Stoping the time travel panel's view loop."

	panelLoop ifNil: [ ^ self ].
	panelLoop terminate.
	panelLoop := nil
]

{ #category : #'life cycle' }
MolTimeTravelView >> updatePanelView [

	"Modify each elements of the time travel panel. It permit to keep the view up to date with the simulation."

	| blRopedText memSize creaSize eventSize stringTemp |
	lastStepView text: timeTravel lastStep asRopedText.
	currentStepView text: timeTravel currentStep asRopedText.

	timeTravel isRestoring
		ifTrue: [ 
			buttonStartTimeTravel background: Color gray.
			buttonStopTimeTravel background: Color white.
			buttonOneStepBefore background: Color white.
			buttonOneStepAfter background: Color white.
			buttonPlayBackward background: Color white.
			buttonReplay background: Color white.
			timeTravel isPlayingBackward ifTrue: [ 
				buttonStopTimeTravel background: Color gray.
				buttonOneStepBefore background: Color gray.
				buttonOneStepAfter background: Color gray.
				buttonReplay background: Color gray ].
			timeTravel isReplaying ifTrue: [ 
				buttonStopTimeTravel background: Color gray.
				buttonOneStepBefore background: Color gray.
				buttonOneStepAfter background: Color gray.
				buttonPlayBackward background: Color gray ].
			timeTravel isOnTheFirstStep ifTrue: [ 
				buttonOneStepBefore background: Color gray.
				buttonPlayBackward background: Color gray ].
			timeTravel isOnTheLastStep ifTrue: [ 
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
	button0 background: Color white.
	button1 background: Color white.
	button5 background: Color white.
	button10 background: Color white.
	button20 background: Color white.
	button50 background: Color white.
	button100 background: Color white.

	timeTravel replaySpeed = 0 ifTrue: [ button0 background: Color gray ].
	timeTravel replaySpeed = 1 ifTrue: [ button1 background: Color gray ].
	timeTravel replaySpeed = 5 ifTrue: [ button5 background: Color gray ].
	timeTravel replaySpeed = 10 ifTrue: [ 
		button10 background: Color gray ].
	timeTravel replaySpeed = 20 ifTrue: [ 
		button20 background: Color gray ].
	timeTravel replaySpeed = 50 ifTrue: [ 
		button50 background: Color gray ].
	timeTravel replaySpeed = 100 ifTrue: [ 
		button100 background: Color gray ].
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	"--------------------------------------------------------------------------------------------------------------------------"
	timeTravel isSaving
		ifTrue: [ logsText text: 'Is Saving ...' asRopedText ]
		ifFalse: [ 
			stringTemp := ''.
			(timeTravel history at: timeTravel currentStep) mementos do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			memSize := ' Mementos: '
			           ,
			           (timeTravel history at: timeTravel currentStep) mementos
				           size asString , ' [ ' , stringTemp , '] '.

			stringTemp := ''.
			(timeTravel history at: timeTravel currentStep)
				creationsAndDeletions do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			creaSize := ' CreationsOrDeletions: '
			            ,
				            (timeTravel history at: timeTravel currentStep)
					            creationsAndDeletions size asString , ' [ '
			            , stringTemp , '] '.

			stringTemp := ''.
			(timeTravel history at: timeTravel currentStep) events do: [ :x | 
				stringTemp := stringTemp
				              , x componentReference componentClass asString
				              , '->' , x componentReference componentName asString
				              , '. ' ].
			eventSize := ' Events '
			             ,
			             (timeTravel history at: timeTravel currentStep) events
				             size asString , ' [ ' , stringTemp , '] '.

			blRopedText := BlRopedText string: memSize , creaSize , eventSize.

			logsText text: blRopedText ]
]
