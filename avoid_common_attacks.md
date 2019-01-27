# Avoid Common Attacks

### Integer overflow and underflow

Openzepplein's SafeMath has been used where arithmetic operations are used in order to avoid over/underflow.

### Withdrawal pattern

The goal is to use the 3DB token (TDBayToken contract) for in app transfers/fees, which is implemented using the ERC20 standard from Openzeppelin that implements the withdrawal pattern. This is not implemented yet.