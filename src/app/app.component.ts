import { Component, OnInit, NgZone } from '@angular/core';
import { Router, ActivatedRoute, ParamMap } from '@angular/router';

import {Web3Service} from './util/web3.service';
declare let require: any;
const tdbay_artifacts = require('../../build/contracts/TDBay.json');


@Component({
  selector: 'app-root',
  templateUrl: './app.component.html',
  styleUrls: ['./app.component.css']
})
export class AppComponent implements OnInit {
  title = '3DBay!';
  welcomeMessage = "Welcome to 3DBay! Use Metamask to login.";
  useComponent: string;

  accounts: string[];
  TDBay: any;
  ownerAccount: string;
  account: string;

  constructor(
    private ngZone: NgZone,
    private route: ActivatedRoute,
    private router: Router,
    private web3Service: Web3Service) {
    console.log('Constructor: ' + web3Service);
  }


  ngOnInit(): void {
    console.log('OnInit: ' + this.web3Service);
    console.log(this);
    this.watchAccount();
    this.web3Service.artifactsToContract(tdbay_artifacts)
      .then((TDBayAbstraction) => {
        this.TDBay = TDBayAbstraction;
        this.TDBay.deployed().then(deployed => {
          console.log(deployed);
          deployed.owner().then(value => {
            this.ownerAccount = value;
            //this.redirectMe();
          });
        });
      });
    
  }

  watchAccount() {
    this.web3Service.accountsObservable.subscribe((accounts) => {
      this.accounts = accounts;
      this.account = this.accounts[0];  
      if(this.account)
        this.welcomeMessage = "Welcome "+this.account +"!";
    });
  }

  redirectMe(){
    if(this.account && this.ownerAccount === this.account){
      this.router.navigate(['/tdbay-admin']);
    }
    else{
      this.router.navigate(['/tdbay']);
    } 
  }
}
