import {Injectable} from '@angular/core';
import contract from 'truffle-contract';
import {BehaviorSubject, Subject} from 'rxjs';
declare let require: any;
const Web3 = require('web3');


declare let window: any;

@Injectable()
export class Web3Service {
  private web3: any;
  private accounts: string[];
  private balances = {};
  public ready = false;

  public accountsObservable = new BehaviorSubject<string[]>([]);
  public currentAccount = new BehaviorSubject<string>('');
  public curBalance = new BehaviorSubject<{}>({});

  constructor() {
    window.addEventListener('load', (event) => {
      this.bootstrapWeb3();
    });
  }

  public bootstrapWeb3() {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
    if (typeof window.web3 !== 'undefined') {
      // Use Mist/MetaMask's provider
      this.web3 = new Web3(window.web3.currentProvider);
    } else {
      console.log('No web3? You should consider trying MetaMask!');

      // Hack to provide backwards compatibility for Truffle, which uses web3js 0.20.x
      Web3.providers.HttpProvider.prototype.sendAsync = Web3.providers.HttpProvider.prototype.send;
      // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
      this.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'));
    }

    setInterval(() => this.refreshData(), 1000);
  }

  public async artifactsToContract(artifacts) {
    if (!this.web3) {
      const delay = new Promise(resolve => setTimeout(resolve, 100));
      await delay;
      return await this.artifactsToContract(artifacts);
    }

    const contractAbstraction = contract(artifacts);
    contractAbstraction.setProvider(this.web3.currentProvider);
    //var deployed = contractAb
    var deployed = await contractAbstraction.deployed();
    var address = await deployed.address;
    this.balances[contractAbstraction.address] = -1;
    return contractAbstraction;

  }

  private async refreshData() {
    this.web3.eth.getAccounts((err, accs) => {
      console.log('Refreshing web3 data.');
      if (err != null) {
        console.warn('There was an error fetching your accounts.');
        return;
      }

      // Get the initial account balance so it can be displayed.
      if (accs.length === 0) {
        console.warn('Couldn\'t get any accounts! Make sure your Ethereum client is configured correctly.');
        return;
      }

      if (!this.accounts || this.accounts.length !== accs.length || this.accounts[0] !== accs[0]) {
        console.log('Observed new accounts');

        this.accountsObservable.next(accs);
        this.accounts = accs;
        this.currentAccount.next(this.accounts[0]);
      }

      this.ready = true;
    });

    // Refresh contract balances
    for(var key in this.balances) {
      var curbal = this.balances[key];
      var newbal = await this.web3.eth.getBalance(key);
      if(newbal != curbal){
        console.log('Observed new balances. Old: '+ curbal + "; New: "+newbal);
        this.balances[key] = newbal;
        this.curBalance.next(this.balances);
      }
    }
  }
}
