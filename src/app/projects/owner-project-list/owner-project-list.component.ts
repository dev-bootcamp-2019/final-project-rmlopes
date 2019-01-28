import { Component, OnInit } from '@angular/core';
import { TDBayService } from '../../tdbay/tdbay.service';
import { Web3Service } from '../../util/web3.service';

@Component({
  selector: 'app-owner-project-list',
  templateUrl: './owner-project-list.component.html',
  styleUrls: ['./owner-project-list.component.css']
})
export class OwnerProjectListComponent implements OnInit {

  model = {
    projects: []
  }
  constructor(private web3Service: Web3Service, 
              private tdbayService: TDBayService) { }

  ngOnInit() {
    //this.model.projects=[];
    this.watchProjects();
  }

  watchProjects() {
    this.tdbayService.userProjects$.subscribe((projects) => {
        this.model.projects = projects;
        console.log(projects);
    });
  }
}
