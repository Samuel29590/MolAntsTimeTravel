# MolAntsTimeTravel

This is the experimental version of [MolAnts](https://github.com/Samuel29590/MolAnts) for time-traveling.
This repository aims to help the search in Time-Traveling debugging techniques with component oriented programming.

## Getting Started

### Prerequisites

MolAntsTimeTravel require [Molecule](https://github.com/OpenSmock/Molecule) for the component aspect and [Bloc](https://github.com/pharo-graphics/Bloc) for the visual aspect.
So this is why this two frameworks are loaded with the baseline of MolAntsTimeTravel.

### Installing MolAntsTimeTravel

```smalltalk
Metacello new
        baseline: 'MolTimeTravel';
        repository: 'github://Samuel29590/MolTimeTravel';
        load.
```

## Documentation

MolAntsTimeTravel like [MolAnts](https://github.com/Samuel29590/MolAnts) is a simulation of an anthill. The folder *MolAntsExperimental* is a lighter implementation of the anthill, it was created to test quickly the time travel component. The folder *MolAnts* the time travel has been added to the original simulation with all the features of the anthill. In this two folder the component *TimeTravel* is the same and it adds the possibility of returning in the past, and replay the simulation step-by-step.

If you want to know more about the organization of components of [MolAnts](https://github.com/Samuel29590/MolAntsTimeTravel/blob/main/MolAnts.md) or [MolAntExperimental](https://github.com/Samuel29590/MolAntsTimeTravel/blob/main/MolAntsExperimental.md), click on the hyperlink.

<br>

**⚠️** The following explanations are adapted for the *MolAntsTimeTravel* version, the full version of the anthill with TimeTravel. If you want specific explanations for *MolAntsExperimental*, the lighter anthill implementation with TimeTravel, you can find them here : [MolAntExperimental](https://github.com/Samuel29590/MolAntsTimeTravel/blob/main/MolAntsExperimental.md).

<br>

### How to start the simulation ?

To start the simulation, go to the *MolAnts* package, on the class side of the MASimulationManager class and launch the start method.

![Screenshot from 2022-07-07 14-48-12](https://user-images.githubusercontent.com/64481702/177777229-fa0a1e0e-b613-44bf-b083-ac8aeafb1914.png)

When the simulation is launched, three windows are opened:

1- Is the simulation.

2- Is the time travel panel.

3- Is an inspector on *MolComponentManager* and it allows to inspect each component of the simulation and their data.

![draw(2)](https://user-images.githubusercontent.com/64481702/178457974-c9afbe47-023f-48c3-868b-82fe07949b91.png)

### How is the data recorded with the *TimeTravel* component ?

Data of the simulation are recorded following the [Momento Pattern](https://en.wikipedia.org/wiki/Memento_pattern), this application as been adapted to fit with components. 

Memento is a way of backing up components by backing up only the information that is needed to be able to restore it later. With this method we do not save the components but only their data.

![TimeTravel_DataStorage](https://user-images.githubusercontent.com/64481702/176431453-dc1fa4e8-c242-49e6-b301-d262936b8744.png)

This is the component *TimeTravel* that store the history of the simulation, in the variable *history*. This variable is an ordered collection of *MAComponentStep*. Each index of this collection represent the simulation state at one step (E.g. index 1 represent the state at step 0, index 2 represent the state at step 1, ...).

*MAComponentStep* is an object that aims to store the state of the simulation at one step. It has two variables, one to store data of components: *mementos*, and one to store creation or deletion of components: *creationsAndDeletions*. This two variables are ordered collections of *MAComponentMemento*'subclasses.

![MomentosOrganization drawio](https://user-images.githubusercontent.com/64481702/177515528-54842cc5-8aac-43e9-bcb5-112513b9003c.png)

So when a component is created or deleted from the simulation, the component create a *MAComponentCreationMemento* instance or a *MAComponentDeletionMemento* instance, and notify the component *TimeTravel* to store it. Then the component *TimeTravel* will look on the history to know if the step as already been created, if not it will create the *MAComponentsStep* associate to the step, and add it to the *history* collection. After that it will store the *MAComponentCreationMemento* instance or the *MAComponentDeletionMemento* instance on the variable *creationsAndDeletions* of the *MAComponentsStep*. From there, the creation or deletion has been saved.

For saving components state the process is different. The simulation manager in the execution loop send an event to all components of the simulation to do their action. When it's done the simulation manager call a service provided by the *TimeTravel* component : *saveTheSimulationAt: aStep*. This service will send an event (*saveForTimeTravel: aStep*) to all the components of the simulation to save their state at *aStep*. Each component of the simulation has its own version of *saveForTimeTravel: aStep* but they all has the same behavior. The component will create a memento and use the service : *save: aComponentMemento at: aStep*, provided by the *TimeTravel* component, to store the memento. The process to store them is almost the same as *creationsAndDeletions*, the component *TimeTravel* receive the notification to save the memento and look in the history to know if the step as already been created. After that it will store the *MAComponentMemento* on the variable *mementos*  of the *MAComponentsStep* associate to the step where the *MAComponentMemento* has been created. From there, the state of the component has been saved through its memento.

The component *SimulationManager* will create a *MASimulationMemento*, the component *insect* will create a *MAInsectMemento*, the component *pheromones* will create a *MPheromonesMemento*, the component *feedingPoint* will create a *MAFeedingPointMemento*, the component *ant* will create a *MAAntMemento*, the component *stage* will create a *MAStageMemento*, the component *queen* will create a *MAQueenMemento*, the component *fighter* will create a *MAFighterMemento*, the component *worker* will create a *MAWorkerMemento*. All these mementos are all subclasses of *MAComponentMemento*.

#### How to save reference of a component

For saving objects that are instances of component the process is a little different. Saving the reference of the instance isn't a good idea because components can be created or removed during the simulation, so the instances saved will refer to old component instances. The solution to solve this problem is quite simple, with [Molecule](https://github.com/OpenSmock/Molecule), component names are unique for each component types. It means that two different component with different type can have the same name, but two components with the same type can't have the same name. Thanks to this feature, a solution to solve the problem of saving component instances is to save the component class and the component name instead of the reference. From there if the component instance is stopped and restarted we don't have the problem of an incorrect instance. The process to restore the correct instance is simple, using *MolUtils* (a feature of [Molecule](https://github.com/OpenSmock/Molecule)), we are able to retrieve any component instance by specifying the component class and component name (*instanceOf: aClass named: aName*).

<br>

![collection_save](https://user-images.githubusercontent.com/64481702/175542288-49e089d1-a23c-4a98-8149-05f1ffc95e82.png)

<br>

### How is the data restored ?

The process to restore data is quite simple. The component *TimeTravel* examine the history that was saved, step-by-step, during the execution and restore the data by updating all the other components directly. The component *TimeTravel* also restore or remove components that appear or disappear during the simulation. With this two feature it's possible to play backward the simulation and to replay it step-by-step.

#### Creation and deletion of components

During undo, components created and deleted during the simulation are also undo. When we go back, the creations (*MAComponentCreationMemento*) are replayed as a deletion, and the deletions (*MAComponentDeletionMemento*) are replayed as a creation. With this behavior, when we go back we have the same components present in the simulation.

The specificity for creation and deletion during undo is that they are interpreted with a shift step. For example if we undo the step X , we will replay the creation and deletion of the step X+1. This specificity is necessary because if we interpret creation and deletion of the same step, we will create components that were not present during execution and delete components that were present during execution.
<br>*If you want to know more about this specificity click here : [undoProblem](https://github.com/Samuel29590/MolAntsTimeTravel/blob/main/undoProblem.md).*

![undo](https://user-images.githubusercontent.com/64481702/176385748-186ad58b-ef82-4dfc-a226-33aaefacfe90.png)

<br>
In the case of redo, it's simpler, creations and deletions are replayed as they were recorded. A creation (*MAComponentCreationMemento*) is replayed as a creation, and a deletion (*MAComponentDeletionMemento*) is replayed as a deletion.

And in redo on the contrary with undo we interpret the creations and deletions of the same step which is restored (For example if we redo step X , we will replay the creation and deletion of step X).

![redo](https://user-images.githubusercontent.com/64481702/176385734-b2bc4b42-5df8-4f17-8deb-1dd444c43bfc.png)

#### Values of components

When we time travel on the simulation, the *TimeTravel* component will execute the *undo* or *redo* methods of the mementos at each restored step. These methods will tell the mementos to restore the variables of their associated component, using the *restorFrom: aMemento* method present in the components. The components receive the mementos and restore their variables using the values saved on the mementos.

#### Example of an undo and a restoration from a memento (example non exhaustive)

![RestoreDataSchema](https://user-images.githubusercontent.com/64481702/177521067-61e1f0ad-5454-4f1e-a0cc-2d5e12de7874.png)

<br><br><br>

### How is the Time Travel implemented ?

If you want to know how time travel is implemented in the simulation and what are the steps to follow to make it go, see this document: [9 steps to implement TimeTravel in MolAnts](https://github.com/Samuel29590/MolAntsTimeTravel/blob/master/ImplementationOfTimeTravel.md)
<br><br><br>

## Illustrations
![2022-07-04 14-31-40](https://user-images.githubusercontent.com/64481702/177515569-c6d831f3-37b2-4d56-8a6c-50dcd4202a7f.gif)

<img src="https://user-images.githubusercontent.com/64481702/178459438-4a5fa818-551f-4784-9dfc-c9f6e39e3365.png" width="50%"><img src="https://user-images.githubusercontent.com/64481702/178459444-17020844-17b0-4cec-9e29-6fc8d2d2d57f.png" width="50%">

<img src="https://user-images.githubusercontent.com/64481702/178459447-f7c8b35d-2658-4264-99df-0f14a9d7e4a9.png" width="50%"><img src="https://user-images.githubusercontent.com/64481702/178459449-e2bceebc-c3d1-485f-a375-566183e0bdf2.png" width="50%">
