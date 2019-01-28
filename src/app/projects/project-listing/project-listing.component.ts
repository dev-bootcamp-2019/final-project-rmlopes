import { Component, OnInit } from '@angular/core';
import {Web3Service} from '../../util/web3.service';
import {TDBayService} from '../../tdbay/tdbay.service';
import { MatSnackBar } from '@angular/material';
import { BehaviorSubject } from 'rxjs';

declare let require: any;
const tdbay_artifacts = require('../../../../build/contracts/TDBay.json');

@Component({
  selector: 'app-project-listing',
  templateUrl: './project-listing.component.html',
  styleUrls: ['./project-listing.component.css'],

})
export class ProjectListingComponent implements OnInit {

  public account: string;

  model = {
    projects: []
  };

  private projectIds$ = new BehaviorSubject<[]>([]);

  constructor(private web3Service: Web3Service, 
              private tdbayService: TDBayService,
              private matSnackBar: MatSnackBar,) { }

  ngOnInit() {
    console.log('ProjectListing OnInit: ' + this.web3Service);
    // this.web3Service.artifactsToContract(tdbay_artifacts)
    //   .then((TDBayAbstraction) => {
    //     this.TDBay = TDBayAbstraction;
    //     this.TDBay.deployed().then(deployed => {
    //       console.log(deployed);
    //       this.model.projects = deployed.fetchProjects.call().then( projects => {
    //         console.log(projects);
    //         this.model.projects = projects;
    //       });
          
    //     });

    //   });
    this.watchProjects();
  }

  setStatus(status) {
    this.matSnackBar.open(status, '', {duration: 3000});
  }

  watchProjects() {
    this.tdbayService.projects$.subscribe(projects => {
        this.model.projects = projects;
        console.log(projects);
    });
  }
}
