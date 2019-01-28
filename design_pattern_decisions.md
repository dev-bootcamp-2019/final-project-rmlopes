# Design Patterns Decisions

### Restricting Access

Access is controlled to the administration features of the contracts using zeppelin's Ownable. Direct read access to TDBay state by other contracts has also been restricted by using private variables. Modifiers were implemented also to restrict the modifications of the Projects and Designs only by the respective creators. Functions in the design contract that are only to be called from the TDBay contract also have restricted access using an appropriate modifier that only allows to be called from the TDBayContract.


### Locked money

A withdraw function is available (restricted to owner) in order to avoid locked funds for both contracts.

### State Machine

Projects and Designs have different stages (for instance, first only design bids are allowed in a project, once a design bid is accepted it no longer accepts bids; a designer can only update the project -CAD- files after the bid has been accepted, etc). Enums for the states and function modifiers were implemented to model the states and guard against incorrect usage of the contracts.

### Upgradability

The TDBay and Design contracts interact using interfaces (ITDBay and IDesign) in order to provide some upgradability.

### Type safety

The Design contract uses the ITDBay interface type instead of the built-in type address.






