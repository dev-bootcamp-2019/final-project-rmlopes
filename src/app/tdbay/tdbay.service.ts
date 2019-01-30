import { Injectable } from '@angular/core';
import {Web3Service} from '../util/web3.service';
import { BehaviorSubject } from 'rxjs';


declare let require: any;
const tdbay_artifacts = require('../../../build/contracts/TDBay.json');

@Injectable({
  providedIn: 'root'
})
export class TDBayService {

  private TDBay;
  private account;

  private projects;
  public projects$ = new BehaviorSubject<[]>([]);

  private userProjects;
  public userProjects$ = new BehaviorSubject<[]>([]);

  constructor(private web3Service: Web3Service) { 
    this.web3Service.artifactsToContract(tdbay_artifacts)
      .then((TDBayAbstraction) => {
        this.TDBay = TDBayAbstraction;
        this.TDBay.deployed().then(deployed => {
          console.log(deployed);
        });

      });

    setInterval(() => this.watchAccount(), 1000);
    setInterval(() => this.refreshProjects(), 1000);
    setInterval(() => this.refreshUserProjects(), 1000);
  }

  watchAccount() {
    this.web3Service.currentAccount.subscribe(current => {
        if(current){
          this.account = current;
        }
    });
  }

  private async refreshProjects(){
    if(this.TDBay)
      try{
        var deployed = await this.TDBay.deployed();
        var _projects = await deployed.fetchProjects.call();

        if (!this.projects || this.projects.length !== _projects.length) {
          console.log('Observed new projects');
          this.projects = _projects;
          this.projects$.next(_projects);
        }
      }
      catch(e){
        console.log(e);
      }
  }

  public async forceRefreshProjects(){
    if(this.TDBay){
      this.projects=[];
      this.userProjects=[];
    }
  }

  public async refreshUserProjects(){
    //console.log("Updating user projects");
    if(this.TDBay)
      try{
        var deployed = await this.TDBay.deployed();
        var _projects = await deployed.fetchUserProjects.call(this.account);

        if (!this.userProjects || this.userProjects.length !== _projects.length) {
          console.log('Observed new projects');
          this.userProjects = _projects;
          this.userProjects$.next(_projects);
        }
      }
      catch(e){
        console.log(e);
      }
  }

  getAbstraction(){
    return this.TDBay;
  }
}
