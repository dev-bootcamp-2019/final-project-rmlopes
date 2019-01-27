import { Injectable } from '@angular/core';
import { Web3Service } from '../util/web3.service';
import { TDBayService } from '../tdbay/tdbay.service';
import { MatSnackBar } from '@angular/material';
import { delay } from 'q';
import { Subject, BehaviorSubject } from 'rxjs';

declare let require: any;
const design_artifacts = require('../../../build/contracts/Design.json');

@Injectable({
  providedIn: 'root'
})
export class DesignContractService {

  Design: any;
  public abstraction$ = new Subject<any>();

  private userDesigns;
  public userDesigns$ = new BehaviorSubject<[]>([]);
  
  public account;
  
  constructor(private web3Service: Web3Service, 
              private tdbService: TDBayService,
              private matSnackBar: MatSnackBar) { 
    this.init();
    this.watchAccount();
    setInterval(() => this.refreshDesigns(), 1000);
  }

  async init(){
    this.web3Service.artifactsToContract(design_artifacts)
      .then((DesignAbstraction) => {
        this.Design = DesignAbstraction;
        this.abstraction$.next(this.Design);
        this.Design.deployed().then(deployed => {
          console.log(deployed);
          //new Event("design-abstraction-loaded");
      });
    });
  }

  watchAccount() {
    this.web3Service.currentAccount.subscribe(current => {
        if(current){
          this.account = current;
        }
    });
  }

  getAbstraction(){
      return this.abstraction$;
  }

  async setMaster(){
    var deployed = await this.tdbService.getAbstraction().deployed();
    var cur_account = this.account;

    console.log("CURRENT ACCOUNT FOR DESIGN:" + cur_account);
    var tdb_address = deployed.address;

    var thisDeployed = await this.Design.deployed();
    var transaction = await thisDeployed.setMaster.sendTransaction(tdb_address, 
        {from: cur_account
      });
    if (!transaction) {
      this.setStatus('Transaction failed!');
    } else {
      this.setStatus('Transaction complete!');
    }
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 10000});
  }

  private async refreshDesigns(){
    if(this.Design)
      try{
        var deployed = await this.Design.deployed();
        var bids = await deployed.getOwnerDesigns.call({from: this.account});

        if (!this.userDesigns || this.userDesigns.length !== bids.length) {
          console.log('Observed new projects');
          this.userDesigns = bids;
          this.userDesigns$.next(bids);
        }
      }
      catch(e){
        console.log(e);
      }
  }



  // async getDesignListings(){
  //   console.log("Getting designs for user "+ this.account);
  //   try {
  //       var deployed = await this.Design.deployed();
  //       var bids = await deployed.getOwnerDesigns.call({from: this.account});
  //       return bids;
  //       console.log("Owner designs: "+bids);
  //   } catch (e) {
  //     console.log(e);
  //     this.setStatus('Error creating project; see log.');
  //   }
  // }


  async addDesignBid(projectId, cost, description){
    console.log("Adding design bid to project "+ projectId);
    this.setStatus("Initiating transaction. Please wait...")
    try {
      var tdbDeployed = await this.tdbService.getAbstraction().deployed();
      var bidcost = await tdbDeployed.designBidCost.call();
      //var intpid: BigInteger;
      //intpid = projectId;

        console.log("Design bid cost is : " + bidcost);
        console.log("Design cost is : " + cost);

        console.log("Sending transaction from " + this.account + "with value "+bidcost);
  
        var deployed = await this.Design.deployed();
        var transaction = await deployed.addDesignBid.sendTransaction(
          projectId, 
          cost,
          description,
          {from: this.account,
          value: bidcost});
        if (!transaction) {
          this.setStatus('Transaction failed!');
        } else {
          this.setStatus('Transaction complete!');
        }
    } catch (e) {
      console.log(e);
      this.setStatus('Error creating project; see log.');
    }
  }
}
