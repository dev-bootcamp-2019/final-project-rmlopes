import { Component, OnInit, Input, AfterContentChecked, AfterContentInit } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';
import {Web3Service} from '../../util/web3.service';
import { MatSnackBar } from '@angular/material';
import {DesignAdminComponent} from '../../design/design-admin/design-admin.component';

declare let require: any;
const tdbay_artifacts = require('../../../../build/contracts/TDBay.json');

@Component({
  selector: 'app-tdbay-admin',
  templateUrl: './tdbay-admin.component.html',
  styleUrls: ['./tdbay-admin.component.css']
})
export class TdbayAdminComponent implements OnInit, AfterContentInit {
  ngAfterContentInit(): void {
    this.checkOwner();
  }

  account: string;
  owner: string;
  TDBay: any;

  model = {
    projectCost: 0,
    designBidCost: 0,
    manufactureBidCost: 0,
    tokenContract: '',
    designContract: '',
    wallet: '',
    projectFee: 0,
    projectFeeRate: 0,
    projects: [],
    account: '',
    withdrawAmount: 0,
    balance: -1
  };

  status = '';

  constructor(private web3Service: Web3Service, 
              private matSnackBar: MatSnackBar,
              private route: ActivatedRoute,
              private router: Router,) {
    console.log('Constructor: ' + web3Service);
  }

  ngOnInit(): void {
    console.log('OnInit: ' + this.web3Service);
    this.web3Service.artifactsToContract(tdbay_artifacts)
      .then((TDBayAbstraction) => {
        this.TDBay = TDBayAbstraction;
        this.TDBay.deployed().then(deployed => {
          console.log(deployed);
          this.setOwner();
          this.refreshState();
          // deployed.Transfer({}, (err, ev) => {
          //   console.log('Transfer event came in, refreshing balance');
            
          // });
        });

      });
    //console.log(this);
    //this.checkOwner();
    this.watchAccount();
    this.watchBalance();
  }

  watchAccount() {
    this.web3Service.currentAccount.subscribe(current => {
        this.model.account = current;
        this.account = current;
        this.checkOwner();  
    });
  }

  watchBalance() {
    this.web3Service.curBalance.subscribe(current => {
      if(this.TDBay)
          this.model.balance = current[this.TDBay.address];  
    });
  }

  async setOwner(){
    console.log('Checking  owner');

    try {
      const deployedBay = await this.TDBay.deployed();
      console.log(deployedBay);
      const theowner = await deployedBay.owner.call();
      console.log("SETTING OWNER: "+theowner);
      this.owner = theowner;
      this.checkOwner();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting owner; see log.');
    }
  }

  checkOwner() {
    console.log('Checking  owner');

    if(this.owner)
      try {
        //console.log("CURRENT ACCOUNT: "+ this.account);
        //console.log("OWNER: "+ this.owner);
        if(this.account != this.owner)
          this.router.navigate(['/']);
      } catch (e) {
        console.log(e);
        this.setStatus('Error getting owner; see log.');
      }
  }

  checkTDBay(){
    if (!this.TDBay) {
      this.setStatus('Metacoin is not loaded, unable to send transaction');
      return;
    }
  }

  setStatus(status) {
  
    this.matSnackBar.open(status, '', {duration: 3000});
  }

  async refreshState() {
    console.log('Refreshing contract');

    try {
      const deployedBay = await this.TDBay.deployed();
      console.log(deployedBay);

      const wallet = await deployedBay.wallet.call();
      this.model.wallet = wallet;

      const tokenContract = await deployedBay.tokenContract.call();
      this.model.tokenContract = tokenContract;

      const designContract = await deployedBay.designContract.call();
      this.model.designContract = designContract;

      const projectCost = await deployedBay.projectCost.call();
      const designBidCost = await deployedBay.designBidCost.call();
      const manufactureBidCost = await deployedBay.manufactureBidCost.call();
      console.log('Found costs: ' + projectCost + ' ' + designBidCost + ' ' + manufactureBidCost);
      this.model.projectCost = projectCost;
      this.model.designBidCost = designBidCost;
      this.model.manufactureBidCost = manufactureBidCost;
      
      const projectFee = await deployedBay.getProjectCreationFee.call();
      this.model.projectFee = projectFee.fee;
      this.model.projectFeeRate = projectFee.rate;
    } catch (e) {
      console.log(e);
      this.setStatus('Error refreshin contract; see log.');
    }
  }

