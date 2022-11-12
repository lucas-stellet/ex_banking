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

## ExCoveralls test coverage

``````
COV    FILE                                        LINES RELEVANT   MISSED
100.0% lib/ex_banking.ex                             308       40        0
100.0% lib/ex_banking/application.ex                  18        3        0
100.0% lib/ex_banking/core.ex                         85       17        0
100.0% lib/ex_banking/core/account.ex                 27        3        0
100.0% lib/ex_banking/core/wallet.ex                  52        7        0
100.0% lib/ex_banking/operations.ex                   54       12        0
100.0% lib/ex_banking/operations/balance.ex           31        3        0
100.0% lib/ex_banking/operations/deposit.ex           35        4        0
100.0% lib/ex_banking/operations/transfer.ex          37        4        0
100.0% lib/ex_banking/operations/withdraw.ex          35        4        0
100.0% lib/ex_banking/services.ex                    109       21        0
100.0% lib/ex_banking/services/account_cashbook       52        7        0
100.0% lib/ex_banking/services/account_creator.       27        1        0
100.0% lib/ex_banking/services/account_operatio       72       15        0
100.0% lib/ex_banking/services/account_server.e      106       21        0
100.0% lib/ex_banking/services/account_supervis       27        5        0
[TOTAL] 100.0%

``````

