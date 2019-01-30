3DBay
=====

This project is a mix between a community marketplace and bounty platform. 3D Printing technologies are evolving fast, and becoming ever more common, while 3D printers prices are coming down. This dApp will enable anyone to start a project with as little as a text description of the 3D artifact they want to develop, and pictures of the object. Users with 3D modelling expertise (the designers) can bid in a project, provide a preview of their model, and deliver the artifact design/schematics for a given cost. Manufacturers (anyone with a 3D printer that meets the requirements of a project) can bid to provide and ship the physical artifact in a given quantity for a certain price.


## User Stories

The owner of the contracts opens the web app. There is an administration option in the navigation bar. In this dashboard he initializes the parameters  of 3DBay (costs, deployed design and token contracts, fees, etc). He can also initialize the Design contract witha  shortcut to the current 3DBay contract.

A curious user that is not the owner tries to enter the administration dashboard. Even though this is protected by the smart contracts, he is redirected to the first page of the app.

A user opens the web app. He starts a new project by going to the Projects section and adding the name, a text description, and a picture of the object he wants to 3D print. As the owner of that project he can modify the object image, and later accept a design bid. He can easily access the projects he created in the section "My Projects".

A user opens the web app with the goal of using his modelling skills. He can browse the existing projects that are searching for design bids, and submit a bid to existing projects in Designing stage. He can set his price, and improve his bid with a preview image of his design. If the bid is accepted, he creates the source files offline, and uploads them to the accepted bid. He can easily access his bids in the section "My Designs".

A user opens the web app to acquire an existing artifact. He browses through the existing projects, sees the details (without accessing the source files), and requests manufacture bids. (Not Implemented yet)

A user opens the web app with the goal of providing manufacturing services. He can browse the existing projects that are searching for manufacture bids, and submit a bid to existing projects. Upon acceptance of the bid, he produces on a given timeframe and ships the physical artifact. (Not Implemented yet)


# How to set it up

## Pre-requisites

1. Truffle

`npm install -g truffle`

2. Ganache or ganache-cli running on port `8545`

`npm install -g ganache-cli`

3. Angular is necessary for the client

`npm install -g @angular/cli`

## Run local

1. Clone the repository

`git clone "https://github.com/dev-bootcamp-2019/final-project-rmlopes"`

2. Go to the project root

`cd final-project-root`

3. Setup the client libraries to run locally, in the project directory:

`npm install`

4. Compile the smart contracts

`truffle compile`

5. Deploy the smart contracts to the local network

`truffle migrate`

6. Run the tests

`truffle test`

7. Start the local development server (will start in localhost:4200 by default)

`npm start`


# How to use it 

1. Open the app in the browser using Metamask (or a similar browser wallet) connected to the local ganache network. 

2. The default account that was used for migration will allow access to the administration dashboard. There, setup the parameters of the contract. Copy the deployed Design contract address and update the respective parameter. 

3. Setup the address of the 3DBay in the Design contract, using the shortcut button in the respective dashboard section, at the bottom of the page.

4. Create projects and switch account to place design bids (a user cannot place a design bid on his own project). Also, only the owner of the project will have access to all the design bids placed for that project.



