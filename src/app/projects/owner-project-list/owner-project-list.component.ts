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
    projectIds: [],
    projects:[]
  }
  constructor(private web3Service: Web3Service, 
              private tdbayService: TDBayService) { }

  ngOnInit() {
    //this.model.projects=[];
    this.watchProjects();
  }

  watchProjects() {
    this.tdbayService.userProjects$.subscribe((projectIds) => {
        this.model.projectIds = projectIds;
        this.refreshProjects();
        console.log(projectIds);
    });
  }


  async refreshProjects(){
    for (const id in this.model.projectIds) {
      const tdb = await this.tdbayService.getAbstraction();
      const deployed = await tdb.deployed();
      const project = await deployed.projects.call(id);
      this.model.projects.push(project);
    }
  }
}
