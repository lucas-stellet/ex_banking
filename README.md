# ExBanking

## Description

Is an application that allows users to create your accounts and multiple wallets.
Each wallet has your own currency.

The applications stands on `OTP behaviours`, creating a branch into the `Supervision`(process created by `Application`) with a `DynamicSupervisor`. It is responsible to create in runtime an `AccountSupervisor` that sequentially creates an `AccountServer` and `AccountOperations`, responsible for manage the account and wallets state and user operations.

That architecture and the `Supervisor` strategies makes the `ExBanking` fault tolerant. 

Furthermore, at each new upgrade of wallets, a cache is made in case of `AccountServer` is restarted. Which helps the process to keep the wallets always with due value.

## Architectural design

![Application Tree](/priv/ex_banking.png)

## How to use 

All docs are indicated on [ExBanking](/lib/ex_banking.ex) module.