  async setProjectCost(e){
    console.log('Setting project cost: ' + e.target.value);
    this.model.projectCost = e.target.value;
  }

  async updateProjectCost(){
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      console.log(this.model.account);
      console.log(this.account);
      const transaction = await deployedBay.setProjectCost.sendTransaction(this.model.projectCost, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting project cost; see log.');
    }
    
  }
  async setDesignBidCost(e){
    console.log('Setting project cost: ' + e.target.value);
    this.model.designBidCost = e.target.value;
  }

  async updateDesignBidCost(){
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.setDesignBidCost.sendTransaction(this.model.designBidCost, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
    
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting design bid cost; see log.');
    }
    
  }

  async setManufactureBidCost(e){
    console.log('Setting project cost: ' + e.target.value);
    this.model.manufactureBidCost = e.target.value;
  }

  async updateManufactureBidCost(){
    this.setStatus('Initiating transaction... (please wait)');
    
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.setManufactureBidCost.sendTransaction(this.model.manufactureBidCost, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting manufacture bid cost; see log.');
    }
    
  }

  async setProjectFee(e){
    this.model.projectFee = e.target.value;
  }

  async setProjectFeeRate(e){
    this.model.projectFeeRate = e.target.value;
  }

  async updateProjectFee(){
    this.checkTDBay();
    console.log('Updating fee to' + this.model.projectFee + ' and rate to ' + this.model.projectFeeRate);

    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployed = await this.TDBay.deployed();
      const transaction = await deployed.setProjectCreationFee.sendTransaction(
        this.model.projectFee, this.model.projectFeeRate, 
        {from: this.model.account});

      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
    } catch (e) {
      console.log(e);
      this.setStatus('Error updating project fee; see log.');
    }
  }

  async setTokenContract(e){
    console.log('Setting new token contract: ' + e.target.value);
    const address = e.target.value;
    this.model.tokenContract = e.target.value;
  }

  async updateTokenContract(){
    this.setStatus('Initiating transaction... (please wait)');
    
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.setTokenContract.sendTransaction(this.model.tokenContract, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting token contract; see log.');
    }
  }


  async setDesignContract(e) {
    console.log('Setting design contract: ' + e.target.value);
    this.model.designContract = e.target.value;
  }

  async updateDesignContract(){
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.setDesignContract.sendTransaction(this.model.designContract, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting design contract; see log.');
    }
  }

  async callInitializeContract(){
    console.log('Calling contract initialization...');
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.initializeTDBay.sendTransaction(
          this.model.tokenContract, 
          this.model.designContract, 
          this.model.projectCost,
          this.model.designBidCost,
          this.model.manufactureBidCost,
          {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting contract parameters; see log.');
    }
  }

  async setWallet(e) {
    console.log('Setting wallet: ' + e.target.value);
    this.model.wallet = e.target.value;
  }

  async updateWallet(){
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.changeWallet.sendTransaction(this.model.wallet, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
        console.log(transaction);
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting wallet; see log.');
    }
  }

  async setWithdrawAmount(e){
    console.log('Setting withdraw amount: ' + e.target.value);
    this.model.withdrawAmount = e.target.value;
  }

  async withdrawToWallet(){
    this.setStatus('Initiating transaction... (please wait)');
    try {
      const deployedBay = await this.TDBay.deployed();
      const transaction = await deployedBay.withdraw.sendTransaction(this.model.withdrawAmount, {from: this.model.account});
      if (!transaction) {
        this.setStatus('Transaction failed!');
      } else {
        this.setStatus('Transaction complete!');
        console.log(transaction);
      }
      this.refreshState();
    } catch (e) {
      console.log(e);
      this.setStatus('Error setting wallet; see log.');
    }
  }
}
