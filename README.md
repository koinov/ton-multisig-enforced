# Problematic

Original multisig-code.fc allows malefactor to drain funds out of the wallet by submitting multiple order messages to smart contract. 

# Solution

Prevent accepting new request message until pre-defined number of signatures are collected offline and built into new request signed by root signature.  

# Step-by-step

## Generate Key pair for your signature ID. 

```
fift -s generate-key.fif <signature-index> [<wallet-name>]


<signaure-index> index on the signature in range 1 to N
<wallet-name> the file name for the wallet
```
### Output
```
<wallet-name>.pub<signature-index>
<wallet-name>.pk<signature-index>
```

### Example:
```
fift -s generate-key.fif 1 new
```

Generates new.pk1 and new.pub1 
new.pub1 is a public key that is shared and used for creating initial state for the wallet


## Deploying multi-wallet smart contract

When all N pub keys are collected one of the parties generates bag of cells containing the code and 
initial state for the multi-wallet contract.

```
fift -s multi-wallet.fif <workchain> <k> <n> <min_k> [<wallet-name>]

<workchain> - workchain id
<k> - number of signatures enough to confirm and perform transaction request
<n> - total number of signatures. <wallet-name>.pub1 ... .pubn files must be located in the same folder
<min-k> - minimum amount of signatures required to submit new order
<wallet-name> the file name for the wallet
```

### Requirements : 
```
multi-wallet-code.fif  
<wallet-name>.pub<1..n>
```

### Output
```
<wallet-name>-init.boc
```

### Example:
```
fift -s multi-wallet.fif 0 10 16 3 new
```

Shows bounceable and Non-bounceable address. Some Grams shouls be transferred to bouncable address to deploy the contract.
It also displays hexadecimal string with the content of initial transaction. 
Generates new.addr - address of the wallet, new-init.boc - bag of cells containing code and initial state for the wallet. 
Content of this file or hexadecimal message mentionel above should be sent to TON blockchain to deploy initialized smart contract. 

## Making request
Any of parties create request 

```
fift -s multi-wallet-request.fif <wallet-name> <dest-addr> <seqno> <amount> <validity> [-B <body-boc>]
<wallet-name> - name of the wallet
<dest-addr> - destination address
<seqno> - internal current seqno, used for faster access, not sent to smart contract
<amount> - amount of grams to sending
<validity> - period in seconds since the moment the request was created
<body-boc> - file with the body of the message to be sent or string
```

### Requirements
``` 
None
```

### Output
```
<wallet-name>.req<seqno> file containing request message. This file must be shared between parties. 
```

### Example 
```
fift -s multi-wallet-request.fif new EQB9w2tPnNCm4cXmlY98+haK3ProhZ4kQLiQGSRCZbTbn3hP 1 11.5 6000 -B TestMe
```
### Output
```
new.req1 
```


## Signing request
At least K parties should sign request. 

```
fift -s sign-request.fif <signature-index> <seq-no> [<wallet-name>]
<signature-index> - signature index of participants
<seq-no> - internal seqno
<wallet-name> - name of the wallet
```

### Output
```
<wallet-name>.req<seqno>.sign<signature-index> file that contains signature for the request. This file should be shared to build transaction 
```

### Requirements : 
```
<wallet-name>.req<seq-no>
<wallet-name>.pk<signature-index>
```

### Example
```
fift -s sign-request.fif 1 1 new
```
### Output
``` 
new.req1.sign1
```

## Building bag of cells containing request and broadcasting the transaction 

When K signature files are collected now it is time to build request and execute transaction.

```
fift -s multi-wallet-build.fif <seqno> <n> <signature-index> [<wallet-name>]

<seq-no> - sequence number of transaction 
<n> - total number of signatures possible. The same n as used for creating the wallet. 
<signature-index> - index of the signature used as root signature
<wallet-name> - name of the wallet
```

### Requirements: 
```
<wallet-name>.req<seqno> k number of <wallet-name>.req<seqno>.sign<1..n> request files, <wallet-name>.pk<signanture-index> 
```

### Output:
``` 
<wallet-name>.req<seq-no>.boc
```

### Example 
```
fift -s multi-wallet-build.fif 1 3 2 new 
```
Iterates over available signature files new.req1.sign<1..3> and creates new.req1.boc containing bag of cells for request. 
If less than 2 are found, request file will be created anyway but transaction will not be validated, request is signed by signature 2.
